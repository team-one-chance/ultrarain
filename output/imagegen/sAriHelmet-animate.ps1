$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore
$ariRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$ariDir=Join-Path $ariRoot 'sprites/sAriHelmet'
$ariResourcePath=Join-Path $ariDir 'sAriHelmet.yy'
$ariResourceText=[IO.File]::ReadAllText($ariResourcePath)
$ariResourceHash=(Get-FileHash -LiteralPath $ariResourcePath).Hash
$ariResource=[regex]::Replace($ariResourceText,',(\s*[}\]])','$1')|ConvertFrom-Json
if($ariResource.frames.Count -ne 1){throw 'Expected the single-frame Ari helmet sprite; refusing to replace an existing animation.'}
$ariBaseFrameId=$ariResource.frames[0].name
$ariLayerId=$ariResource.layers[0].name
$ariBasePath=Join-Path $ariDir "$ariBaseFrameId.png"
$ariBaseHash=(Get-FileHash -LiteralPath $ariBasePath).Hash
$ariBaseLayerPath=Join-Path $ariDir "layers/$ariBaseFrameId/$ariLayerId.png"
$ariBaseLayerHash=(Get-FileHash -LiteralPath $ariBaseLayerPath).Hash
$samResourcePath=Join-Path $ariRoot 'sprites/sSamIdle/sSamIdle.yy'
$samResourceHash=(Get-FileHash -LiteralPath $samResourcePath).Hash
$samResource=[regex]::Replace([IO.File]::ReadAllText($samResourcePath),',(\s*[}\]])','$1')|ConvertFrom-Json
$ariWork=Join-Path $PSScriptRoot ('sAriHelmet-idle-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $ariWork|Out-Null
Compress-Archive -LiteralPath $ariDir -DestinationPath (Join-Path $ariWork 'static-sprite-before.zip')
$ariStage=Join-Path $ariWork 'staged'
New-Item -ItemType Directory -Path $ariStage|Out-Null
$ariBase=[Drawing.Bitmap]::new($ariBasePath)
$samBaseId=$samResource.frames[0].name
$samBase=[Drawing.Bitmap]::new((Join-Path $ariRoot "sprites/sSamIdle/$samBaseId.png"))
$ariFrames=@();$ariKeys=@();$ariMotion=@();$ariSamHashes=@()
$ariFrameTemplate=$ariResource.frames[0]|ConvertTo-Json -Depth 10
$ariPalette=[Collections.Generic.HashSet[int]]::new()
for($y=0;$y -lt 96;$y++){for($x=0;$x -lt 64;$x++){[void]$ariPalette.Add($ariBase.GetPixel($x,$y).ToArgb())}}
$ariStrip=[Drawing.Bitmap]::new(64*$samResource.frames.Count,96,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$ariContact=[Drawing.Bitmap]::new(1152,576,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$ariGif=[Windows.Media.Imaging.GifBitmapEncoder]::new()
for($i=0;$i -lt $samResource.frames.Count;$i++){
    $samFrameId=$samResource.frames[$i].name
    $samFramePath=Join-Path $ariRoot "sprites/sSamIdle/$samFrameId.png"
    $ariSamHashes+=[pscustomobject]@{Path=$samFramePath;Hash=(Get-FileHash -LiteralPath $samFramePath).Hash}
    $samFrame=[Drawing.Bitmap]::new($samFramePath)
    $ariOffsets=@{}
    foreach($samRegion in @(@{Name='Head';X0=18;X1=34;Y0=3;Y1=23},@{Name='Torso';X0=18;X1=34;Y0=26;Y1=49},@{Name='Arm';X0=10;X1=17;Y0=36;Y1=59})){
        $samScores=@()
        foreach($dy in -2..2){
            $samMismatch=0
            for($y=$samRegion.Y0;$y -le $samRegion.Y1;$y++){for($x=$samRegion.X0;$x -le $samRegion.X1;$x++){if($samBase.GetPixel($x,$y).ToArgb() -ne $samFrame.GetPixel($x,$y+$dy).ToArgb()){$samMismatch++}}}
            $samScores+=[pscustomobject]@{Offset=$dy;Mismatch=$samMismatch}
        }
        $samMatch=$samScores|Sort-Object Mismatch|Select-Object -First 1
        if($samRegion.Name -ne 'Head' -and $samMatch.Mismatch -ne 0){throw "Unexpected Sam motion in frame $i"}
        if($samMatch.Offset -notin @(0,-1)){throw 'Unexpected motion range.'}
        $ariOffsets[$samRegion.Name]=[int]$samMatch.Offset
    }
    $samFrame.Dispose()
    $ariBitmap=[Drawing.Bitmap]::new(64,96,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    for($y=0;$y -lt 96;$y++){for($x=0;$x -lt 64;$x++){$ariBitmap.SetPixel($x,$y,$ariBase.GetPixel($x,$y))}}
    if($ariOffsets.Torso -eq -1){
        # Raise shoulders and chest; keep the lower shirt hem and waistband anchored.
        for($y=27;$y -le 51;$y++){for($x=0;$x -lt 64;$x++){$ariBitmap.SetPixel($x,$y,$ariBase.GetPixel($x,$y+1))}}
    }
    if($ariOffsets.Arm -eq -1){
        for($y=52;$y -le 59;$y++){for($x=0;$x -lt 64;$x++){
            $ariHere=$ariBase.GetPixel($x,$y);$ariNext=$ariBase.GetPixel($x,$y+1)
            $ariSkinHere=$ariHere.A -gt 0 -and $ariHere.R -ge 200 -and $ariHere.R -gt $ariHere.G -and $ariHere.G -gt $ariHere.B
            $ariSkinNext=$ariNext.A -gt 0 -and $ariNext.R -ge 200 -and $ariNext.R -gt $ariNext.G -and $ariNext.G -gt $ariNext.B
            if($x -lt 18 -or $x -gt 34 -or (($x -eq 18 -or $x -eq 34) -and ($ariSkinHere -or $ariSkinNext))){$ariBitmap.SetPixel($x,$y,$ariNext)}
        }}
    }
    if($ariOffsets.Head -eq -1){
        # Lift helmet, straps, face and glasses as one piece. No alterations to lenses.
        for($y=0;$y -le 26;$y++){for($x=0;$x -lt 64;$x++){$ariBitmap.SetPixel($x,$y,$ariBase.GetPixel($x,$y+1))}}
    }
    # Sam's blink is concealed by Ari's opaque glasses; preserve the exact lenses.
    for($y=0;$y -lt 96;$y++){for($x=0;$x -lt 64;$x++){
        $ariPixel=$ariBitmap.GetPixel($x,$y)
        if(!$ariPalette.Contains($ariPixel.ToArgb())){throw "New color in frame $i"}
        if(($i -eq 0 -or $y -ge 60) -and $ariPixel.ToArgb() -ne $ariBase.GetPixel($x,$y).ToArgb()){throw "Base frame or planted skates changed in frame $i"}
        $ariStrip.SetPixel($i*64+$x,$y,$ariPixel)
    }}
    $ariFrameId=if($i -eq 0){$ariBaseFrameId}else{[guid]::NewGuid().ToString()}
    New-Item -ItemType Directory -Path "$ariStage/layers/$ariFrameId" -Force|Out-Null
    if($i -eq 0){
        Copy-Item -LiteralPath $ariBasePath -Destination "$ariStage/$ariFrameId.png"
        Copy-Item -LiteralPath $ariBaseLayerPath -Destination "$ariStage/layers/$ariFrameId/$ariLayerId.png"
    }else{
        $ariBitmap.Save("$ariStage/$ariFrameId.png",[Drawing.Imaging.ImageFormat]::Png)
        $ariBitmap.Save("$ariStage/layers/$ariFrameId/$ariLayerId.png",[Drawing.Imaging.ImageFormat]::Png)
    }
    $ariFrameObject=$ariFrameTemplate|ConvertFrom-Json
    $ariFrameObject.'%Name'=$ariFrameId;$ariFrameObject.name=$ariFrameId;$ariFrames+=$ariFrameObject
    $ariKeysForFrame=$samResource.sequence.tracks[0].keyframes.Keyframes|Where-Object{$_.Channels.'0'.Id.name -eq $samFrameId}
    foreach($ariSamKey in $ariKeysForFrame){
        $ariKey=$ariSamKey|ConvertTo-Json -Depth 30|ConvertFrom-Json
        $ariKey.id=[guid]::NewGuid().ToString();$ariKey.Channels.'0'.Id.name=$ariFrameId;$ariKey.Channels.'0'.Id.path='sprites/sAriHelmet/sAriHelmet.yy';$ariKeys+=$ariKey
    }
    $ariPreview=[Drawing.Bitmap]::new(384,576,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $ariContactIndex=switch($i){0{0}5{1}8{2}default{-1}}
    for($y=0;$y -lt 576;$y++){for($x=0;$x -lt 384;$x++){
        $ariColor=$ariBitmap.GetPixel([int][Math]::Floor($x/6),[int][Math]::Floor($y/6))
        if($ariColor.A -eq 0){$ariColor=[Drawing.Color]::FromArgb(255,49,53,63)}
        $ariPreview.SetPixel($x,$y,$ariColor)
        if($ariContactIndex -ge 0){$ariContact.SetPixel($ariContactIndex*384+$x,$y,$ariColor)}
    }}
    $ariMemory=[IO.MemoryStream]::new();$ariPreview.Save($ariMemory,[Drawing.Imaging.ImageFormat]::Png);$ariMemory.Position=0
    $ariDecoder=[Windows.Media.Imaging.PngBitmapDecoder]::new($ariMemory,[Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
    $ariGif.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($ariDecoder.Frames[0]))
    $ariMemory.Dispose();$ariPreview.Dispose();$ariBitmap.Dispose()
    $ariMotion+=[pscustomobject]@{Frame=$i;Head=$ariOffsets.Head;Torso=$ariOffsets.Torso;Arm=$ariOffsets.Arm}
}
$ariResource.frames=$ariFrames
$ariResource.sequence.tracks[0].keyframes.Keyframes=@($ariKeys|Sort-Object Key)
foreach($ariTimingProperty in @('length','playback','playbackSpeed','playbackSpeedType','timeUnits')){$ariResource.sequence.$ariTimingProperty=$samResource.sequence.$ariTimingProperty}
$ariResource.bbox_top=3
[IO.File]::WriteAllText((Join-Path $ariStage 'sAriHelmet.yy'),($ariResource|ConvertTo-Json -Depth 60),[Text.UTF8Encoding]::new($false))
$ariStrip.Save((Join-Path $ariWork 'sprite-strip.png'),[Drawing.Imaging.ImageFormat]::Png)
$ariContact.Save((Join-Path $ariWork 'contact.png'),[Drawing.Imaging.ImageFormat]::Png)
$ariGifPath=Join-Path $ariWork 'preview.gif'
$ariGifFile=[IO.File]::Create($ariGifPath);$ariGif.Save($ariGifFile);$ariGifFile.Dispose()
& (Join-Path $PSScriptRoot 'sSam1Idle-gif-timing.ps1') -Path $ariGifPath -Fps $samResource.sequence.playbackSpeed -FrameCount $samResource.frames.Count
$ariMotion|ConvertTo-Json|Set-Content (Join-Path $ariWork 'motion.json') -Encoding UTF8
$ariStrip.Dispose();$ariContact.Dispose();$ariBase.Dispose();$samBase.Dispose()
if((Get-FileHash -LiteralPath $ariResourcePath).Hash -ne $ariResourceHash -or (Get-FileHash -LiteralPath $ariBasePath).Hash -ne $ariBaseHash -or (Get-FileHash -LiteralPath $ariBaseLayerPath).Hash -ne $ariBaseLayerHash){throw 'Ari was edited during staging. No changes applied.'}
if((Get-FileHash -LiteralPath $samResourcePath).Hash -ne $samResourceHash){throw 'Sam animation changed during staging. No changes applied.'}
foreach($ariSamFile in $ariSamHashes){if((Get-FileHash -LiteralPath $ariSamFile.Path).Hash -ne $ariSamFile.Hash){throw 'Sam frame changed during staging. No changes applied.'}}
Get-ChildItem $ariStage -Filter '*.png' -File|ForEach-Object{Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $ariDir $_.Name)}
foreach($ariStagedFrame in $ariFrames){
    $ariStagedFrameId=$ariStagedFrame.name
    New-Item -ItemType Directory -Path "$ariDir/layers/$ariStagedFrameId" -Force|Out-Null
    Copy-Item -LiteralPath "$ariStage/layers/$ariStagedFrameId/$ariLayerId.png" -Destination "$ariDir/layers/$ariStagedFrameId/$ariLayerId.png" -Force
}
Copy-Item -LiteralPath (Join-Path $ariStage 'sAriHelmet.yy') -Destination $ariResourcePath -Force
Write-Output "Animated sAriHelmet with Sam's exact $($samResource.frames.Count)-frame, $($samResource.sequence.playbackSpeed)-fps breathing timing and offsets. Original first frame and planted legs/skates verified; original palette preserved. Preview and backup: $ariWork"
