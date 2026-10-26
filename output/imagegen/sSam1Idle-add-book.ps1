$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore
$samRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$samAnimDir=Join-Path $samRoot 'sprites/sSam1Idle'
$samSourcePath=Join-Path $samRoot 'sprites/sSam_1/6153a636-1f65-4c9a-992c-01b0184f5665.png'
$samStamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$samWork=Join-Path $PSScriptRoot "sSam1Idle-book-$samStamp"
New-Item -ItemType Directory -Path $samWork | Out-Null
$samBackup=Join-Path $samWork 'animation-before.zip'
Compress-Archive -LiteralPath $samAnimDir -DestinationPath $samBackup
$samSourceHash=(Get-FileHash -LiteralPath $samSourcePath).Hash
$samResourcePath=Join-Path $samAnimDir 'sSam1Idle.yy'
$samResourceHash=(Get-FileHash -LiteralPath $samResourcePath).Hash
$samText=[IO.File]::ReadAllText($samResourcePath)
$samAnim=[regex]::Replace($samText,',(\s*[}\]])','$1')|ConvertFrom-Json
Copy-Item -LiteralPath $samSourcePath -Destination (Join-Path $samWork 'book-source.png')
$samBook=[Drawing.Bitmap]::new((Join-Path $samWork 'book-source.png'))
$samBase=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'sSam1Idle-source.png'))
$samPatch=[Collections.Generic.List[object]]::new()
for($y=0;$y -lt 96;$y++){for($x=0;$x -lt 64;$x++){
    if($samBook.GetPixel($x,$y).ToArgb() -ne $samBase.GetPixel($x,$y).ToArgb()){
        if($x -lt 31 -or $x -gt 50 -or $y -lt 50 -or $y -gt 62){throw 'Source changes extend beyond the book/grip region.'}
        $samPatch.Add([pscustomobject]@{X=$x;Y=$y;Color=$samBook.GetPixel($x,$y)})
    }
}}
if($samPatch.Count -eq 0){throw 'No book pixels found.'}
$samStage=Join-Path $samWork 'staged'
$samStrip=[Drawing.Bitmap]::new(64*$samAnim.frames.Count,96,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$samContact=[Drawing.Bitmap]::new(1536,576,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$samGif=[Windows.Media.Imaging.GifBitmapEncoder]::new()
$samManifest=@()
$samStageFiles=@()
for($i=0;$i -lt $samAnim.frames.Count;$i++){
    $samId=$samAnim.frames[$i].name
    $samBeforePath=Join-Path $samAnimDir "$samId.png"
    $samBefore=[Drawing.Bitmap]::new($samBeforePath)
    # Find the exact existing hand offset; do not infer motion from the old animation.
    $samScores=@()
    foreach($samDy in -6..8){foreach($samDx in -3..3){
        $samMismatch=0
        for($y=40;$y -le 54;$y++){for($x=35;$x -le 42;$x++){
            if($samBefore.GetPixel($x+$samDx,$y+$samDy).ToArgb() -ne $samBase.GetPixel($x,$y).ToArgb()){$samMismatch++}
        }}
        $samScores+=[pscustomobject]@{X=$samDx;Y=$samDy;Mismatch=$samMismatch}
    }}
    $samMatch=$samScores|Sort-Object Mismatch|Select-Object -First 1
    if($samMatch.Mismatch -ne 0){throw "Cannot exactly match hand in frame $i"}
    $samMask=[Collections.Generic.HashSet[int]]::new()
    foreach($samPixel in $samPatch){[void]$samMask.Add(($samPixel.Y+$samMatch.Y)*64+$samPixel.X+$samMatch.X)}
    $samPaths=@("$samId.png")
    foreach($samLayer in $samAnim.layers){$samLayerPath="layers/$samId/$($samLayer.name).png";if(Test-Path (Join-Path $samAnimDir $samLayerPath)){$samPaths+=$samLayerPath}}
    foreach($samRelative in $samPaths){
        $samExistingPath=Join-Path $samAnimDir $samRelative
        $samExistingHash=(Get-FileHash -LiteralPath $samExistingPath).Hash
        $samExisting=[Drawing.Bitmap]::new($samExistingPath)
        $samEdited=[Drawing.Bitmap]::new(64,96,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
        for($y=0;$y -lt 96;$y++){for($x=0;$x -lt 64;$x++){$samEdited.SetPixel($x,$y,$samExisting.GetPixel($x,$y))}}
        foreach($samPixel in $samPatch){$samEdited.SetPixel($samPixel.X+$samMatch.X,$samPixel.Y+$samMatch.Y,$samPixel.Color)}
        for($y=0;$y -lt 96;$y++){for($x=0;$x -lt 64;$x++){
            if(!$samMask.Contains($y*64+$x) -and $samEdited.GetPixel($x,$y).ToArgb() -ne $samExisting.GetPixel($x,$y).ToArgb()){throw "Unrelated pixel changed in frame $i"}
        }}
        foreach($samPixel in $samPatch){if($samEdited.GetPixel($samPixel.X+$samMatch.X,$samPixel.Y+$samMatch.Y).ToArgb() -ne $samPixel.Color.ToArgb()){throw 'Book pixel mismatch.'}}
        $samStagedPath=Join-Path $samStage $samRelative
        New-Item -ItemType Directory -Path (Split-Path -Parent $samStagedPath) -Force|Out-Null
        $samEdited.Save($samStagedPath,[Drawing.Imaging.ImageFormat]::Png)
        $samStageFiles+=[pscustomobject]@{Source=$samStagedPath;Destination=$samExistingPath;BeforeHash=$samExistingHash}
        $samExisting.Dispose();$samEdited.Dispose()
    }
    $samAfter=[Drawing.Bitmap]::new((Join-Path $samStage "$samId.png"))
    for($y=0;$y -lt 96;$y++){for($x=0;$x -lt 64;$x++){$samStrip.SetPixel($i*64+$x,$y,$samAfter.GetPixel($x,$y))}}
    $samContactIndex=switch($i){0{0}5{1}8{2}21{3}default{-1}}
    $samPreview=[Drawing.Bitmap]::new(384,576,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    for($y=0;$y -lt 576;$y++){for($x=0;$x -lt 384;$x++){
        $samColor=$samAfter.GetPixel([int][Math]::Floor($x/6),[int][Math]::Floor($y/6))
        if($samColor.A -eq 0){$samColor=[Drawing.Color]::FromArgb(255,49,53,63)}
        $samPreview.SetPixel($x,$y,$samColor)
        if($samContactIndex -ge 0){$samContact.SetPixel($samContactIndex*384+$x,$y,$samColor)}
    }}
    $samMemory=[IO.MemoryStream]::new()
    $samPreview.Save($samMemory,[Drawing.Imaging.ImageFormat]::Png);$samMemory.Position=0
    $samDecoder=[Windows.Media.Imaging.PngBitmapDecoder]::new($samMemory,[Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
    $samGif.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($samDecoder.Frames[0]))
    $samMemory.Dispose();$samPreview.Dispose();$samAfter.Dispose();$samBefore.Dispose()
    $samManifest+=[pscustomobject]@{Frame=$i;FrameId=$samId;BookOffsetX=$samMatch.X;BookOffsetY=$samMatch.Y;BookPixels=$samPatch.Count}
}
$samStrip.Save((Join-Path $samWork 'sprite-strip.png'),[Drawing.Imaging.ImageFormat]::Png)
$samContact.Save((Join-Path $samWork 'contact.png'),[Drawing.Imaging.ImageFormat]::Png)
$samPreviewPath=Join-Path $samWork 'preview.gif'
$samGifFile=[IO.File]::Create($samPreviewPath);$samGif.Save($samGifFile);$samGifFile.Dispose()
& (Join-Path $PSScriptRoot 'sSam1Idle-gif-timing.ps1') -Path $samPreviewPath -Fps $samAnim.sequence.playbackSpeed -FrameCount $samAnim.frames.Count
$samManifest|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $samWork 'frame-offsets.json') -Encoding UTF8
$samStrip.Dispose();$samContact.Dispose();$samBook.Dispose();$samBase.Dispose()
# Reject stale staged edits if the artist changed a source while this was running.
if((Get-FileHash -LiteralPath $samResourcePath).Hash -ne $samResourceHash){throw 'Animation metadata changed during staging; no sprite frames applied.'}
if((Get-FileHash -LiteralPath $samSourcePath).Hash -ne $samSourceHash){throw 'Book source changed during staging; no sprite frames applied.'}
foreach($samFile in $samStageFiles){if((Get-FileHash -LiteralPath $samFile.Destination).Hash -ne $samFile.BeforeHash){throw 'Animation frame changed during staging; no sprite frames applied.'}}
foreach($samFile in $samStageFiles){Copy-Item -LiteralPath $samFile.Source -Destination $samFile.Destination -Force}
if((Get-FileHash -LiteralPath $samResourcePath).Hash -ne $samResourceHash){throw 'Animation metadata changed.'}
Write-Output "Applied book-only pixel patch to $($samAnim.frames.Count) existing frames and editor layers. Timing, frame IDs, collision settings, and all other pixels preserved. Backup and preview: $samWork"
