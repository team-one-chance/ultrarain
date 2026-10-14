param([Parameter(Mandatory=$true)][string]$Source)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
function Read-GM($path){return ((Get-Content -Raw -LiteralPath $path) -replace ',(\s*[}\]])','$1' | ConvertFrom-Json)}
function Save-GM($path,$value){[System.IO.File]::WriteAllText($path,($value | ConvertTo-Json -Depth 100),[System.Text.UTF8Encoding]::new($false))}
$name='s_DamagedRobot';$dir=Join-Path $root "sprites/$name"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$m=Read-GM (Join-Path $root 'sprites/s_CrumpledRobot/s_CrumpledRobot.yy')
$existing=if(Test-Path (Join-Path $dir "$name.yy")){Read-GM (Join-Path $dir "$name.yy")}else{$null}
$m.name=$name;$m.'%Name'=$name;$m.sequence.name=$name;$m.sequence.'%Name'=$name
$layer=if($existing){$existing.layers[0].name}else{[guid]::NewGuid().ToString()}
$m.layers[0].name=$layer;$m.layers[0].'%Name'=$layer
Copy-Item -LiteralPath $Source -Destination (Join-Path $PSScriptRoot 'incoming-robots-source.png')
$sourceImage=[System.Drawing.Bitmap]::new($Source)
$cellWidth=[int]($sourceImage.Width/3);$cellHeight=[int]($sourceImage.Height/2)
$sizes=@(@(40,34),@(34,34),@(40,26),@(28,40),@(38,34),@(40,32))
$atlas=[System.Drawing.Bitmap]::new(288,48);$atlasGraphics=[System.Drawing.Graphics]::FromImage($atlas)
$frames=@();$keys=@()
for($i=0;$i -lt 6;$i++){
    $cell=[System.Drawing.Rectangle]::new(($i%3)*$cellWidth,[int][Math]::Floor($i/3)*$cellHeight,$cellWidth,$cellHeight)
    $left=$cell.Right;$top=$cell.Bottom;$right=$cell.X;$bottom=$cell.Y
    for($y=$cell.Y;$y -lt $cell.Bottom;$y++){for($x=$cell.X;$x -lt $cell.Right;$x++){
        if($sourceImage.GetPixel($x,$y).A -gt 127){$left=[Math]::Min($left,$x);$top=[Math]::Min($top,$y);$right=[Math]::Max($right,$x);$bottom=[Math]::Max($bottom,$y)}
    }}
    if($right -le $left -or $bottom -le $top){throw 'Empty incoming robot cell'}
    $bitmap=[System.Drawing.Bitmap]::new(48,48,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g=[System.Drawing.Graphics]::FromImage($bitmap)
    $g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor;$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $g.DrawImage($sourceImage,[System.Drawing.Rectangle]::new([int]((48-$sizes[$i][0])/2),[int]((48-$sizes[$i][1])/2),$sizes[$i][0],$sizes[$i][1]),$left,$top,$right-$left+1,$bottom-$top+1,[System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    for($y=0;$y -lt 48;$y++){for($x=0;$x -lt 48;$x++){
        $c=$bitmap.GetPixel($x,$y)
        if($c.A -gt 127){$bitmap.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$c.R,$c.G,$c.B))}else{$bitmap.SetPixel($x,$y,[System.Drawing.Color]::Transparent)}
    }}
    $id=if($existing){$existing.frames[$i].name}else{[guid]::NewGuid().ToString()}
    $path=Join-Path $dir "$id.png";$bitmap.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
    $layerDir=Join-Path $dir "layers/$id";New-Item -ItemType Directory -Force -Path $layerDir | Out-Null
    Copy-Item -LiteralPath $path -Destination (Join-Path $layerDir "$layer.png")
    $atlasGraphics.DrawImageUnscaled($bitmap,$i*48,0);$bitmap.Dispose()
    $frames+=@{'$GMSpriteFrame'='v1';'%Name'=$id;name=$id;resourceType='GMSpriteFrame';resourceVersion='2.0'}
    $key=($m.sequence.tracks[0].keyframes.Keyframes[$i] | ConvertTo-Json -Depth 30) | ConvertFrom-Json
    $key.id=[guid]::NewGuid().ToString();$key.Channels.'0'.Id.name=$id;$key.Channels.'0'.Id.path="sprites/$name/$name.yy"
    $keys+=$key
}
$sourceImage.Dispose();$atlasGraphics.Dispose()
$atlas.Save((Join-Path $PSScriptRoot 's_DamagedRobot-variants.png'),[System.Drawing.Imaging.ImageFormat]::Png);$atlas.Dispose()
$m.frames=$frames;$m.sequence.tracks[0].keyframes.Keyframes=$keys
Save-GM (Join-Path $dir "$name.yy") $m
$objectPath=Join-Path $root 'objects/o_FallingRobotScrap/o_FallingRobotScrap.yy'
$object=Read-GM $objectPath
if(!@($object.eventList | Where-Object {$_.eventType -eq 8 -and $_.eventNum -eq 0}).Count){
    $draw=($object.eventList[0] | ConvertTo-Json -Depth 10) | ConvertFrom-Json
    $draw.eventType=8;$draw.eventNum=0;$object.eventList=@($object.eventList)+@($draw)
    Save-GM $objectPath $object
}
$projectPath=Join-Path $root 'ULTRA RAIN.yyp';$project=Read-GM $projectPath
if($project.resources.id.name -notcontains $name){
    $raw=Get-Content -Raw -LiteralPath $projectPath
    $entry='{"id":{"name":"'+$name+'","path":"sprites/'+$name+'/'+$name+'.yy"}},'
    $raw=[regex]::Replace($raw,'(?m)^(  "resources"\s*:\s*\[)',('$1'+"`n    "+$entry),1)
    [System.IO.File]::WriteAllText($projectPath,$raw,[System.Text.UTF8Encoding]::new($false))
}
Write-Output 'Imported six matching incoming wrecks and registered the grinding Draw event.'
