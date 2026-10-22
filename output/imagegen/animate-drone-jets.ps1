$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$workspace = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$spriteName = 'sDroneJetAnimated'
$spriteDir = Join-Path $workspace "sprites/$spriteName"
$existingPath = Join-Path $spriteDir "$spriteName.yy"
$existing = if (Test-Path -LiteralPath $existingPath) {
    ([System.IO.File]::ReadAllText($existingPath) -replace ',\s*([}\]])', '$1') | ConvertFrom-Json
} else { $null }
$templatePath = Join-Path $workspace 'sprites/sDrone1Frame2Shaded/sDrone1Frame2Shaded.yy'
$templateText = [System.IO.File]::ReadAllText($templatePath)
$template = ($templateText -replace ',\s*([}\]])', '$1') | ConvertFrom-Json
$sourcePath = Join-Path $workspace "sprites/sDrone1Frame2Shaded/$($template.frames[0].name).png"
$source = [System.Drawing.Bitmap]::FromFile($sourcePath)
$sourceHash = (Get-FileHash -LiteralPath $sourcePath).Hash
$frameCount = 32
$fps = 50
$referenceMeta = ([System.IO.File]::ReadAllText((Join-Path $workspace 'sprites/sDrone_1/sDrone_1.yy')) -replace ',\s*([}\]])','$1') | ConvertFrom-Json
$referencePaths = @()
$referenceHashes = @()
$referenceBounds = @()
for ($pose=3; $pose -le 11; $pose++) {
    $path = Join-Path $workspace "sprites/sDrone_1/$($referenceMeta.frames[$pose].name).png"
    $referencePaths += $path
    $referenceHashes += (Get-FileHash -LiteralPath $path).Hash
    $reference = [System.Drawing.Bitmap]::FromFile($path)
    $sides = @()
    foreach ($referenceCenter in @(6,41)) {
        $bounds = New-Object 'int[]' 6
        for ($y=9; $y -lt 32; $y++) {
            $radius = -1
            for ($x=($referenceCenter-5); $x -le ($referenceCenter+5); $x++) {
                $p = $reference.GetPixel($x,$y)
                if ($p.A -gt 0 -and $p.R -gt (2*$p.G+20)) {
                    $radius = [Math]::Max($radius,[Math]::Abs($x-$referenceCenter))
                }
            }
            for ($r=0; $r -le $radius; $r++) { $bounds[$r] = $y-8 }
        }
        $sides += ,$bounds
    }
    $referenceBounds += ,$sides
    $reference.Dispose()
}
$layerId = if ($existing) { $existing.layers[0].name } else { [guid]::NewGuid().ToString() }
$frameIds = @()
$keyIds = @()
$framePaths = @()
$sheet = New-Object System.Drawing.Bitmap (48 * $frameCount),32
$sheetG = [System.Drawing.Graphics]::FromImage($sheet)
$sheetG.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
New-Item -ItemType Directory -Path $spriteDir -Force | Out-Null

