param(
    [string]$RuntimeRoot = (Join-Path ([Environment]::GetFolderPath('CommonApplicationData')) 'GameMakerStudio2-LTS2026/Cache/runtimes/runtime-2026.0.0.23'), # Installed GameMaker runtime to compile and run the regression.
    [string]$GameMakerUser = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'GameMakerStudio2-LTS2026/unknownUser_unknownUserID') # Existing local build profile; no credentials are read or printed.
)
$ErrorActionPreference = 'Stop'
$workspace = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..')) # Source workspace containing the real effect.
$buildRoot = Join-Path $workspace 'Build/breaker-slam-regression' # Generated harness and logs stay in the ignored Build folder.
$utf8 = [Text.UTF8Encoding]::new($false) # Match repository text files without adding a byte-order mark.
New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null

function Read-GameMakerJson([string]$Path) {
    # GameMaker's JSON files allow trailing commas; remove those before parsing.
    return ConvertFrom-Json -InputObject ([regex]::Replace([IO.File]::ReadAllText($Path), ',(\s*[}\]])', '$1'))
}
function Write-HarnessJson([string]$RelativePath, $Value) {
    $target = Join-Path $buildRoot $RelativePath
    New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
    [IO.File]::WriteAllText($target, ($Value | ConvertTo-Json -Depth 100), $utf8)
}

# Copy the actual implementation, so tests cannot pass by reproducing its logic.
foreach ($relativeDirectory in @('objects/oBreakerSlamVFX','scripts/scr_breaker_slam_visuals','options')) {
    $destination = Join-Path $buildRoot (Split-Path $relativeDirectory)
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $workspace $relativeDirectory) -Destination $destination -Recurse -Force
}
$controllerName = 'oBreakerSlamRegression' # Persistent controller containing only assertions and room changes.
$controller = Read-GameMakerJson (Join-Path $workspace 'objects/oBreakerSlamVFX/oBreakerSlamVFX.yy')
$controller.'%Name' = $controllerName
$controller.name = $controllerName
$controller.persistent = $true
$controller.parent = @{name='Objects';path='folders/Objects.yy'}
Write-HarnessJson "objects/$controllerName/$controllerName.yy" $controller
foreach ($eventFile in @('Create_0.gml','Step_0.gml','Draw_0.gml')) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $eventFile) -Destination (Join-Path $buildRoot "objects/$controllerName/$eventFile") -Force
}
$renderer = Read-GameMakerJson (Join-Path $workspace 'objects/oBreakerSlamVFX/oBreakerSlamVFX.yy')
$renderer.'%Name' = 'o_Lighting'
$renderer.name = 'o_Lighting'
$renderer.eventList = @() # Only supplies the resource ID and renderer fields for handoff assertions.
Write-HarnessJson 'objects/o_Lighting/o_Lighting.yy' $renderer

$resources = @(
    @{id=@{name='oBreakerSlamVFX';path='objects/oBreakerSlamVFX/oBreakerSlamVFX.yy'}},
    @{id=@{name=$controllerName;path="objects/$controllerName/$controllerName.yy"}},
    @{id=@{name='o_Lighting';path='objects/o_Lighting/o_Lighting.yy'}},
    @{id=@{name='scr_breaker_slam_visuals';path='scripts/scr_breaker_slam_visuals/scr_breaker_slam_visuals.yy'}}
)
$roomNames = @('TESTING','SLAM_REGRESSION_NEXT') # A direct test-room launch followed by a new level.
foreach ($roomName in $roomNames) {
    $room = Read-GameMakerJson (Join-Path $workspace 'rooms/TESTING/TESTING.yy')
    $room.'%Name' = $roomName
    $room.name = $roomName
    $room.instanceCreationOrder = @()
    $room.layers = @()
    $room.roomSettings.Width = 320
    $room.roomSettings.Height = 160
    $room.roomSettings.persistent = $false
    $room.physicsSettings.PhysicsWorld = $false
    $room.viewSettings.enableViews = $false
    $room.creationCodeFile = "rooms/$roomName/RoomCreationCode.gml"
    Write-HarnessJson "rooms/$roomName/$roomName.yy" $room
    $creationCode = if ($roomName -eq 'TESTING') { "instance_create_depth(0, 0, -1000, $controllerName);" } else { '' }
    [IO.File]::WriteAllText((Join-Path $buildRoot "rooms/$roomName/RoomCreationCode.gml"), $creationCode, $utf8)
    $resources += @{id=@{name=$roomName;path="rooms/$roomName/$roomName.yy"}}
}
$project = Read-GameMakerJson (Join-Path $workspace 'ULTRA RAIN.yyp')
$project.'%Name' = 'BreakerSlamRegression'
$project.resources = $resources
$project.RoomOrderNodes = @($roomNames | ForEach-Object { @{roomId=@{name=$_;path="rooms/$_/$_.yy"}} })
Write-HarnessJson 'BreakerSlamRegression.yyp' $project

$igor = Join-Path $RuntimeRoot 'bin/igor/windows/x64/Igor.exe' # Official GameMaker compiler.
$compileLog = Join-Path $buildRoot 'compile.log'
& $igor "--project=$buildRoot/BreakerSlamRegression.yyp" "--rp=$RuntimeRoot" '--runtime=VM' "--cache=$buildRoot/cache" "--temp=$buildRoot/temp" "--of=$buildRoot/BreakerSlamRegression.win" "--user=$GameMakerUser" windows Compile *> $compileLog
if ($LASTEXITCODE -ne 0) { Get-Content $compileLog -Tail 30; throw 'Regression harness failed to compile.' }

$stdoutLog = Join-Path $buildRoot 'runner.stdout.log'
$stderrLog = Join-Path $buildRoot 'runner.stderr.log'
$debugLog = Join-Path $buildRoot 'runner.debug.log'
$runner = Join-Path $RuntimeRoot 'windows/x64/Runner.exe' # Actual GameMaker VM runner, with its window hidden.
$runnerArguments = @('-game', ('"' + (Join-Path $buildRoot 'BreakerSlamRegression.win') + '"'), '-debugoutput', ('"' + $debugLog + '"'))
$process = Start-Process -FilePath $runner -ArgumentList $runnerArguments -WorkingDirectory $buildRoot -WindowStyle Hidden -RedirectStandardOutput $stdoutLog -RedirectStandardError $stderrLog -PassThru
if (!$process.WaitForExit(20000)) { $process.Kill(); throw 'Regression runner timed out after 20 seconds.' }
$runnerOutput = (@($stdoutLog,$stderrLog,$debugLog) | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object { [IO.File]::ReadAllText($_) }) -join "`n"
$messages = @($runnerOutput -split '\r?\n' | Where-Object { $_ -match 'BREAKER_TEST_' } | Select-Object -Unique)
$messages | Write-Output
if ($runnerOutput -match 'BREAKER_TEST_FAIL:' -or $runnerOutput -notmatch 'BREAKER_TEST_COMPLETE: failures=0') {
    Get-Content $stdoutLog -Tail 20
    Get-Content $stderrLog -Tail 20
    throw 'GameMaker regression checks failed; inspect Build/breaker-slam-regression logs.'
}
