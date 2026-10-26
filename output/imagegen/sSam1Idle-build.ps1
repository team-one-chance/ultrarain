$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore
$samRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$samName = 'sSam1Idle'
$samSourcePath = Join-Path $PSScriptRoot 'sSam1Idle-source.png'
$samSourceHash = (Get-FileHash -LiteralPath (Join-Path $samRoot 'sprites/sSam_1/6153a636-1f65-4c9a-992c-01b0184f5665.png')).Hash
$samOriginal = [Drawing.Bitmap]::new($samSourcePath)
$samDir = Join-Path $samRoot "sprites/$samName"
if (Test-Path -LiteralPath $samDir) { throw 'Animated sprite already exists; refusing to overwrite.' }
New-Item -ItemType Directory -Path $samDir | Out-Null
$samResourceText = [IO.File]::ReadAllText((Join-Path $samRoot 'sprites/sSam_1/sSam_1.yy'))
$samResource = [regex]::Replace($samResourceText,',(\s*[}\]])','$1') | ConvertFrom-Json
$samResource.'%Name' = $samName
$samResource.name = $samName
$samResource.bboxMode = 2
$samResource.bbox_top = 1
$samResource.sequence.'%Name' = $samName
$samResource.sequence.name = $samName
$samResource.sequence.length = 24.0
$samResource.sequence.playbackSpeed = 6.0
$samResource.sequence.playbackSpeedType = 0
$samLayer = [guid]::NewGuid().ToString()
$samResource.layers[0].'%Name' = $samLayer
$samResource.layers[0].name = $samLayer
$samKeyTemplate = $samResource.sequence.tracks[0].keyframes.Keyframes[0] | ConvertTo-Json -Depth 40
$samFrameTemplate = $samResource.frames[0] | ConvertTo-Json -Depth 10
$samFrames = @()
$samKeys = @()
$samPalette = [Collections.Generic.HashSet[int]]::new()
for ($y=0;$y -lt 96;$y++) { for ($x=0;$x -lt 64;$x++) { [void]$samPalette.Add($samOriginal.GetPixel($x,$y).ToArgb()) } }
$samStrip = [Drawing.Bitmap]::new(1536,96,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$samContact = [Drawing.Bitmap]::new(1536,576,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$samGif = [Windows.Media.Imaging.GifBitmapEncoder]::new()
$samGifStreams = [Collections.Generic.List[IO.MemoryStream]]::new()
$samPoseSequence = @(0,0,0,0,0,1,1,1,2,2,2,2,1,1,1,0,0,0,0,0,0,0,0,0)
for ($i=0;$i -lt 24;$i++) {
    $samPose = $samPoseSequence[$i]
    $samBlink = $i -eq 21
    $samBitmap = [Drawing.Bitmap]::new(64,96,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    # The original image is the base of every frame; legs and feet stay fixed.
    for ($y=0;$y -lt 96;$y++) { for ($x=0;$x -lt 64;$x++) { $samBitmap.SetPixel($x,$y,$samOriginal.GetPixel($x,$y)) } }
    if ($samPose -gt 0) {
        # Shoulders, shirt and hanging hands rise one pixel; the waistband stays anchored.
        for ($y=20;$y -le 54;$y++) {
            for ($x=0;$x -lt 64;$x++) {
                $samArm = $x -lt 18 -or $x -gt 34
                if ($samArm -or $y -le 47) { $samBitmap.SetPixel($x,$y,$samOriginal.GetPixel($x,$y+1)) }
            }
        }
        # Keep the shirt hem intact and extend the original bottom shirt row by one pixel.
        for ($x=18;$x -le 34;$x++) { $samBitmap.SetPixel($x,47,$samOriginal.GetPixel($x,47)) }
        if ($samPose -eq 2) {
            # A small head lift follows the breath; copy exact head/neck pixels.
            for ($y=0;$y -lt 20;$y++) { for ($x=0;$x -lt 64;$x++) { $samBitmap.SetPixel($x,$y,$samOriginal.GetPixel($x,$y+1)) } }
        }
    }
    if ($samBlink) {
        for ($y=11;$y -le 12;$y++) { for ($x=20;$x -le 32;$x++) { if ($x -ne 26) { $samBitmap.SetPixel($x,$y,$samOriginal.GetPixel($x,13)) } } }
        foreach ($x in @(22,23,24,28,29,30)) { $samBitmap.SetPixel($x,12,$samOriginal.GetPixel(21,10)) }
    }
    # Verify palette, planted lower body and exact original first frame.
    for ($y=0;$y -lt 96;$y++) {
        for ($x=0;$x -lt 64;$x++) {
            $samPixel = $samBitmap.GetPixel($x,$y)
            if (!$samPalette.Contains($samPixel.ToArgb())) { throw "New color in frame $i" }
            if (($i -eq 0 -or $y -ge 55) -and $samPixel.ToArgb() -ne $samOriginal.GetPixel($x,$y).ToArgb()) { throw "Original or planted feet mismatch in frame $i" }
            $samStrip.SetPixel($i*64+$x,$y,$samPixel)
        }
    }
    $samFrame = [guid]::NewGuid().ToString()
    New-Item -ItemType Directory -Path "$samDir/layers/$samFrame" -Force | Out-Null
    $samBitmap.Save("$samDir/$samFrame.png",[Drawing.Imaging.ImageFormat]::Png)
    $samBitmap.Save("$samDir/layers/$samFrame/$samLayer.png",[Drawing.Imaging.ImageFormat]::Png)
    $samFrameObject = $samFrameTemplate | ConvertFrom-Json
    $samFrameObject.'%Name' = $samFrame
    $samFrameObject.name = $samFrame
    $samFrames += $samFrameObject
    $samKey = $samKeyTemplate | ConvertFrom-Json
    $samKey.id = [guid]::NewGuid().ToString()
    $samKey.Key = [double]$i
    $samKey.Length = 1.0
    $samKey.Channels.'0'.Id.name = $samFrame
    $samKey.Channels.'0'.Id.path = "sprites/$samName/$samName.yy"
    $samKeys += $samKey
    # Preview only: enlarge without interpolation against a neutral background.
    $samPreview = [Drawing.Bitmap]::new(384,576,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    for ($y=0;$y -lt 576;$y++) {
        for ($x=0;$x -lt 384;$x++) {
            $samPixel = $samBitmap.GetPixel([int][Math]::Floor($x/6),[int][Math]::Floor($y/6))
            if ($samPixel.A -eq 0) { $samPixel = [Drawing.Color]::FromArgb(255,49,53,63) }
            $samPreview.SetPixel($x,$y,$samPixel)
            $samContactIndex = switch ($i) { 0 {0} 5 {1} 8 {2} 21 {3} default {-1} }
            if ($samContactIndex -ge 0) { $samContact.SetPixel($samContactIndex*384+$x,$y,$samPixel) }
        }
    }
    $samStream = [IO.MemoryStream]::new()
    $samPreview.Save($samStream,[Drawing.Imaging.ImageFormat]::Png)
    $samStream.Position = 0
    $samGifStreams.Add($samStream)
    $samDecoder = [Windows.Media.Imaging.PngBitmapDecoder]::new($samStream,[Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
    $samMetadata = [Windows.Media.Imaging.BitmapMetadata]::new('gif')
    $samMetadata.SetQuery('/grctlext/Delay',[uint16]$(if ($i%3 -eq 0) {16} else {17}))
    $samMetadata.SetQuery('/grctlext/Disposal',[byte]1)
    if ($i -eq 0) {
        $samMetadata.SetQuery('/appext/application',[Text.Encoding]::ASCII.GetBytes('NETSCAPE2.0'))
        $samMetadata.SetQuery('/appext/data',[byte[]]@(3,1,0,0,0))
    }
    $samGif.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($samDecoder.Frames[0],$null,$samMetadata,$null))
    $samPreview.Dispose(); $samBitmap.Dispose()
}
$samResource.frames = $samFrames
$samResource.sequence.tracks[0].keyframes.Keyframes = $samKeys
[IO.File]::WriteAllText("$samDir/$samName.yy",($samResource | ConvertTo-Json -Depth 60),[Text.UTF8Encoding]::new($false))
$samStrip.Save((Join-Path $PSScriptRoot 'sSam1Idle-strip.png'),[Drawing.Imaging.ImageFormat]::Png)
$samContact.Save((Join-Path $PSScriptRoot 'sSam1Idle-contact.png'),[Drawing.Imaging.ImageFormat]::Png)
$samGifPath = Join-Path $PSScriptRoot 'sSam1Idle-preview.gif'
$samGifFile = [IO.File]::Create($samGifPath)
$samGif.Save($samGifFile)
$samGifFile.Dispose()
& (Join-Path $PSScriptRoot 'sSam1Idle-gif-timing.ps1') -Path $samGifPath
foreach ($samStream in $samGifStreams) { $samStream.Dispose() }
$samStrip.Dispose(); $samContact.Dispose(); $samOriginal.Dispose()
$samVerifyStream=[IO.File]::OpenRead($samGifPath)
$samVerifyDecoder=[Windows.Media.Imaging.GifBitmapDecoder]::new($samVerifyStream,[Windows.Media.Imaging.BitmapCreateOptions]::None,[Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
if ($samVerifyDecoder.Frames.Count -ne 24) { throw 'Incorrect GIF frame count.' }
$samVerifyStream.Dispose()
if ((Get-FileHash -LiteralPath (Join-Path $samRoot 'sprites/sSam_1/6153a636-1f65-4c9a-992c-01b0184f5665.png')).Hash -ne $samSourceHash) { throw 'Source changed during build.' }
Write-Output 'Created 24 frames, 6 fps, 4-second breathing/blink loop. Verified original first frame, fixed lower body, original palette, GIF decoding, and unchanged sSam_1.'
