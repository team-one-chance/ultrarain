$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$samRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$samOriginalPath = Join-Path $samRoot 'sprites/sSam/6153a636-1f65-4c9a-992c-01b0184f5665.png'
$samOriginalHash = (Get-FileHash -LiteralPath $samOriginalPath).Hash
$samResourceDir = Join-Path $samRoot 'sprites/sSamNeutral'
if (Test-Path -LiteralPath $samResourceDir) { throw 'sSamNeutral already exists; refusing to overwrite it.' }
$samOriginal = [System.Drawing.Bitmap]::new($samOriginalPath)
$samNeutral = [System.Drawing.Bitmap]::new(64,96,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$samClear = [System.Drawing.Color]::FromArgb(0,0,0,0)
# Keep head, neck, and the complete original central torso at their exact positions.
for ($y=0; $y -lt 96; $y++) {
    for ($x=0; $x -lt 64; $x++) {
        if ($y -lt 24 -or ($y -lt 58 -and $x -ge 18 -and $x -le 34)) {
            $samNeutral.SetPixel($x,$y,$samOriginal.GetPixel($x,$y))
        } else { $samNeutral.SetPixel($x,$y,$samClear) }
    }
}
# Translate the original arm rows inward, keeping shoulders connected.
for ($y=24; $y -lt 58; $y++) {
    $samArmShift = if ($y -lt 29) { 0 } elseif ($y -lt 35) { 1 } else { 2 }
    foreach ($samSide in @(-1,1)) {
        $samFirst = if ($samSide -eq -1) { 0 } else { 35 }
        $samLast = if ($samSide -eq -1) { 17 } else { 63 }
        for ($x=$samFirst; $x -le $samLast; $x++) {
            $samPixel = $samOriginal.GetPixel($x,$y)
            $samDestX = $x - $samSide*$samArmShift
            if ($samPixel.A -gt 0 -and ($samDestX -lt 18 -or $samDestX -gt 34)) {
                $samNeutral.SetPixel($samDestX,$y,$samPixel)
            }
        }
    }
}
# Straighten each leg using row translations. Shoes move inward as intact blocks.
for ($y=58; $y -lt 96; $y++) {
    $samLegShift = if ($y -lt 64) { 0 } elseif ($y -lt 70) { 1 } elseif ($y -lt 77) { 2 } elseif ($y -lt 84) { 3 } else { 4 }
    for ($x=0; $x -lt 64; $x++) {
        $samPixel = $samOriginal.GetPixel($x,$y)
        if ($samPixel.A -gt 0) {
            $samDestX = if ($x -le 26) { $x+$samLegShift } else { $x-$samLegShift }
            $samNeutral.SetPixel($samDestX,$y,$samPixel)
        }
    }
}
# Check the invariant regions and original palette before writing assets.
$samPalette = [System.Collections.Generic.HashSet[int]]::new()
for ($y=0; $y -lt 96; $y++) { for ($x=0; $x -lt 64; $x++) { [void]$samPalette.Add($samOriginal.GetPixel($x,$y).ToArgb()) } }
for ($y=0; $y -lt 96; $y++) {
    for ($x=0; $x -lt 64; $x++) {
        $samPixel = $samNeutral.GetPixel($x,$y)
        if ($samPixel.A -gt 0 -and !$samPalette.Contains($samPixel.ToArgb())) { throw 'Unexpected new color.' }
        if (($y -lt 24 -or ($y -lt 58 -and $x -ge 18 -and $x -le 34)) -and $samPixel.ToArgb() -ne $samOriginal.GetPixel($x,$y).ToArgb()) { throw 'Protected head or torso pixel changed.' }
    }
}
$samFrame = [guid]::NewGuid().ToString()
$samLayer = [guid]::NewGuid().ToString()
$samKey = [guid]::NewGuid().ToString()
New-Item -ItemType Directory -Path "$samResourceDir/layers/$samFrame" -Force | Out-Null
$samNeutral.Save("$samResourceDir/$samFrame.png",[System.Drawing.Imaging.ImageFormat]::Png)
$samNeutral.Save("$samResourceDir/layers/$samFrame/$samLayer.png",[System.Drawing.Imaging.ImageFormat]::Png)
$samNeutral.Save((Join-Path $PSScriptRoot 'sSamNeutral.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$samResource = [System.IO.File]::ReadAllText((Join-Path $samRoot 'sprites/sSam/sSam.yy')).Replace('sSam','sSamNeutral').Replace('6153a636-1f65-4c9a-992c-01b0184f5665',$samFrame).Replace('8ee74136-cd15-4ca8-a1fe-04af37b79bdb',$samLayer).Replace('cf97e851-01be-40df-8be5-bb396d93b0f2',$samKey).Replace('"bbox_left":8','"bbox_left":12').Replace('"bbox_right":44','"bbox_right":40')
[System.IO.File]::WriteAllText("$samResourceDir/sSamNeutral.yy",$samResource,[System.Text.UTF8Encoding]::new($false))
$samPreview = [System.Drawing.Bitmap]::new(1088,768,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($y=0; $y -lt 768; $y++) {
    for ($x=0; $x -lt 512; $x++) {
        $sx=[int][Math]::Floor($x/8); $sy=[int][Math]::Floor($y/8)
        $samPreview.SetPixel($x,$y,$samOriginal.GetPixel($sx,$sy))
        $samPreview.SetPixel(576+$x,$y,$samNeutral.GetPixel($sx,$sy))
    }
}
$samPreview.Save((Join-Path $PSScriptRoot 'sSamNeutral-comparison.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$samPreview.Dispose(); $samNeutral.Dispose(); $samOriginal.Dispose()
if ((Get-FileHash -LiteralPath $samOriginalPath).Hash -ne $samOriginalHash) { throw 'Original file changed.' }
Write-Output 'Created sSamNeutral: 64x96, original palette, head and torso pixel-identical; original unchanged.'
