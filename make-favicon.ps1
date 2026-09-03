# Builds a favicon set from the "J" glyph in images/logo.png.
#
# The full wordmark is unreadable below about 64px, so the leading J is lifted
# out and set in white on the brand accent. A saturated tile stays legible in a
# crowded tab strip on both light and dark browser chrome.

Add-Type -AssemblyName System.Drawing

$srcPath = Join-Path $PSScriptRoot 'images\logo.png'
$outDir = Join-Path $PSScriptRoot 'images'

# Measured bounds of the accent-coloured J inside logo.png.
$gx = 5; $gy = 208; $gw = 62; $gh = 94

$accent = [System.Drawing.Color]::FromArgb(255, 255, 0, 79)

$src = New-Object System.Drawing.Bitmap([System.Drawing.Image]::FromFile($srcPath))

# White glyph with alpha taken from the source ink, so anti-aliased edges survive.
$glyph = New-Object System.Drawing.Bitmap($gw, $gh, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($y = 0; $y -lt $gh; $y++) {
    for ($x = 0; $x -lt $gw; $x++) {
        $c = $src.GetPixel($gx + $x, $gy + $y)
        $a = [Math]::Max($c.R, [Math]::Max($c.G, $c.B))
        $glyph.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, 255, 255, 255))
    }
}
$src.Dispose()

function New-Icon {
    param([int]$Size, [double]$Inset = 0.70)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

        $g.Clear($accent)

        # Scale by height and centre; the J is taller than it is wide.
        $h = [double]$Size * $Inset
        $w = $h * ($gw / [double]$gh)
        $left = ($Size - $w) / 2.0
        $top = ($Size - $h) / 2.0
        $g.DrawImage($glyph, [float]$left, [float]$top, [float]$w, [float]$h)
    } finally {
        $g.Dispose()
    }
    return $bmp
}

function Save-Png {
    param([System.Drawing.Bitmap]$Bmp, [string]$Name)
    $p = Join-Path $outDir $Name
    $Bmp.Save($p, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host ("  {0,-26} {1,3}x{2,-3}  {3,6:N1} KB" -f $Name, $Bmp.Width, $Bmp.Height, ((Get-Item $p).Length / 1KB))
}

Write-Host 'generated:'

# Small sizes get slightly more inset so the glyph is not cramped against edges.
$png16 = New-Icon -Size 16 -Inset 0.74
$png32 = New-Icon -Size 32 -Inset 0.72
$png48 = New-Icon -Size 48 -Inset 0.70

Save-Png $png32 'favicon-32.png'
$apple = New-Icon -Size 180 -Inset 0.66
Save-Png $apple 'apple-touch-icon.png'
$i192 = New-Icon -Size 192 -Inset 0.68
Save-Png $i192 'icon-192.png'
$i512 = New-Icon -Size 512 -Inset 0.68
Save-Png $i512 'icon-512.png'

# ---- favicon.ico containing 16/32/48 as embedded PNGs (supported since Vista)
$images = @($png16, $png32, $png48)

# A List[byte[]] is required here: piping byte arrays through ForEach-Object
# flattens them into one long byte stream and the size fields come out wrong.
$payloads = New-Object 'System.Collections.Generic.List[byte[]]'
foreach ($bmp in $images) {
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $payloads.Add($ms.ToArray())
    $ms.Dispose()
}

$icoPath = Join-Path $outDir 'favicon.ico'
$fs = [System.IO.File]::Create($icoPath)
$bw = New-Object System.IO.BinaryWriter($fs)
try {
    $bw.Write([UInt16]0)                    # reserved
    $bw.Write([UInt16]1)                    # type: icon
    $bw.Write([UInt16]$images.Count)

    $offset = 6 + (16 * $images.Count)
    for ($i = 0; $i -lt $images.Count; $i++) {
        $bmp = $images[$i]
        $len = $payloads[$i].Length
        $bw.Write([Byte]($(if ($bmp.Width -ge 256) { 0 } else { $bmp.Width })))
        $bw.Write([Byte]($(if ($bmp.Height -ge 256) { 0 } else { $bmp.Height })))
        $bw.Write([Byte]0)                  # palette count
        $bw.Write([Byte]0)                  # reserved
        $bw.Write([UInt16]1)                # colour planes
        $bw.Write([UInt16]32)               # bits per pixel
        $bw.Write([UInt32]$len)
        $bw.Write([UInt32]$offset)
        $offset += $len
    }
    foreach ($p in $payloads) { $bw.Write($p) }
} finally {
    $bw.Dispose()
    $fs.Dispose()
}

Write-Host ("  {0,-26} 16/32/48   {1,6:N1} KB" -f 'favicon.ico', ((Get-Item $icoPath).Length / 1KB))

$images | ForEach-Object { $_.Dispose() }
$apple.Dispose(); $i192.Dispose(); $i512.Dispose(); $glyph.Dispose()
