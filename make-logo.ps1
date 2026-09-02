# images/logo.png is a 500x500 tile: white wordmark baked onto solid black.
# This converts luminance to alpha (black -> transparent, white -> opaque),
# trims to the wordmark bounding box and writes a transparent PNG.
# The result is white, so light theme just inverts it in CSS.

Add-Type -AssemblyName System.Drawing

$src = Join-Path $PSScriptRoot 'images\logo.png'
$outDir = Join-Path $PSScriptRoot 'images\opt'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$out = Join-Path $outDir 'logo-mark.png'

$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
$img.Dispose()

$w = $bmp.Width
$h = $bmp.Height

# Alpha map from luminance.
$alpha = New-Object 'int[,]' $w, $h
$minX = $w; $minY = $h; $maxX = -1; $maxY = -1

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, $y)
        $lum = [int](0.299 * $c.R + 0.587 * $c.G + 0.114 * $c.B)
        if ($lum -lt 18) { $lum = 0 }
        $alpha[$x, $y] = $lum
        if ($lum -gt 24) {
            if ($x -lt $minX) { $minX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

if ($maxX -lt 0) { throw 'No wordmark pixels found in logo.png' }

# Small breathing room around the mark.
$pad = 4
$minX = [Math]::Max(0, $minX - $pad)
$minY = [Math]::Max(0, $minY - $pad)
$maxX = [Math]::Min($w - 1, $maxX + $pad)
$maxY = [Math]::Min($h - 1, $maxY + $pad)

$cw = $maxX - $minX + 1
$ch = $maxY - $minY + 1

$outBmp = New-Object System.Drawing.Bitmap($cw, $ch, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($y = 0; $y -lt $ch; $y++) {
    for ($x = 0; $x -lt $cw; $x++) {
        $a = $alpha[($minX + $x), ($minY + $y)]
        $outBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, 255, 255, 255))
    }
}

# The wordmark renders at ~132 CSS px, so 300px wide covers 2x displays without
# shipping a needlessly large file.
$targetW = 300
$targetH = [int][Math]::Round($ch * ($targetW / [double]$cw))

$final = New-Object System.Drawing.Bitmap($targetW, $targetH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($final)
try {
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($outBmp, 0, 0, $targetW, $targetH)
} finally {
    $g.Dispose()
}

$final.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)

Write-Host ("source      : {0} x {1}" -f $w, $h)
Write-Host ("wordmark box: x {0}..{1}  y {2}..{3}  ({4} x {5})" -f $minX, $maxX, $minY, $maxY, $cw, $ch)
Write-Host ("written     : images/opt/logo-mark.png  ({0} x {1}, {2} KB)" -f $targetW, $targetH, [math]::Round((Get-Item $out).Length / 1KB, 1))

$final.Dispose()
$outBmp.Dispose()
$bmp.Dispose()
