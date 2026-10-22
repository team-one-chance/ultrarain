Add-Type -AssemblyName System.Drawing
$source = [System.Drawing.Bitmap]::FromFile((Join-Path $PSScriptRoot 'sdrone1-frame2-source.png'))
$result = New-Object System.Drawing.Bitmap $source.Width,$source.Height
$palette = @{}
function Get-Shade([string]$hex) {
    if (-not $palette.ContainsKey($hex)) {
        $palette[$hex] = [System.Drawing.ColorTranslator]::FromHtml($hex)
    }
    return $palette[$hex]
}

# Recolor only. Pixel positions, alpha, part boundaries and all original
# details are read directly from sDrone_1's second frame without resampling.
for ($y = 0; $y -lt $source.Height; $y++) {
    for ($x = 0; $x -lt $source.Width; $x++) {
        $pixel = $source.GetPixel($x,$y)
        if ($pixel.A -eq 0) { continue }
        $hex = '#0d0d0d'
        $isRed = $pixel.R -gt (2 * $pixel.G + 20)
        $isFire = $isRed -and $y -ge 9 -and ($x -le 12 -or $x -ge 36)
        if ($isFire) {
            # The original two flame colors become a hot core and cooler rim.
            # All flame pixels and their original silhouettes stay in place.
            $isCore = $pixel.R -lt 160
            if ($isCore) {
                if ($y -le 11) { $hex = '#ed3131' }
                elseif ($y -le 15) { $hex = '#c82929' }
                elseif ($y -le 19) { $hex = '#9e0b0f' }
                else { $hex = '#7f080c' }
                $flameCenter = if ($x -le 12) { 7 } else { 41 }
                if ($y -le 11 -and [Math]::Abs($x - $flameCenter) -le 1) {
                    $hex = '#e87f7f'
                }
                if ($y -eq 9 -and $x -eq $flameCenter) { $hex = '#ffd7d7' }
            } else {
                if ($y -le 11) { $hex = '#c82929' }
                elseif ($y -le 15) { $hex = '#9e0b0f' }
                else { $hex = '#7f080c' }
            }
        } elseif ($isRed) {
            if ($pixel.R -ge 220) { $hex = '#f94e4e' }
            elseif ($pixel.R -ge 150) { $hex = '#ed3131' }
            elseif ($y -eq 7 -and $x -ge 20 -and $x -le 30) { $hex = '#ed3131' }
            else { $hex = '#c82929' }
        } elseif ($pixel.R -eq 0 -and $pixel.G -eq 0 -and $pixel.B -eq 0) {
            # Preserve every existing seam and black recess.
            $hex = '#0d0d0d'
        } elseif ($pixel.R -eq 76) {
            # Neutral charcoal steel from the reference's top-left sprite.
            $hex = '#414141'
        } elseif ($pixel.R -eq 63) {
            # Existing rim/outline region, without changing its thickness.
            if ($y -eq 9) { $hex = '#353535' }
            elseif ($y -le 14) { $hex = '#1d1d1d' }
            else { $hex = '#161616' }
        } else {
            # Existing body planes get stepped metallic shading.
            if ($y -le 8) { $hex = '#222222' }
            elseif ($y -eq 10) { $hex = '#3f3f3f' }
            elseif ($y -le 13) { $hex = '#292929' }
            elseif ($y -eq 14) { $hex = '#353535' }
            elseif ($y -eq 15) { $hex = '#292929' }
            elseif ($y -eq 16) { $hex = '#222222' }
            elseif ($y -eq 17) { $hex = '#1d1d1d' }
            else { $hex = '#161616' }
        }
        $shade = Get-Shade $hex
        $result.SetPixel($x,$y,([System.Drawing.Color]::FromArgb($pixel.A,$shade.R,$shade.G,$shade.B)))
    }
}
$result.Save((Join-Path $PSScriptRoot 'sdrone1-frame2-polished.png'))

$preview = New-Object System.Drawing.Bitmap 768,512
$g = [System.Drawing.Graphics]::FromImage($preview)
$g.Clear([System.Drawing.Color]::FromArgb(65,65,70))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($result,0,0,768,512)
$preview.Save((Join-Path $PSScriptRoot 'sdrone1-frame2-polished-preview.png'))
$g.Dispose()
$preview.Dispose()
$source.Dispose()
$result.Dispose()
