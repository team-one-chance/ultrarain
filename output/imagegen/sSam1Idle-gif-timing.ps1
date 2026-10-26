param([Parameter(Mandatory=$true)][string]$Path,[double]$Fps=6,[int]$FrameCount=24)
$ErrorActionPreference='Stop'
$samGifBytes=[IO.File]::ReadAllBytes($Path)
$samGifOut=[IO.MemoryStream]::new()
$samGifPos=13
if (($samGifBytes[10] -band 128) -ne 0) { $samGifPos += 3 * [int][Math]::Pow(2,1+($samGifBytes[10] -band 7)) }
$samGifOut.Write($samGifBytes,0,$samGifPos)
$samGifOut.Write([byte[]]@(33,255,11),0,3)
$samGifApplication=[Text.Encoding]::ASCII.GetBytes('NETSCAPE2.0')
$samGifOut.Write($samGifApplication,0,11)
$samGifOut.Write([byte[]]@(3,1,0,0,0),0,5)
$samGifCount=0
while ($samGifPos -lt $samGifBytes.Length) {
    $samGifStart=$samGifPos
    $samGifMarker=$samGifBytes[$samGifPos]
    if ($samGifMarker -eq 59) { $samGifOut.WriteByte(59); break }
    if ($samGifMarker -eq 33) {
        $samGifLabel=$samGifBytes[$samGifPos+1]
        $samGifPos+=2
        do { $samGifBlockSize=[int]$samGifBytes[$samGifPos]; $samGifPos+=1+$samGifBlockSize } while ($samGifBlockSize -ne 0)
        $samGifIsLoop=$samGifLabel -eq 255 -and [Text.Encoding]::ASCII.GetString($samGifBytes,$samGifStart+3,11) -eq 'NETSCAPE2.0'
        if ($samGifLabel -ne 249 -and !$samGifIsLoop) { $samGifOut.Write($samGifBytes,$samGifStart,$samGifPos-$samGifStart) }
    } elseif ($samGifMarker -eq 44) {
        $samGifDelay=[int]([Math]::Round(($samGifCount+1)*100/$Fps)-[Math]::Round($samGifCount*100/$Fps))
        $samGifOut.Write([byte[]]@(33,249,4,4,$samGifDelay,0,0,0),0,8)
        $samGifPacked=$samGifBytes[$samGifPos+9]
        $samGifPos+=10
        if (($samGifPacked -band 128) -ne 0) { $samGifPos+=3*[int][Math]::Pow(2,1+($samGifPacked -band 7)) }
        $samGifPos++
        do { $samGifBlockSize=[int]$samGifBytes[$samGifPos]; $samGifPos+=1+$samGifBlockSize } while ($samGifBlockSize -ne 0)
        $samGifOut.Write($samGifBytes,$samGifStart,$samGifPos-$samGifStart)
        $samGifCount++
    } else { throw "Unexpected GIF block $samGifMarker at $samGifPos" }
}
if ($samGifCount -ne $FrameCount) { throw "Expected $FrameCount GIF image blocks." }
[IO.File]::WriteAllBytes($Path,$samGifOut.ToArray())
$samGifOut.Dispose()
Write-Output "Encoded GIF timing: $samGifCount frames at $Fps fps, infinite loop."
