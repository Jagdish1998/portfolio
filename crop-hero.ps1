# The original hero used images/background.png (1616x909), which has the portrait
# composited onto flat black with the left ~40% left empty for the headline text.
# This crops the photographic region out so it can be used as a real <img> in the
# hero instead of an unresponsive background-image.

Add-Type -AssemblyName System.Drawing

$src = Join-Path $PSScriptRoot 'images\background.png'
$outDir = Join-Path $PSScriptRoot 'images\opt'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

# Measured content bounding box was x 681..1593, y 87..906. Pad slightly and keep
# the full height so nothing at the top of the frame gets clipped.
$cropX = 686
$cropY = 74
$cropW = 1616 - $cropX - 8
$cropH = 909 - $cropY

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq 'image/jpeg' }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters 1
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality, 82)

$img = [System.Drawing.Image]::FromFile($src)
try {
    $rect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)

    foreach ($target in 800, 1200) {
        $scale = [Math]::Min(1.0, $target / [double]$cropW)
        $w = [int][Math]::Round($cropW * $scale)
        $h = [int][Math]::Round($cropH * $scale)

        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        try {
            $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $dest = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
            $g.DrawImage($img, $dest, $rect, [System.Drawing.GraphicsUnit]::Pixel)
        } finally {
            $g.Dispose()
        }

        $out = Join-Path $outDir ("hero-portrait-{0}.jpg" -f $target)
        $bmp.Save($out, $encoder, $encParams)
        $bmp.Dispose()

        Write-Host ("wrote images/opt/hero-portrait-{0}.jpg  {1} x {2}  {3} KB" -f `
            $target, $w, $h, [math]::Round((Get-Item $out).Length / 1KB, 1))
    }
} finally {
    $img.Dispose()
}

Write-Host ("crop region: x {0} y {1}  {2} x {3}" -f $cropX, $cropY, $cropW, $cropH)
