$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$workspace = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$manifest = Get-Content (Join-Path $PSScriptRoot 'sdrone-jet-animation-manifest.json') -Raw | ConvertFrom-Json
$spriteDir = Join-Path $workspace 'sprites/sDroneJetAnimated'
$sprite = ([System.IO.File]::ReadAllText((Join-Path $spriteDir 'sDroneJetAnimated.yy')) -replace ',\s*([}\]])','$1') | ConvertFrom-Json
$keys = $sprite.sequence.tracks[0].keyframes.Keyframes
$frameCount = $manifest.frames.Count
if ($frameCount -ne 32 -or $sprite.frames.Count -ne $frameCount -or $keys.Count -ne $frameCount -or
    $sprite.sequence.length -ne $frameCount -or $sprite.sequence.playbackSpeed -ne $manifest.fps -or
    $sprite.width -ne 48 -or $sprite.height -ne 32 -or
    $sprite.bbox_right -ne 47 -or $sprite.bbox_bottom -ne 31) { throw 'Invalid metadata' }
if ((Get-FileHash -LiteralPath $manifest.source).Hash -ne $manifest.sourceHash) { throw 'Source changed' }
$source = [System.Drawing.Bitmap]::FromFile($manifest.source)
$allowed = @{}
for ($y=0; $y -lt 32; $y++) { for ($x=0; $x -lt 48; $x++) {
    $pixel = $source.GetPixel($x,$y)
    if ($pixel.A -gt 0) { $allowed[$pixel.ToArgb()] = $true }
} }
$gif = [System.Drawing.Bitmap]::FromFile((Join-Path $PSScriptRoot 'sdrone-jet-animation-native.gif'))
$dimension = New-Object System.Drawing.Imaging.FrameDimension ($gif.FrameDimensionsList[0])
if ($gif.GetFrameCount($dimension) -ne $frameCount) { throw 'GIF frame count mismatch' }
$hashes = @{}
$lengths = @()
$maxRecolored = 0
for ($refIndex=0; $refIndex -lt $manifest.referenceFrames.Count; $refIndex++) {
    if ((Get-FileHash -LiteralPath $manifest.referenceFrames[$refIndex]).Hash -ne $manifest.referenceHashes[$refIndex]) {
        throw 'Original reference animation changed'
    }
}
for ($index=0; $index -lt $frameCount; $index++) {
    $id = $sprite.frames[$index].name
    if ($keys[$index].Key -ne $index -or $keys[$index].Channels.'0'.Id.name -ne $id -or
        $keys[$index].Channels.'0'.Id.path -ne 'sprites/sDroneJetAnimated/sDroneJetAnimated.yy') { throw 'Invalid frame reference' }
    $framePath = Join-Path $spriteDir "$id.png"
    $layerPath = Join-Path $spriteDir "layers/$id/$($sprite.layers[0].name).png"
    $hash = (Get-FileHash -LiteralPath $framePath).Hash
    if ($hash -ne (Get-FileHash -LiteralPath $layerPath).Hash) { throw 'Frame/layer mismatch' }
    $hashes[$hash] = $true
    $frame = [System.Drawing.Bitmap]::FromFile($framePath)
    if ($frame.Width -ne 48 -or $frame.Height -ne 32) { throw 'Frame dimensions changed' }
    $null = $gif.SelectActiveFrame($dimension,$index)
    $bottom = @(-1,-1)
    for ($y=9; $y -lt 32; $y++) { for ($x=0; $x -lt 48; $x++) {
        if (($x -le 12 -or $x -ge 36) -and $frame.GetPixel($x,$y).A -gt 0) {
            $side = if ($x -le 12) { 0 } else { 1 }
            $bottom[$side] = [Math]::Max($bottom[$side],$y)
        }
    } }
    $lengths += ,$bottom
    $recolored = 0
    $reference = if ($index%4 -eq 0) {
        [System.Drawing.Bitmap]::FromFile($manifest.referenceFrames[[int]($index/4)])
    } else { $null }
    for ($y=0; $y -lt 32; $y++) { for ($x=0; $x -lt 48; $x++) {
        $p = $frame.GetPixel($x,$y)
        $original = $source.GetPixel($x,$y)
        $sideRegion = $y -ge 9 -and ($x -le 12 -or $x -ge 36)
        if (-not $sideRegion -and $p.ToArgb() -ne $original.ToArgb()) { throw "Body/eyes changed in frame $index" }
        if ($p.A -ne 0 -and $p.A -ne 255) { throw 'Partial alpha introduced' }
        if ($p.A -gt 0 -and -not $allowed.ContainsKey($p.ToArgb())) { throw 'Palette changed' }
        if ($p.A -gt 0 -and $p.ToArgb() -ne $original.ToArgb()) {
            $side = if ($x -le 12) { 0 } else { 1 }
            if (-not $sideRegion -or $y -lt ($bottom[$side]-1)) { throw 'Flicker escaped the lowest two rows' }
            $recolored++
        }
        if ($sideRegion -and $p.A -gt 0 -and $p.R -le ([Math]::Max($p.G,$p.B)+20)) { throw 'Non-flame side pixel' }
        if ($reference -and $sideRegion) {
            $expectedFire = $false
            if ($x -ge 1) {
                $referenceX = if ($x -le 12) { $x-1 } else { $x }
                $r = $reference.GetPixel($referenceX,$y)
                $expectedFire = $r.A -gt 0 -and $r.R -gt (2*$r.G+20)
            }
            if (($p.A -gt 0) -ne $expectedFire) { throw "Original pose silhouette mismatch in frame $index" }
        }
        $expected = if ($p.A -eq 0) { [System.Drawing.Color]::FromArgb(65,65,70) } else { $p }
        if ($gif.GetPixel($x,$y).ToArgb() -ne $expected.ToArgb()) { throw "GIF decode mismatch in frame $index" }
    } }
    if ($reference) { $reference.Dispose() }
    $maxRecolored = [Math]::Max($maxRecolored,$recolored)
    if ($recolored -gt 2) { throw 'Too much color flicker' }
    foreach ($center in @(7,41)) {
        $visited = @{}
        $queue = New-Object 'System.Collections.Generic.Queue[System.Drawing.Point]'
        for ($x=($center-5); $x -le ($center+5); $x++) {
            if ($frame.GetPixel($x,9).A -gt 0) {
                $queue.Enqueue((New-Object System.Drawing.Point $x,9))
                $visited["$x,9"] = $true
            }
        }
        while ($queue.Count -gt 0) {
            $point = $queue.Dequeue()
            for ($dy=-1; $dy -le 1; $dy++) { for ($dx=-1; $dx -le 1; $dx++) {
                $nx=$point.X+$dx; $ny=$point.Y+$dy
                if ($nx -lt ($center-5) -or $nx -gt ($center+5) -or $ny -lt 9 -or $ny -ge 32 -or $visited.ContainsKey("$nx,$ny")) { continue }
                if ($frame.GetPixel($nx,$ny).A -gt 0) {
                    $visited["$nx,$ny"] = $true
                    $queue.Enqueue((New-Object System.Drawing.Point $nx,$ny))
                }
            } }
        }
        for ($y=9; $y -lt 32; $y++) { for ($x=($center-5); $x -le ($center+5); $x++) {
            if ($frame.GetPixel($x,$y).A -gt 0 -and -not $visited.ContainsKey("$x,$y")) { throw "Detached flame pixel in frame $index at $x,$y" }
        } }
    }
    $frame.Dispose()
}
$gif.Dispose()
$source.Dispose()
if ($hashes.Count -lt 16) { throw 'Animation has too few distinct states' }
$maxLengthStep = 0
for ($i=0; $i -lt $frameCount; $i++) {
    foreach ($side in @(0,1)) {
        $step = [Math]::Abs($lengths[$i][$side]-$lengths[(($i+1)%$frameCount)][$side])
        $maxLengthStep = [Math]::Max($maxLengthStep,$step)
    }
}
if ($maxLengthStep -gt 1) { throw 'Abrupt length transition' }
Write-Output "Validated $frameCount frames ($($hashes.Count) distinct): exact original key-pose silhouettes, fixed body/eyes/palette, at most $maxRecolored flickering pixels at the tips, maximum $maxLengthStep pixel length step, connected jets, matching layers, and lossless GIF decoding."
