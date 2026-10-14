$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
Add-Type -AssemblyName System.Drawing
function Read-GM($path){return ((Get-Content -Raw -LiteralPath $path) -replace ',(\s*[}\]])','$1' | ConvertFrom-Json)}
function Data-Image($path){return 'data:image/png;base64,'+[Convert]::ToBase64String([System.IO.File]::ReadAllBytes($path))}
$incoming=Data-Image (Join-Path $PSScriptRoot 's_DamagedRobot-variants.png')
$outgoing=Data-Image (Join-Path $PSScriptRoot 's_CrumpledRobot-variants.png')
$hatch=Data-Image (Join-Path $PSScriptRoot 's_RobotDropHatch-parts.png')
$sheet=[System.Drawing.Bitmap]::new(6912,192);$g=[System.Drawing.Graphics]::FromImage($sheet)
for($row=0;$row -lt 2;$row++){
    $name=if($row -eq 0){'s_GrinderLeft'}else{'s_GrinderRight'}
    $meta=Read-GM (Join-Path $root "sprites/$name/$name.yy")
    for($i=0;$i -lt 72;$i++){
        $bitmap=[System.Drawing.Bitmap]::new((Join-Path $root "sprites/$name/$($meta.frames[$i].name).png"))
        $g.DrawImageUnscaled($bitmap,$i*96,$row*96);$bitmap.Dispose()
    }
}
$g.Dispose();$stream=[System.IO.MemoryStream]::new();$sheet.Save($stream,[System.Drawing.Imaging.ImageFormat]::Png)
$gears='data:image/png;base64,'+[Convert]::ToBase64String($stream.ToArray());$stream.Dispose();$sheet.Dispose()
$room=Read-GM (Join-Path $root 'rooms/LE_TUTORIAL_WIP/LE_TUTORIAL_WIP.yy')
$positions=@($room.layers | ForEach-Object {$_.instances} | Where-Object {$_.objectId.name -match '^o_Grinder(Left|Right)$'} | Sort-Object x | ForEach-Object {@{x=$_.x-4384;y=$_.y-480;row=if($_.objectId.name -eq 'o_GrinderLeft'){0}else{1}}}) | ConvertTo-Json -Compress
$flow=[System.IO.File]::ReadAllText((Join-Path $root 'objects/o_RobotScrapEmitter/Create_0.gml'))
function Flow-Value($name){$match=[regex]::Match($flow,('(?m)^'+$name+'\s*=\s*([\d.]+)\s*;'));if(!$match.Success){throw "Missing flow setting $name"};return [double]::Parse($match.Groups[1].Value,[System.Globalization.CultureInfo]::InvariantCulture)}
$gearInstances=@($room.layers | ForEach-Object {$_.instances} | Where-Object {$_.objectId.name -match '^o_Grinder(Left|Right)$'})
$config=@{minX=($gearInstances | Measure-Object x -Minimum).Minimum+32-4384;maxX=($gearInstances | Measure-Object x -Maximum).Maximum+96-32-4384;minY=(Flow-Value 'drop_min_y')-480;maxY=(Flow-Value 'drop_max_y')-480;interval=(Flow-Value 'drop_interval');maxBodies=(Flow-Value 'max_falling_bodies');groundY=(Flow-Value 'ground_y')-480} | ConvertTo-Json -Compress
$html=@"
<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Robot grinder flow</title><style>
*{box-sizing:border-box}body{margin:0;padding:24px;background:#17191c;color:#e4e4e4;font:15px system-ui}main{display:flex;gap:24px;justify-content:center}canvas{background:#202328;image-rendering:pixelated;max-width:100%}#full{height:88vh;width:auto}.detail{width:768px;max-width:70vw}#top,#ground{width:100%;height:auto}p{line-height:1.5}button{padding:10px 18px;background:#383d44;color:white;border:0;border-radius:4px;font:inherit}@media(max-width:700px){main{flex-direction:column}.detail{max-width:100%;width:100%}#full{height:55vh}}
</style><main><canvas id="full" width="768" height="2176" aria-label="Full fall from grinder to ground"></canvas><div class="detail"><canvas id="top" width="768" height="560" aria-label="Incoming robots and grinding effect"></canvas><p>Metal hatch &rarr; damaged robot &rarr; grinder flecks &rarr; crushed robot &rarr; ground.</p><canvas id="ground" width="768" height="176" aria-label="Scrap sinks into ground before fading"></canvas><p>Incoming robots can hit the player; crushed scrap is harmless.<br>A quick-opening hatch appears at each random drop point. Bodies sink 32 pixels before disappearing.</p><button id="pause">Pause</button> <label><input id="danger" type="checkbox"> Show dangerous bodies</label></div></main><script>
const incoming=new Image(),outgoing=new Image(),gears=new Image(),hatchImage=new Image();incoming.src='$incoming';outgoing.src='$outgoing';gears.src='$gears';hatchImage.src='$hatch';
const config=$config;
const positions=$positions,contexts=['full','top','ground'].map(id=>document.getElementById(id).getContext('2d'));
let bodies=[],hatches=[],timer=.1,time=0,last=0,paused=false;const random=(a,b)=>a+Math.random()*(b-a),groundY=config.groundY;
document.getElementById('pause').onclick=()=>{paused=!paused;document.getElementById('pause').textContent=paused?'Resume':'Pause'};
function spawn(h){const size=random(1.15,1.25),x=h.x,y=h.lip-24*size,gear=positions.reduce((best,g)=>Math.abs(g.x+48-x)<Math.abs(best.x+48-x)?g:best),b={x,y,size,releaseY:h.lip,releaseAngle:random(-25,25),emerged:false,grindTop:gear.y,grindBottom:gear.y+96,grindCenter:gear.y+48,flip:Math.random()<.5?-1:1,variant:Math.floor(random(0,6)),angle:0,spin:random(-60,60),vx:random(-8,8),vy:random(90,140),state:0,stage:0,age:0,alpha:1,sx:1,sy:1,sparks:[]};bodies.push(b);h.body=b}
function step(dt){time+=dt;timer-=dt;if(timer<=0){timer=config.interval+random(-.04,.04);const batch=Math.random()<1/3?2:1;for(let i=0;i<batch&&bodies.length+hatches.length<config.maxBodies;i++){const x=random(config.minX,config.maxX),y=random(config.minY,config.maxY);hatches.push({x,y,lip:y+10,age:0,stage:0,stageTime:0,open:0,alpha:0,body:null})}}
for(const h of hatches){h.age+=dt;h.stageTime+=dt;if(h.age>1){h.dead=true;continue}if(h.stage===0){h.alpha=Math.min(1,h.age/.04);h.open=Math.min(1,h.stageTime/.09);if(h.open>=1){if(bodies.length<config.maxBodies)spawn(h);h.stage=1;h.stageTime=0}}else if(h.stage===1){if(!h.body||h.body.dead||h.body.y-24*h.body.size>=h.lip+2||h.stageTime>=.5){h.stage=2;h.stageTime=0}}else if(h.stage===2){h.open=1-Math.min(1,h.stageTime/.09);if(h.open<=0){h.stage=3;h.stageTime=0}}else{h.alpha=1-Math.min(1,h.stageTime/.05);if(h.alpha<=0)h.dead=true}}
for(const b of bodies){b.age+=dt;const radius=21*b.size;for(const p of b.sparks){p.life-=dt;p.x+=p.vx*dt;p.y+=p.vy*dt;p.vy+=360*dt}
if(b.state===0){b.x+=b.vx*dt;b.y+=b.vy*dt+.5*780*dt*dt;b.vy+=780*dt;if(!b.emerged&&b.y-24*b.size>=b.releaseY){b.emerged=true;b.angle=b.releaseAngle}if(b.emerged)b.angle+=b.spin*dt;if(b.y+radius>=b.grindTop+6){b.y=b.grindTop+6-radius;b.entry=b.y;b.stage=0;b.state=1;for(let i=0;i<9;i++)b.sparks.push({x:b.x+random(-6,6),y:b.grindTop+6,vx:random(-125,125),vy:random(-150,-30),life:random(.18,.34),color:['#bfd2de','#6d8da3','#9d3d4d'][Math.floor(random(0,3))]})}}
else if(b.state===1){b.stage+=dt;const progress=Math.min(1,b.stage/.3);b.y=b.entry+(b.grindCenter-b.entry)*progress;b.angle+=260*dt;b.sx=1-.6*progress;b.sy=1-.85*progress;b.alpha=1-progress;if(progress>=1){b.y=b.grindBottom+radius+4;b.vy=random(170,230);b.spin=random(-160,160);b.angle=random(0,360);b.sx=b.sy=b.alpha=1;b.stage=0;b.state=2}}
else if(b.state===2){b.x+=b.vx*dt;b.y+=b.vy*dt+.5*780*dt*dt;b.vy+=780*dt;b.angle+=b.spin*dt;if(b.y+radius>=groundY){b.y=groundY-radius;b.entry=b.y;b.stage=0;b.state=3}}
else {b.stage+=dt;const progress=Math.min(1,b.stage/.42);b.y=b.entry+32*progress;b.alpha=1-Math.max(0,Math.min(1,(progress-.35)/.65));if(progress>=1)b.dead=true}}
bodies=bodies.filter(b=>!b.dead&&b.age<=12);hatches=hatches.filter(h=>!h.dead)}
function render(ctx,cameraY,height){ctx.imageSmoothingEnabled=false;ctx.clearRect(0,0,768,height);ctx.save();ctx.translate(0,-cameraY);ctx.strokeStyle='#292d33';for(let y=0;y<2176;y+=32){ctx.beginPath();ctx.moveTo(0,y);ctx.lineTo(768,y);ctx.stroke()}ctx.fillStyle='#363a40';ctx.fillRect(0,groundY,768,160);ctx.fillStyle='#4a5058';ctx.fillRect(0,groundY,768,3);
const frame=Math.floor(time*24)%72;for(const gear of positions)ctx.drawImage(gears,frame*96,gear.row*96,96,96,gear.x,gear.y,96,96);
for(const b of bodies){ctx.save();ctx.translate(b.x,b.y);ctx.rotate(-b.angle*Math.PI/180);ctx.scale(b.flip*b.size*b.sx,b.size*b.sy);ctx.globalAlpha=b.alpha;const hidden=b.state===0&&!b.emerged?Math.max(0,Math.min(48,Math.ceil((b.releaseY-(b.y-24*b.size))/b.size))):0;if(hidden>0&&hidden<48)ctx.drawImage(incoming,b.variant*48,hidden,48,48-hidden,-24,-24+hidden,48,48-hidden);else if(hidden===0)ctx.drawImage(b.state<2?incoming:outgoing,b.variant*48,0,48,48,-24,-24,48,48);if(b.state===0&&hidden===0&&document.getElementById("danger").checked){ctx.strokeStyle="#e77777";ctx.lineWidth=1/b.size;ctx.strokeRect(-20,-20,40,40)}ctx.restore();for(const p of b.sparks){if(p.life<=0)continue;ctx.globalAlpha=Math.min(1,p.life/.12);ctx.strokeStyle=p.color;ctx.lineWidth=1;ctx.beginPath();ctx.moveTo(Math.round(p.x),Math.round(p.y));ctx.lineTo(Math.round(p.x-p.vx*.025),Math.round(p.y-p.vy*.025));ctx.stroke()}ctx.globalAlpha=1}for(const h of hatches){ctx.globalAlpha=h.alpha;ctx.drawImage(hatchImage,0,0,96,32,h.x-48,h.y-16,96,32);const shown=Math.ceil(40*(1-h.open));if(shown>0){ctx.drawImage(hatchImage,144-shown,8,shown,16,h.x-40,h.y-8,shown,16);ctx.drawImage(hatchImage,144,8,shown,16,h.x+40-shown,h.y-8,shown,16)}}ctx.globalAlpha=1;ctx.restore()}
function tick(now){const dt=last?Math.min((now-last)/1000,.05):0;last=now;if(!paused)step(dt);if(incoming.complete&&incoming.naturalWidth&&outgoing.complete&&outgoing.naturalWidth&&gears.complete&&gears.naturalWidth&&hatchImage.complete&&hatchImage.naturalWidth){render(contexts[0],0,2176);render(contexts[1],0,560);render(contexts[2],1952,176)}requestAnimationFrame(tick)}requestAnimationFrame(tick);
</script></html>
"@
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot 'flow-preview.html'),$html,[System.Text.UTF8Encoding]::new($false))
Write-Output 'Saved animated grinder and ground preview using the actual sprites.'