for ($frameIndex = 0; $frameIndex -lt $frameCount; $frameIndex++) {
    $frame = New-Object System.Drawing.Bitmap 48,32
    # Copy the approved artwork exactly, removing only the old flame pixels.
    for ($y = 0; $y -lt 32; $y++) {
        for ($x = 0; $x -lt 48; $x++) {
            $pixel = $source.GetPixel($x,$y)
            $isFire = $y -ge 9 -and ($x -le 12 -or $x -ge 36) -and
                $pixel.A -gt 0 -and $pixel.R -gt ([Math]::Max($pixel.G,$pixel.B) + 20)
            if (-not $isFire) { $frame.SetPixel($x,$y,$pixel) }
        }
    }
    $pose = [int][Math]::Floor($frameIndex/4)
    $blend = ($frameIndex%4)/4.0
    $phase = 2*[Math]::PI*$frameIndex/$frameCount
    for ($side = 0; $side -lt 2; $side++) {
        $center = if ($side -eq 0) { 7 } else { 41 }
        $bounds = New-Object 'int[]' 6
        for ($r=0; $r -le 5; $r++) {
            $a = $referenceBounds[$pose][$side][$r]
            $b = $referenceBounds[($pose+1)][$side][$r]
            $bounds[$r] = [int][Math]::Floor($a+($b-$a)*$blend+0.5)
        }
        $length = $bounds[0]
        for ($depth = 0; $depth -lt $length; $depth++) {
            $y = 9 + $depth
            $radius = 0
            for ($r=1; $r -le 5; $r++) {
                if ($depth -lt $bounds[$r]) { $radius = $r }
            }
            $minX = $center-$radius
            $maxX = $center+$radius
            # Exact original silhouettes on every fourth frame. In between,
            # one-pixel tip variations are confined to the last two rows.
            $flicker = $frameIndex%4 -ne 0 -and [Math]::Sin($phase*2+$side*1.4) -gt 0.8
            if ($flicker -and $depth -eq ($length-1)) {
                $direction = if ($side -eq 0) { 1 } else { -1 }
                $minX += $direction
                $maxX += $direction
            }
            for ($x = $minX; $x -le $maxX; $x++) {
                # Keep the approved shading fixed above the lower tips.
                $sampleX = [Math]::Max(($center-$radius),[Math]::Min(($center+$radius),$x))
                $color = $source.GetPixel($sampleX,$y)
                if ($flicker -and $depth -eq ($length-2) -and $x -eq $center -and $color.R -le 127) {
                    $color = [System.Drawing.ColorTranslator]::FromHtml('#9e0b0f')
                }
                $frame.SetPixel($x,$y,$color)
            }
        }
    }
    $reuse = $existing -and $frameIndex -lt $existing.frames.Count
    $frameId = if ($reuse) { $existing.frames[$frameIndex].name } else { [guid]::NewGuid().ToString() }
    $frameIds += $frameId
    $keyIds += if ($reuse) { $existing.sequence.tracks[0].keyframes.Keyframes[$frameIndex].id } else { [guid]::NewGuid().ToString() }
    $layerDir = Join-Path $spriteDir "layers/$frameId"
    New-Item -ItemType Directory -Path $layerDir -Force | Out-Null
    $framePath = Join-Path $spriteDir "$frameId.png"
    $frame.Save($framePath)
    $frame.Save((Join-Path $layerDir "$layerId.png"))
    $framePaths += $framePath
    $sheetG.DrawImage($frame,($frameIndex*48),0,48,32)
    $frame.Dispose()
}
$source.Dispose()
$sheetG.Dispose()
$sheet.Save((Join-Path $PSScriptRoot 'sdrone-jet-animation-strip.png'))
$preview = New-Object System.Drawing.Bitmap 1536,512
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(65,65,70))
$pg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$pg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
for ($i=0; $i -lt $frameCount; $i++) {
    $srcRect = New-Object System.Drawing.Rectangle ($i*48),0,48,32
    $dstRect = New-Object System.Drawing.Rectangle (($i%8)*192),([int][Math]::Floor($i/8)*128),192,128
    $pg.DrawImage($sheet,$dstRect,$srcRect,[System.Drawing.GraphicsUnit]::Pixel)
}
$preview.Save((Join-Path $PSScriptRoot 'sdrone-jet-animation-contact.png'))
$pg.Dispose()
$preview.Dispose()
$sheet.Dispose()

# Keep the existing GameMaker metadata format and stable collision bounds.
$frameLines = @()
$keyLines = @()
for ($i=0; $i -lt $frameCount; $i++) {
    $id = $frameIds[$i]
    $frameLines += '    {"$GMSpriteFrame":"v1","%Name":"'+$id+'","name":"'+$id+'","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},'
    $keyLines += '            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{"0":{"$SpriteFrameKeyframe":"","Id":{"name":"'+$id+'","path":"sprites/'+$spriteName+'/'+$spriteName+'.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},},"Disabled":false,"id":"'+$keyIds[$i]+'","IsCreationKey":false,"Key":'+$i+'.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},'
}
$metadata = $templateText.Replace('sDrone1Frame2Shaded',$spriteName).Replace($template.layers[0].name,$layerId)
$metadata = [regex]::Replace($metadata,'(?s)("frames":\[).*?(\r?\n  \],)',{param($m) $m.Groups[1].Value+"`r`n"+($frameLines -join "`r`n")+$m.Groups[2].Value},1)
$metadata = [regex]::Replace($metadata,'(?s)("keyframes":\{[^\[]*"Keyframes":\[).*?(\r?\n          \],)',{param($m) $m.Groups[1].Value+"`r`n"+($keyLines -join "`r`n")+$m.Groups[2].Value},1)
$metadata = $metadata.Replace('"length":1.0',('"length":'+$frameCount+'.0')).Replace('"playbackSpeed":30.0',('"playbackSpeed":'+$fps.ToString([System.Globalization.CultureInfo]::InvariantCulture)))
[System.IO.File]::WriteAllText((Join-Path $spriteDir "$spriteName.yy"),$metadata)
@{ sprite=$spriteName; frames=$framePaths; fps=$fps; source=$sourcePath; sourceHash=$sourceHash; referenceFrames=$referencePaths; referenceHashes=$referenceHashes; subframes=4 } |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'sdrone-jet-animation-manifest.json') -Encoding UTF8
Write-Output "Created $frameCount frames for $spriteName at $fps fps."
