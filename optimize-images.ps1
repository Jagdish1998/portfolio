# Generates resized, EXIF-rotated JPEGs into images/opt/.
# Originals are never modified.

Add-Type -AssemblyName System.Drawing

$srcDir = Join-Path $PSScriptRoot 'images'
$outDir = Join-Path $srcDir 'opt'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq 'image/jpeg' }
$quality = [System.Drawing.Imaging.Encoder]::Quality
$encParams = New-Object System.Drawing.Imaging.EncoderParameters 1
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($quality, 78)

$ORIENT_ID = 0x0112

function Convert-Image {
    param(
        [string]$Path,
        [string]$OutPath,
        [int]$MaxSide
    )

    $img = [System.Drawing.Image]::FromFile($Path)
    try {
        # Respect EXIF orientation so portrait phone shots are not sideways.
        if ($img.PropertyIdList -contains $ORIENT_ID) {
            $o = $img.GetPropertyItem($ORIENT_ID).Value[0]
            switch ($o) {
                3 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
                6 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
                8 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
            }
        }

        $scale = [Math]::Min(1.0, $MaxSide / [double][Math]::Max($img.Width, $img.Height))
        $w = [int][Math]::Round($img.Width * $scale)
        $h = [int][Math]::Round($img.Height * $scale)

        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        try {
            $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $g.Clear([System.Drawing.Color]::White)
            $g.DrawImage($img, 0, 0, $w, $h)
        } finally {
            $g.Dispose()
        }

        $bmp.Save($OutPath, $encoder, $encParams)
        $bmp.Dispose()
        return "{0}x{1}" -f $w, $h
    } finally {
        $img.Dispose()
    }
}

$targets = Get-ChildItem -Path $srcDir -File |
    Where-Object { $_.Extension -match '^\.(jpg|jpeg|png)$' -and $_.Name -notmatch '^(logo|icon-logo)\.png$' }

$results = @()
foreach ($f in $targets) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name) -replace '[^A-Za-z0-9_-]', ''
    # 500 for gallery tiles, 800 for larger slots, 1600 for the lightbox.
    foreach ($size in 500, 800, 1600) {
        $out = Join-Path $outDir ("{0}-{1}.jpg" -f $base, $size)
        $dim = Convert-Image -Path $f.FullName -OutPath $out -MaxSide $size
        $kb = [math]::Round((Get-Item $out).Length / 1KB, 1)
        $results += [pscustomobject]@{
            File = "{0}-{1}.jpg" -f $base, $size
            Dim  = $dim
            KB   = $kb
        }
    }
}

$results | Format-Table -AutoSize
$before = [math]::Round(($targets | Measure-Object Length -Sum).Sum / 1MB, 2)
$after = [math]::Round((Get-ChildItem $outDir -File | Measure-Object Length -Sum).Sum / 1MB, 2)
Write-Host ("originals: {0} MB  ->  optimized set: {1} MB" -f $before, $after)
