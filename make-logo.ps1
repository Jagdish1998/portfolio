# images/logo.png is a 500x500 tile holding the wordmark on solid black.
# The mark is two-tone: an accent "J" at rgb(255,0,79) followed by "agdish."
# in white.
#
# Keying the black out by luminance alone would leave the accent J at only ~33%
# opacity, because pink has far lower luminance than white. Instead alpha comes
# from max(R,G,B) and the colour is un-premultiplied, which preserves both tones
# and keeps anti-aliased edges clean.
#
# Two variants are produced because a colour mark cannot be recoloured with a
# CSS invert filter: inverting would turn the pink J green.

Add-Type -AssemblyName System.Drawing

$src = Join-Path $PSScriptRoot 'images\logo.png'
$outDir = Join-Path $PSScriptRoot 'images\opt'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$bmp = New-Object System.Drawing.Bitmap([System.Drawing.Image]::FromFile($src))
$w = $bmp.Width
$h = $bmp.Height

# Ink colour for the light theme, replacing white so it reads on a pale page.
$darkInk = @(20, 20, 26)

$alpha = New-Object 'int[,]' $w, $h
$rgb = New-Object 'int[,,]' $w, $h, 3
$minX = $w; $minY = $h; $maxX = -1; $maxY = -1

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, $y)
        $a = [Math]::Max($c.R, [Math]::Max($c.G, $c.B))
        if ($a -lt 8) { $alpha[$x, $y] = 0; continue }

        $alpha[$x, $y] = $a
        # Un-premultiply against the black backdrop.
        $scale = 255.0 / $a
        $rgb[$x, $y, 0] = [Math]::Min(255, [int][Math]::Round($c.R * $scale))
        $rgb[$x, $y, 1] = [Math]::Min(255, [int][Math]::Round($c.G * $scale))
        $rgb[$x, $y, 2] = [Math]::Min(255, [int][Math]::Round($c.B * $scale))

        if ($a -gt 24) {
            if ($x -lt $minX) { $minX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}
$bmp.Dispose()

if ($maxX -lt 0) { throw 'No wordmark pixels found in logo.png' }

$pad = 4
$minX = [Math]::Max(0, $minX - $pad); $minY = [Math]::Max(0, $minY - $pad)
$maxX = [Math]::Min($w - 1, $maxX + $pad); $maxY = [Math]::Min($h - 1, $maxY + $pad)
$cw = $maxX - $minX + 1
$ch = $maxY - $minY + 1

function Build-Variant {
    param([bool]$NeutralToDark)

    $out = New-Object System.Drawing.Bitmap($cw, $ch, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    for ($y = 0; $y -lt $ch; $y++) {
        for ($x = 0; $x -lt $cw; $x++) {
            $sx = $minX + $x; $sy = $minY + $y
            $a = $alpha[$sx, $sy]
            if ($a -eq 0) { $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0)); continue }

            $r = $rgb[$sx, $sy, 0]; $g = $rgb[$sx, $sy, 1]; $b = $rgb[$sx, $sy, 2]

            if ($NeutralToDark) {
                # Saturation separates the white lettering from the accent J.
                $mx = [Math]::Max($r, [Math]::Max($g, $b))
                $mn = [Math]::Min($r, [Math]::Min($g, $b))
                $sat = if ($mx -eq 0) { 0 } else { ($mx - $mn) / [double]$mx }
                if ($sat -lt 0.35) { $r = $darkInk[0]; $g = $darkInk[1]; $b = $darkInk[2] }
            }

            $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $g, $b))
        }
    }
    return $out
}

function Save-Scaled {
    param([System.Drawing.Bitmap]$Bmp, [string]$Name, [int]$TargetW = 300)

    $th = [int][Math]::Round($Bmp.Height * ($TargetW / [double]$Bmp.Width))
    $final = New-Object System.Drawing.Bitmap($TargetW, $th, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($final)
    try {
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.DrawImage($Bmp, 0, 0, $TargetW, $th)
    } finally { $g.Dispose() }

    $p = Join-Path $outDir $Name
    $final.Save($p, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host ("  {0,-24} {1}x{2}  {3:N1} KB" -f $Name, $TargetW, $th, ((Get-Item $p).Length / 1KB))
    $final.Dispose()
}

Write-Host ("wordmark box: x {0}..{1}  y {2}..{3}  ({4} x {5})" -f $minX, $maxX, $minY, $maxY, $cw, $ch)
Write-Host 'written:'

$dark = Build-Variant -NeutralToDark:$false
Save-Scaled $dark 'logo-mark.png'
$dark.Dispose()

$light = Build-Variant -NeutralToDark:$true
Save-Scaled $light 'logo-mark-light.png'
$light.Dispose()
