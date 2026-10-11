param([string]$ZigPath='zig')
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
$env:ZIG_GLOBAL_CACHE_DIR=Join-Path $root 'cache/global'
$env:ZIG_LOCAL_CACHE_DIR=Join-Path $root 'cache/local'
$testOutput=Join-Path $root 'build/tests'
New-Item -ItemType Directory -Force -Path $testOutput | Out-Null
$lua=Join-Path $root 'vendor/lua'
$sources=@(Get-ChildItem -LiteralPath $lua -Filter '*.c' | Where-Object {$_.Name -notin @('lua.c','luac.c','onelua.c','ltests.c')} | ForEach-Object FullName)
foreach($name in @('binding_test','receiver_test')) {
    $inputs=@("$root/tests/$name.c")
    if($name -eq 'binding_test') {$inputs+="$root/src/receiver.c"}
    $exe=Join-Path $testOutput "$name.exe"
    & $ZigPath cc -target x86_64-windows-gnu -O2 "-I$lua" "-I$root/vendor/reframework" @inputs @sources -lws2_32 -o $exe
    if($LASTEXITCODE){throw "$name build failed"}
    & $exe
    if($LASTEXITCODE){throw "$name failed"}
    if($name -eq 'binding_test') {
        & $exe "$root/build/package/reframework/plugins/RhyLiveFace.dll"
        if($LASTEXITCODE){throw 'Built DLL binding failed'}
        Write-Output 'BUILT_DLL_BINDING_PASS'
    }
}
