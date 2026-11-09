param(
    [ValidateSet('s_GrinderRight','s_GrinderLeft')][string]$SpriteName = 's_GrinderRight',
    [ValidateSet(1,-1)][int]$Direction = 1
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'MeshingGear.cs') -ReferencedAssemblies System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$spriteDir = Join-Path $root "sprites/$SpriteName"
$metaPath = Join-Path $spriteDir "$SpriteName.yy"
$meta = (Get-Content -Raw -LiteralPath $metaPath) -replace ',(\s*[}\]])', '$1' | ConvertFrom-Json
$layerId = $meta.layers[0].name
$source = [System.Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'gear-64-source.png'))
$frames = @(); $keys = @()
$sheet = [System.Drawing.Bitmap]::new(96*12,96*6)
$graphics = [System.Drawing.Graphics]::FromImage($sheet)
$phase = if($Direction -eq 1){22.5}else{0.0}
for($i=0;$i -lt 72;$i++) {
    $id = $meta.frames[$i].name
    $bitmap = [MeshingGear]::Frame(($phase+$Direction*$i*5),$source)
    $path = Join-Path $spriteDir "$id.png"
    $bitmap.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
    $layerDir = Join-Path $spriteDir "layers/$id"
    New-Item -ItemType Directory -Force -Path $layerDir | Out-Null
    Copy-Item -LiteralPath $path -Destination (Join-Path $layerDir "$layerId.png")
    $graphics.DrawImageUnscaled($bitmap,($i%12)*96,[int][Math]::Floor($i/12)*96)
    $bitmap.Dispose()
    $frames += [ordered]@{'$GMSpriteFrame'='v1';'%Name'=$id;name=$id;resourceType='GMSpriteFrame';resourceVersion='2.0'}
    $keys += [ordered]@{'$Keyframe<SpriteFrameKeyframe>'='';Channels=@{'0'=@{'$SpriteFrameKeyframe'='';Id=@{name=$id;path="sprites/$SpriteName/$SpriteName.yy"};resourceType='SpriteFrameKeyframe';resourceVersion='2.0'}};Disabled=$false;id=$meta.sequence.tracks[0].keyframes.Keyframes[$i].id;IsCreationKey=$false;Key=[double]$i;Length=1.0;resourceType='Keyframe<SpriteFrameKeyframe>';resourceVersion='2.0';Stretch=$false}
}
$graphics.Dispose()
$sheet.Save((Join-Path $PSScriptRoot "$SpriteName-contact-sheet.png"),[System.Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose(); $source.Dispose()
$meta.frames=$frames
$meta.width=96; $meta.height=96
$meta.sequence.length=72.0; $meta.sequence.playbackSpeed=24.0
$meta.sequence.tracks[0].keyframes.Keyframes=$keys
$meta.bbox_left=1; $meta.bbox_top=1; $meta.bbox_right=94; $meta.bbox_bottom=94
[System.IO.File]::WriteAllText($metaPath,($meta | ConvertTo-Json -Depth 100),[System.Text.UTF8Encoding]::new($false))
Write-Output "Updated ${SpriteName}: 96x96, 8 meshing teeth, 72 frames, phase $phase degrees."
