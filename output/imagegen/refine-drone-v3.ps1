Add-Type -AssemblyName System.Drawing

$inputPath = Join-Path $PSScriptRoot 'sdrone-example-v3-draft.png'
$outputPath = Join-Path $PSScriptRoot 'sdrone-example-v3.png'
$source = [System.Drawing.Bitmap]::FromFile($inputPath)
$width = 62
$height = 41
$mask = New-Object 'bool[,]' $width,$height
$colors = New-Object 'System.Drawing.Color[,]' $width,$height
$palette = @(
    '#24252d', '#3a3c46', '#515460', '#737887', '#a3a8b4',
    '#490c1b', '#7d1022', '#b51a2a', '#e43b3c'
) | ForEach-Object { [System.Drawing.ColorTranslator]::FromHtml($_) }
$outline = [System.Drawing.ColorTranslator]::FromHtml('#0c0b10')

# Sample one half on the native grid, then mirror the exact pixels.
for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt ($width / 2); $x++) {
        $pixel = $source.GetPixel($x, $y)
        $otherX = $width - 1 - $x
        $mask[$x,$y] = $pixel.A -ge 192
        $mask[$otherX,$y] = $mask[$x,$y]
        $bestDistance = [double]::PositiveInfinity
        $bestColor = $palette[0]
        $isRed = $pixel.R -gt (2 * $pixel.G + 20)
        foreach ($color in $palette) {
            $paletteIsRed = $color.R -gt (2 * $color.G + 20)
            if ($paletteIsRed -ne $isRed) { continue }
            $distance = [Math]::Pow(($pixel.R - $color.R), 2) +
                [Math]::Pow(($pixel.G - $color.G), 2) +
                [Math]::Pow(($pixel.B - $color.B), 2)
            if ($distance -lt $bestDistance) {
                $bestDistance = $distance
                $bestColor = $color
            }
        }
        $colors[$x,$y] = $bestColor
        $colors[$otherX,$y] = $bestColor
    }
}
$source.Dispose()

$sprite = New-Object System.Drawing.Bitmap $width,$height
for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        if (-not $mask[$x,$y]) { continue }
        # One native pixel of outline along the silhouette and open gaps.
        $boundary = $x -eq 0 -or $y -eq 0 -or
            $x -eq ($width - 1) -or $y -eq ($height - 1)
        if (-not $boundary) {
            $boundary = -not $mask[($x - 1),$y] -or
                -not $mask[($x + 1),$y] -or
                -not $mask[$x,($y - 1)] -or
                -not $mask[$x,($y + 1)]
        }
        if ($boundary) { $sprite.SetPixel($x, $y, $outline) }
        else { $sprite.SetPixel($x, $y, ($colors[$x,$y])) }
    }
}

# Keep the beam highlight straight and repeat small mechanical details exactly.
for ($x = 4; $x -le 18; $x++) {
    $sprite.SetPixel($x, 11, $palette[3])
    $sprite.SetPixel(($width - 1 - $x), 11, $palette[3])
}
foreach ($boltX in @(17,44)) {
    $sprite.SetPixel($boltX, 11, $palette[0])
    $sprite.SetPixel(($boltX - 1), 12, $palette[0])
    $sprite.SetPixel(($boltX + 1), 12, $palette[0])
    $sprite.SetPixel($boltX, 13, $palette[0])
    $sprite.SetPixel($boltX, 12, $palette[4])
}
foreach ($eyeX in @(27,34)) { $sprite.SetPixel($eyeX, 17, $palette[8]) }
foreach ($eyeX in @(28,33)) { $sprite.SetPixel($eyeX, 17, $palette[7]) }
$sprite.Save($outputPath)

$preview = New-Object System.Drawing.Bitmap ($width * 16),($height * 16)
$graphics = [System.Drawing.Graphics]::FromImage($preview)
$graphics.Clear([System.Drawing.Color]::FromArgb(60,60,65))
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.DrawImage($sprite, 0, 0, $preview.Width, $preview.Height)
$preview.Save((Join-Path $PSScriptRoot 'sdrone-example-v3-preview.png'))
$graphics.Dispose()
$preview.Dispose()
$sprite.Dispose()
