Add-Type -AssemblyName System.Drawing
$sourcePath = Join-Path $PSScriptRoot 'sdrone-original-source.png'
$source = [System.Drawing.Bitmap]::FromFile($sourcePath)
$width = 62
$height = 32
$sprite = New-Object System.Drawing.Bitmap $width,$height
$mask = New-Object 'bool[,]' $width,$height
$sample = New-Object 'System.Drawing.Color[,]' $width,$height
$ink = [System.Drawing.ColorTranslator]::FromHtml('#0c0b10')
$palette = @(
    '#29292e', '#3b3b41', '#52535b', '#74767b',
    '#580c15', '#850d18', '#bd1522', '#e92b31'
) | ForEach-Object { [System.Drawing.ColorTranslator]::FromHtml($_) }

# Crop only the original padding. All geometry comes from the user's artwork.
$minX = $source.Width
$minY = $source.Height
$maxX = -1
$maxY = -1
for ($y = 0; $y -lt $source.Height; $y++) {
    for ($x = 0; $x -lt $source.Width; $x++) {
        if ($source.GetPixel($x,$y).A -lt 128) { continue }
        $minX = [Math]::Min($minX,$x)
        $maxX = [Math]::Max($maxX,$x)
        $minY = [Math]::Min($minY,$y)
        $maxY = [Math]::Max($maxY,$y)
    }
}
$cropWidth = $maxX - $minX + 1
$cropHeight = $maxY - $minY + 1
$artWidth = 60
$artHeight = [int][Math]::Round($artWidth * $cropHeight / $cropWidth)
$offsetY = [int][Math]::Floor(($height - $artHeight) / 2)
for ($y = 0; $y -lt $artHeight; $y++) {
    for ($x = 0; $x -lt $artWidth; $x++) {
        $sx = $minX + [int][Math]::Floor(($x + 0.5) * $cropWidth / $artWidth)
        $sy = $minY + [int][Math]::Floor(($y + 0.5) * $cropHeight / $artHeight)
        $pixel = $source.GetPixel($sx,$sy)
        $dx = $x + 1
        $dy = $y + $offsetY
        $mask[$dx,$dy] = $pixel.A -ge 128
        $sample[$dx,$dy] = $pixel
    }
}
$source.Dispose()

# Quantize the existing materials, keeping their original regions and seams.
for ($y = 1; $y -lt ($height - 1); $y++) {
    for ($x = 1; $x -lt ($width - 1); $x++) {
        if (-not $mask[$x,$y]) { continue }
        $pixel = $sample[$x,$y]
        $isInk = $pixel.R -lt 26 -and $pixel.G -lt 26
        $boundary = -not $mask[($x-1),$y] -or -not $mask[($x+1),$y] -or
            -not $mask[$x,($y-1)] -or -not $mask[$x,($y+1)]
        # Remove doubled black edge pixels introduced by enlargement. Retain
        # the source's internal seams; only pixels beside the exterior qualify.
        if ($isInk -and -not $boundary) {
            $nearExterior = $false
            foreach ($delta in @(@(-2,0),@(2,0),@(0,-2),@(0,2))) {
                $nx = $x + $delta[0]
                $ny = $y + $delta[1]
                if ($nx -lt 0 -or $nx -ge $width -or $ny -lt 0 -or $ny -ge $height -or
                    -not $mask[$nx,$ny]) { $nearExterior = $true }
            }
            if ($nearExterior) {
                foreach ($delta in @(@(0,1),@(1,0),@(-1,0),@(0,-1))) {
                    $nx = $x + $delta[0]
                    $ny = $y + $delta[1]
                    $neighbor = $sample[$nx,$ny]
                    if ($mask[$nx,$ny] -and ($neighbor.R -ge 26 -or $neighbor.G -ge 26)) {
                        $pixel = $neighbor
                        $isInk = $false
                        break
                    }
                }
            }
        }
        if ($boundary -or $isInk) {
            $sprite.SetPixel($x,$y,$ink)
            continue
        }
        $isRed = $pixel.R -gt (2 * $pixel.G + 20)
        if ($isRed) {
            if ($pixel.R -ge 210) { $color = $palette[7] }
            elseif ($pixel.R -ge 155) { $color = $palette[6] }
            elseif ($pixel.R -ge 100) { $color = $palette[5] }
            else { $color = $palette[4] }
        } else {
            $brightness = ($pixel.R + $pixel.G + $pixel.B) / 3
            if ($brightness -ge 100) { $color = $palette[3] }
            elseif ($brightness -ge 72) { $color = $palette[2] }
            elseif ($brightness -ge 48) { $color = $palette[1] }
            else { $color = $palette[0] }
            # A single lit pixel row separates existing metal planes.
            $above = $sample[$x,($y-1)]
            if ($above.A -ge 128 -and $above.R -lt 26 -and $above.G -lt 26) {
                $color = $palette[2]
            }
        }
        $sprite.SetPixel($x,$y,$color)
    }
}

$sprite.Save((Join-Path $PSScriptRoot 'sdrone-original-refined.png'))
$preview = New-Object System.Drawing.Bitmap ($width*16),($height*16)
$graphics = [System.Drawing.Graphics]::FromImage($preview)
$graphics.Clear([System.Drawing.Color]::FromArgb(65,65,70))
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.DrawImage($sprite,0,0,$preview.Width,$preview.Height)
$preview.Save((Join-Path $PSScriptRoot 'sdrone-original-refined-preview.png'))
$graphics.Dispose()
$preview.Dispose()
$sprite.Dispose()
Write-Output "Original artwork: ${cropWidth}x${cropHeight}; refined artwork: ${artWidth}x${artHeight}; canvas: ${width}x${height}."
