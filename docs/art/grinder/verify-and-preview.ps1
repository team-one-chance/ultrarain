$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'MeshingGear.cs') -ReferencedAssemblies System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$roomPath = Join-Path $root 'rooms/LE_TUTORIAL_WIP/LE_TUTORIAL_WIP.yy'
$room = (Get-Content -Raw -LiteralPath $roomPath) -replace ',(\s*[}\]])','$1' | ConvertFrom-Json
$gears = @($room.layers | ForEach-Object {$_.instances} | Where-Object {$_.objectId.name -match '^o_Grinder(Left|Right)$'} | Sort-Object x)
if($gears.Count -ne 10){throw 'Expected ten tutorial grinders'}
for($i=0;$i -lt 10;$i++){
    if([Math]::Abs($gears[$i].x-(4384+$i*224/3)) -gt 0.0001){throw 'Incorrect pitch'}
    $expected = if($i%2 -eq 0){'o_GrinderLeft'}else{'o_GrinderRight'}
    if($gears[$i].objectId.name -ne $expected -or $gears[$i].y -ne 816){throw 'Incorrect direction or height'}
}
if([Math]::Abs($gears[9].x+96-$gears[0].x-768) -gt 0.0001){throw 'Incorrect span'}
$maxOverlap = 0
for($angle=0;$angle -lt 45;$angle+=0.5){$maxOverlap=[Math]::Max($maxOverlap,[MeshingGear]::Overlap($angle))}
if($maxOverlap -ne 0){throw 'Gear teeth intersect during rotation'}
$strip = [System.Drawing.Bitmap]::new(96*72,192)
$g = [System.Drawing.Graphics]::FromImage($strip)
for($row=0;$row -lt 2;$row++){
    $name=if($row -eq 0){'s_GrinderLeft'}else{'s_GrinderRight'}
    $dir=Join-Path $root "sprites/$name"
    $meta=(Get-Content -Raw -LiteralPath (Join-Path $dir "$name.yy")) -replace ',(\s*[}\]])','$1' | ConvertFrom-Json
    if($meta.width -ne 96 -or $meta.height -ne 96 -or $meta.frames.Count -ne 72){throw 'Wrong sprite dimensions or length'}
    $keyframes=$meta.sequence.tracks[0].keyframes.Keyframes
    if($keyframes.Count -ne 72){throw 'Wrong keyframe count'}
    for($i=0;$i -lt 72;$i++){
        $id=$meta.frames[$i].name
        if($keyframes[$i].Channels.'0'.Id.name -ne $id -or $keyframes[$i].Channels.'0'.Id.path -ne "sprites/$name/$name.yy"){throw 'Broken animation reference'}
        $path=Join-Path $dir "$id.png"
        $layer=Join-Path $dir "layers/$id/$($meta.layers[0].name).png"
        $b=[System.Drawing.Bitmap]::new($path)
        $layerBitmap=[System.Drawing.Bitmap]::new($layer)
        for($py=0;$py -lt 96;$py++){for($px=0;$px -lt 96;$px++){
            $a=$b.GetPixel($px,$py);$c=$layerBitmap.GetPixel($px,$py)
            if($a.A -ne $c.A -or ($a.A -gt 0 -and $a.ToArgb() -ne $c.ToArgb())){throw "Frame/layer pixels differ: $name frame $i"}
        }}
        $layerBitmap.Dispose()
        if($b.Width -ne 96 -or $b.Height -ne 96){throw 'Wrong frame dimensions'}
        for($p=0;$p -lt 96;$p++){
            if($b.GetPixel(0,$p).A -gt 0 -or $b.GetPixel(95,$p).A -gt 0 -or $b.GetPixel($p,0).A -gt 0 -or $b.GetPixel($p,95).A -gt 0){throw 'Missing outer clearance'}
        }
        $g.DrawImageUnscaled($b,$i*96,$row*96);$b.Dispose()
    }
}
$g.Dispose()
$stream=[System.IO.MemoryStream]::new()
$strip.Save($stream,[System.Drawing.Imaging.ImageFormat]::Png)
$data=[Convert]::ToBase64String($stream.ToArray())
$stream.Dispose();$strip.Dispose()
$positions=(@($gears | ForEach-Object {@{x=($_.x-4384);direction=if($_.objectId.name -eq 'o_GrinderLeft'){0}else{1}}}) | ConvertTo-Json -Compress)
$html=@"
<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tutorial grinder preview</title><style>
body{margin:0;background:#181a1d;color:#eee;font:16px system-ui;display:grid;place-content:center;min-height:100vh;gap:20px}
canvas{width:min(95vw,1536px);height:auto;image-rendering:pixelated;background:#181a1d}
p{margin:0;text-align:center;color:#bfc2c6}button{font:inherit;padding:8px 16px;justify-self:center}
</style><canvas id="view" width="768" height="128"></canvas><p>10 gears · 96×96 · 768-pixel span · alternating rotation</p><button id="toggle">Pause</button>
<script>
const positions=$positions, sheet=new Image(), canvas=document.querySelector('canvas'), ctx=canvas.getContext('2d');
ctx.imageSmoothingEnabled=false;let playing=true, time=0, last=0;
sheet.src='data:image/png;base64,$data';
document.querySelector('button').onclick=()=>{playing=!playing;document.querySelector('button').textContent=playing?'Pause':'Play'};
function tick(now){if(last&&playing)time+=(now-last)/1000;last=now;
const frame=Math.floor(time*24)%72;ctx.clearRect(0,0,768,128);
if(sheet.complete)for(const gear of positions)ctx.drawImage(sheet,frame*96,gear.direction*96,96,96,gear.x,16,96,96);
requestAnimationFrame(tick)}requestAnimationFrame(tick);
</script></html>
"@
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot 'meshing-preview.html'),$html,[System.Text.UTF8Encoding]::new($false))
Write-Output 'Verified ten tutorial placements, 768-pixel span, all 144 frames/layers, animation references and outer clearance. No geometric intersections at 90 sampled angles. Saved animated preview.'
