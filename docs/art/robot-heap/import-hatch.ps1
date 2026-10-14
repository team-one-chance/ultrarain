param([Parameter(Mandatory=$true)][string]$Source)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
function Read-GM($path){return ((Get-Content -Raw -LiteralPath $path) -replace ',(\s*[}\]])','$1' | ConvertFrom-Json)}
function Save-GM($path,$value){[System.IO.File]::WriteAllText($path,($value | ConvertTo-Json -Depth 100),[System.Text.UTF8Encoding]::new($false))}
$name='s_RobotDropHatch';$dir=Join-Path $root "sprites/$name"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$m=Read-GM (Join-Path $root 'sprites/s_DamagedRobot/s_DamagedRobot.yy')
$existing=if(Test-Path (Join-Path $dir "$name.yy")){Read-GM (Join-Path $dir "$name.yy")}else{$null}
$m.name=$name;$m.'%Name'=$name;$m.width=96;$m.height=32;$m.origin=4
$m.bbox_left=0;$m.bbox_top=0;$m.bbox_right=95;$m.bbox_bottom=31
$m.sequence.name=$name;$m.sequence.'%Name'=$name;$m.sequence.length=2.0;$m.sequence.xorigin=48;$m.sequence.yorigin=16
$layer=if($existing){$existing.layers[0].name}else{[guid]::NewGuid().ToString()}
$m.layers[0].name=$layer;$m.layers[0].'%Name'=$layer
Copy-Item -LiteralPath $Source -Destination (Join-Path $PSScriptRoot 'hatch-parts-source.png')
$sourceImage=[System.Drawing.Bitmap]::new($Source);$cellWidth=[int]($sourceImage.Width/2)
$sizes=@(@(96,32),@(80,16))
$atlas=[System.Drawing.Bitmap]::new(192,32);$ag=[System.Drawing.Graphics]::FromImage($atlas)
$frames=@();$keys=@()
for($i=0;$i -lt 2;$i++){
    $left=($i+1)*$cellWidth;$top=$sourceImage.Height;$right=$i*$cellWidth;$bottom=0
    for($y=0;$y -lt $sourceImage.Height;$y++){for($x=$i*$cellWidth;$x -lt ($i+1)*$cellWidth;$x++){
        if($sourceImage.GetPixel($x,$y).A -gt 127){$left=[Math]::Min($left,$x);$top=[Math]::Min($top,$y);$right=[Math]::Max($right,$x);$bottom=[Math]::Max($bottom,$y)}
    }}
    if($right -le $left -or $bottom -le $top){throw 'Empty hatch part'}
    $bitmap=[System.Drawing.Bitmap]::new(96,32,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g=[System.Drawing.Graphics]::FromImage($bitmap);$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor;$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $g.DrawImage($sourceImage,[System.Drawing.Rectangle]::new([int]((96-$sizes[$i][0])/2),[int]((32-$sizes[$i][1])/2),$sizes[$i][0],$sizes[$i][1]),$left,$top,$right-$left+1,$bottom-$top+1,[System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    for($y=0;$y -lt 32;$y++){for($x=0;$x -lt 96;$x++){
        $c=$bitmap.GetPixel($x,$y)
        if($c.A -gt 127){$bitmap.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$c.R,$c.G,$c.B))}else{$bitmap.SetPixel($x,$y,[System.Drawing.Color]::Transparent)}
    }}
    $id=if($existing){$existing.frames[$i].name}else{[guid]::NewGuid().ToString()}
    $path=Join-Path $dir "$id.png";$bitmap.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
    $layerDir=Join-Path $dir "layers/$id";New-Item -ItemType Directory -Force -Path $layerDir | Out-Null
    Copy-Item -LiteralPath $path -Destination (Join-Path $layerDir "$layer.png")
    $ag.DrawImageUnscaled($bitmap,$i*96,0);$bitmap.Dispose()
    $frames+=@{'$GMSpriteFrame'='v1';'%Name'=$id;name=$id;resourceType='GMSpriteFrame';resourceVersion='2.0'}
    $key=($m.sequence.tracks[0].keyframes.Keyframes[$i] | ConvertTo-Json -Depth 30) | ConvertFrom-Json
    $key.id=[guid]::NewGuid().ToString();$key.Channels.'0'.Id.name=$id;$key.Channels.'0'.Id.path="sprites/$name/$name.yy"
    $keys+=$key
}
$sourceImage.Dispose();$ag.Dispose();$atlas.Save((Join-Path $PSScriptRoot 's_RobotDropHatch-parts.png'),[System.Drawing.Imaging.ImageFormat]::Png);$atlas.Dispose()
$m.frames=$frames;$m.sequence.tracks[0].keyframes.Keyframes=$keys;Save-GM (Join-Path $dir "$name.yy") $m
$object=Read-GM (Join-Path $root 'objects/o_RobotScrapEmitter/o_RobotScrapEmitter.yy')
$object.name='o_RobotDropHatch';$object.'%Name'=$object.name;$object.visible=$true
$draw=($object.eventList[0] | ConvertTo-Json -Depth 10) | ConvertFrom-Json
$draw.eventType=8;$draw.eventNum=0;$object.eventList=@($object.eventList)+@($draw)
Save-GM (Join-Path $root 'objects/o_RobotDropHatch/o_RobotDropHatch.yy') $object
$projectPath=Join-Path $root 'ULTRA RAIN.yyp';$project=Read-GM $projectPath;$entries=@()
foreach($resource in @(@{name='s_RobotDropHatch';kind='sprites'},@{name='o_RobotDropHatch';kind='objects'})){
    if($project.resources.id.name -notcontains $resource.name){$entries+=('{"id":{"name":"'+$resource.name+'","path":"'+$resource.kind+'/'+$resource.name+'/'+$resource.name+'.yy"}},')}
}
if($entries.Count){
    $raw=Get-Content -Raw -LiteralPath $projectPath
    $raw=[regex]::Replace($raw,'(?m)^(  "resources"\s*:\s*\[)',('$1'+"`n    "+($entries -join "`n    ")),1)
    [System.IO.File]::WriteAllText($projectPath,$raw,[System.Text.UTF8Encoding]::new($false))
}
Write-Output 'Imported hatch frame/shutters and registered the temporary drop hatch.'
