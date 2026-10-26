$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore
$beamRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$beamDir=Join-Path $beamRoot 'sprites/sSowrdBeam'
$beamMetadataPath=Join-Path $beamDir 'sSowrdBeam.yy'
$beamMetadataText=[IO.File]::ReadAllText($beamMetadataPath)
$beamMetadata=[regex]::Replace($beamMetadataText,',(\s*[}\]])','$1')|ConvertFrom-Json
if($beamMetadata.width -ne 35 -or $beamMetadata.height -ne 65 -or $beamMetadata.frames.Count -ne 16){throw 'Unexpected source beam layout.'}
$beamCoreLayer=($beamMetadata.layers|Where-Object displayName -eq 'Beam').name
$beamAuraLayer=($beamMetadata.layers|Where-Object displayName -eq 'Aura').name
if(!$beamCoreLayer -or !$beamAuraLayer){throw 'Missing Beam or Aura layer.'}
$beamWork=Join-Path $PSScriptRoot ('finished-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $beamWork|Out-Null
Compress-Archive -LiteralPath $beamDir -DestinationPath (Join-Path $beamWork 'before.zip')
$beamHashes=Get-ChildItem $beamDir -File -Recurse|Get-FileHash
$beamStage=Join-Path $beamWork 'staged'
New-Item -ItemType Directory -Path $beamStage|Out-Null
$beamRef=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'aura-reference.png'))
$beamPadX=10;$beamPadY=4;$beamWidth=47;$beamHeight=73
$beamFrames=[Collections.Generic.List[Drawing.Bitmap]]::new()
$beamManifest=@()
$beamContact=[Drawing.Bitmap]::new($beamWidth*4*8,$beamHeight*4*2,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$beamAuraContact=[Drawing.Bitmap]::new($beamWidth*4*7,$beamHeight*4,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
for($i=0;$i -lt $beamMetadata.frames.Count;$i++){
    $beamId=$beamMetadata.frames[$i].name
    $beamOldCore=[Drawing.Bitmap]::new((Join-Path $beamDir "layers/$beamId/$beamCoreLayer.png"))
    $beamCore=[Drawing.Bitmap]::new($beamWidth,$beamHeight,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $beamAura=[Drawing.Bitmap]::new($beamWidth,$beamHeight,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $beamComposite=[Drawing.Bitmap]::new($beamWidth,$beamHeight,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $beamBounds=@(35,65,0,0)
    for($y=0;$y -lt 65;$y++){for($x=0;$x -lt 35;$x++){
        $c=$beamOldCore.GetPixel($x,$y)
        $beamCore.SetPixel($x+$beamPadX,$y+$beamPadY,$c)
        if($c.A -gt 0){$beamBounds[0]=[Math]::Min($x,$beamBounds[0]);$beamBounds[1]=[Math]::Min($y,$beamBounds[1]);$beamBounds[2]=[Math]::Max($x,$beamBounds[2]);$beamBounds[3]=[Math]::Max($y,$beamBounds[3])}
    }}
    $beamScale=[Math]::Min(1.0,($beamBounds[3]-$beamBounds[1]+1+2)/65.0)
    $beamCenterY=($beamBounds[1]+$beamBounds[3])/2.0
    $beamPhase=2*[Math]::PI*(($i-9+70)%7)/7.0
    $beamOpacity=if($i -lt 9){0.4+0.6*$i/9.0}else{1.0}
    $beamVisibleColors=@{Black=0;Red=0;Yellow=0}
    for($y=0;$y -lt $beamHeight;$y++){for($x=0;$x -lt $beamWidth;$x++){
        $beamLogicalY=$y-$beamPadY
        $beamRefY=32+($beamLogicalY-$beamCenterY)/$beamScale
        $beamSampleY=$beamRefY+0.65*[Math]::Sin($beamPhase+$beamRefY*0.19)
        $beamTrailOffset=4+4*[Math]::Sin([Math]::PI*[Math]::Max(0,[Math]::Min(64,$beamRefY))/64)
        $beamFlow=1.25*[Math]::Sin($beamPhase+$beamRefY*0.28)
        $beamSampleX=34+($x-$beamPadX-$beamBounds[2])/$beamScale+$beamTrailOffset+$beamFlow
        $sx=[int][Math]::Floor($beamSampleX+0.5);$sy=[int][Math]::Floor($beamSampleY+0.5)
        if($sx -ge 0 -and $sx -lt 35 -and $sy -ge 0 -and $sy -lt 65){
            $c=$beamRef.GetPixel($sx,$sy)
            if($c.A -gt 0){$beamAura.SetPixel($x,$y,[Drawing.Color]::FromArgb([int][Math]::Round($c.A*$beamOpacity),$c.R,$c.G,$c.B))}
        }
        $beamCorePixel=$beamCore.GetPixel($x,$y);$beamAuraPixel=$beamAura.GetPixel($x,$y)
        $beamResultPixel=if($beamCorePixel.A -gt 0){$beamCorePixel}else{$beamAuraPixel}
        $beamComposite.SetPixel($x,$y,$beamResultPixel)
        if($beamCorePixel.A -eq 0 -and $beamAuraPixel.A -ge 128){
            if($beamAuraPixel.R -eq 0){$beamVisibleColors.Black++}elseif($beamAuraPixel.G -gt 100){$beamVisibleColors.Yellow++}else{$beamVisibleColors.Red++}
        }
    }}
    if($i -ge 9 -and ($beamVisibleColors.Black -lt 5 -or $beamVisibleColors.Red -lt 5 -or $beamVisibleColors.Yellow -lt 5)){throw "Missing visible aura color in loop frame $i"}
    # The original blade is pixel-identical at the translated canvas coordinates.
    for($y=0;$y -lt 65;$y++){for($x=0;$x -lt 35;$x++){
        $c=$beamOldCore.GetPixel($x,$y)
        if($c.ToArgb() -ne $beamCore.GetPixel($x+$beamPadX,$y+$beamPadY).ToArgb()){throw 'Core pixel changed.'}
        if($c.A -gt 0 -and $c.ToArgb() -ne $beamComposite.GetPixel($x+$beamPadX,$y+$beamPadY).ToArgb()){throw 'Aura obscures beam core.'}
    }}
    $beamLayerDir=Join-Path $beamStage "layers/$beamId"
    New-Item -ItemType Directory -Path $beamLayerDir -Force|Out-Null
    $beamCore.Save((Join-Path $beamLayerDir "$beamCoreLayer.png"),[Drawing.Imaging.ImageFormat]::Png)
    $beamAura.Save((Join-Path $beamLayerDir "$beamAuraLayer.png"),[Drawing.Imaging.ImageFormat]::Png)
    $beamComposite.Save((Join-Path $beamStage "$beamId.png"),[Drawing.Imaging.ImageFormat]::Png)
    $beamFrames.Add($beamComposite)
    $beamSelectedIndex=[Array]::IndexOf(@(0,2,5,8,9,11,13,15),$i)
    if($beamSelectedIndex -ge 0){
        $beamPanelX=($beamSelectedIndex%8)*$beamWidth*4
        for($y=0;$y -lt $beamHeight*4;$y++){for($x=0;$x -lt $beamWidth*4;$x++){
            $px=[int][Math]::Floor($x/4);$py=[int][Math]::Floor($y/4)
            foreach($panel in @(0,1)){
                $c=if($panel -eq 0){$beamComposite.GetPixel($px,$py)}else{$beamAura.GetPixel($px,$py)}
                $f=$c.A/255.0
                $c=[Drawing.Color]::FromArgb(255,[int]($c.R*$f+45*(1-$f)),[int]($c.G*$f+49*(1-$f)),[int]($c.B*$f+60*(1-$f)))
                $beamContact.SetPixel($beamPanelX+$x,$panel*$beamHeight*4+$y,$c)
            }
        }}
    }
    if($i -ge 9){
        for($y=0;$y -lt $beamHeight*4;$y++){for($x=0;$x -lt $beamWidth*4;$x++){
            $c=$beamComposite.GetPixel([int][Math]::Floor($x/4),[int][Math]::Floor($y/4));$f=$c.A/255.0
            $c=[Drawing.Color]::FromArgb(255,[int]($c.R*$f+45*(1-$f)),[int]($c.G*$f+49*(1-$f)),[int]($c.B*$f+60*(1-$f)))
            $beamAuraContact.SetPixel(($i-9)*$beamWidth*4+$x,$y,$c)
        }}
    }
    $beamManifest+=[pscustomobject]@{Frame=$i;Looping=($i -ge 9);VisibleAuraBlack=$beamVisibleColors.Black;VisibleAuraRed=$beamVisibleColors.Red;VisibleAuraYellow=$beamVisibleColors.Yellow;Phase=$beamPhase}
    $beamOldCore.Dispose();$beamCore.Dispose();$beamAura.Dispose()
}
$beamOriginalOriginX=$beamMetadata.sequence.xorigin;$beamOriginalOriginY=$beamMetadata.sequence.yorigin
$beamMetadata.width=$beamWidth;$beamMetadata.height=$beamHeight
$beamMetadata.origin=9
$beamMetadata.sequence.xorigin+=$beamPadX;$beamMetadata.sequence.yorigin+=$beamPadY
$beamMetadata.bbox_left+=$beamPadX;$beamMetadata.bbox_right+=$beamPadX
$beamMetadata.bbox_top+=$beamPadY;$beamMetadata.bbox_bottom+=$beamPadY
if($beamMetadata.bbox_left-$beamMetadata.sequence.xorigin -ne -35 -or $beamMetadata.bbox_right-$beamMetadata.sequence.xorigin -ne -1 -or $beamMetadata.bbox_top-$beamMetadata.sequence.yorigin -ne -65 -or $beamMetadata.bbox_bottom-$beamMetadata.sequence.yorigin -ne -1){throw 'World-space collision bounds changed.'}
[IO.File]::WriteAllText((Join-Path $beamStage 'sSowrdBeam.yy'),($beamMetadata|ConvertTo-Json -Depth 60),[Text.UTF8Encoding]::new($false))
$beamContact.Save((Join-Path $beamWork 'contact.png'),[Drawing.Imaging.ImageFormat]::Png)
$beamAuraContact.Save((Join-Path $beamWork 'loop-contact.png'),[Drawing.Imaging.ImageFormat]::Png)
$beamManifest|ConvertTo-Json|Set-Content (Join-Path $beamWork 'visible-aura-colors.json') -Encoding UTF8
$beamManifest|Format-Table -AutoSize
$beamSequences=@(@{Name='growth-and-loop';Indices=@(0..15)+@(9..15)+@(9..15)+@(9..15)},@{Name='loop';Indices=@(9..15)})
foreach($beamSequence in $beamSequences){
    $beamGif=[Windows.Media.Imaging.GifBitmapEncoder]::new()
    foreach($beamIndex in $beamSequence.Indices){
        $beamPreview=[Drawing.Bitmap]::new($beamWidth*6,$beamHeight*6,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
        for($y=0;$y -lt $beamHeight*6;$y++){for($x=0;$x -lt $beamWidth*6;$x++){
            $c=$beamFrames[$beamIndex].GetPixel([int][Math]::Floor($x/6),[int][Math]::Floor($y/6));$f=$c.A/255.0
            $c=[Drawing.Color]::FromArgb(255,[int]($c.R*$f+45*(1-$f)),[int]($c.G*$f+49*(1-$f)),[int]($c.B*$f+60*(1-$f)))
            $beamPreview.SetPixel($x,$y,$c)
        }}
        $beamMemory=[IO.MemoryStream]::new();$beamPreview.Save($beamMemory,[Drawing.Imaging.ImageFormat]::Png);$beamMemory.Position=0
        $beamDecoder=[Windows.Media.Imaging.PngBitmapDecoder]::new($beamMemory,[Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
        $beamGif.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($beamDecoder.Frames[0]))
        $beamMemory.Dispose();$beamPreview.Dispose()
    }
    $beamGifPath=Join-Path $beamWork ($beamSequence.Name+'.gif')
    $beamGifStream=[IO.File]::Create($beamGifPath);$beamGif.Save($beamGifStream);$beamGifStream.Dispose()
    & (Join-Path $beamRoot 'output/imagegen/sSam1Idle-gif-timing.ps1') -Path $beamGifPath -Fps $beamMetadata.sequence.playbackSpeed -FrameCount $beamSequence.Indices.Count
}
foreach($beamFrame in $beamFrames){$beamFrame.Dispose()}
$beamRef.Dispose();$beamContact.Dispose();$beamAuraContact.Dispose()
foreach($beamHash in $beamHashes){if((Get-FileHash -LiteralPath $beamHash.Path).Hash -ne $beamHash.Hash){throw 'Beam edited during staging. No changes applied.'}}
# Apply staged files only after visually inspecting the output.
$beamHashes|Select-Object Path,Hash|ConvertTo-Json|Set-Content (Join-Path $beamWork 'source-hashes.json') -Encoding UTF8
Write-Output "Staged improved beam, validated all three aura colors in frames 10-16, identical core and world-space bounds. Output: $beamWork"
