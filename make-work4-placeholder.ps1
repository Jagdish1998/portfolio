# Generates a dark-themed 650x800 placeholder for the LLM Gateway card, matching the site's
# background and accent, until a real screenshot replaces images/opt/work-4-800.jpg. The other
# work-*.jpg tiles are placeholders too; this keeps the fourth card consistent with them.
Add-Type -AssemblyName System.Drawing

$w = 650
$h = 800
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'ClearTypeGridFit'

$bg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(13, 17, 23))
$g.FillRectangle($bg, 0, 0, $w, $h)

$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 48, 54, 61), 1)
for ($x = 0; $x -le $w; $x += 40) { $g.DrawLine($pen, $x, 0, $x, $h) }
for ($y = 0; $y -le $h; $y += 40) { $g.DrawLine($pen, 0, $y, $w, $y) }

$accent = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 79))
$g.FillRectangle($accent, 60, 300, 60, 6)

$titleFont = New-Object System.Drawing.Font('Segoe UI Semibold', 34, [System.Drawing.FontStyle]::Bold)
$white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 237, 243))
$g.DrawString('LLM Gateway', $titleFont, $white, 58, 330)

$subFont = New-Object System.Drawing.Font('Consolas', 15)
$muted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(139, 148, 158))
$g.DrawString('budgets - cache - resilience - cost', $subFont, $muted, 60, 392)
$g.DrawString('screenshot pending', $subFont, $muted, 60, 420)

$g.Dispose()
$out = Join-Path $PSScriptRoot 'images\opt\work-4-800.jpg'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp.Dispose()
Write-Output ("created: {0} ({1}KB)" -f $out, [math]::Round((Get-Item $out).Length / 1KB))
