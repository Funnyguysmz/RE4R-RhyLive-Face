param([string]$ZigPath='zig')
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
$env:ZIG_GLOBAL_CACHE_DIR=Join-Path $root 'cache/global'
$env:ZIG_LOCAL_CACHE_DIR=Join-Path $root 'cache/local'
$package=Join-Path $root 'build/package'
New-Item -ItemType Directory -Force -Path "$package/reframework/plugins","$package/reframework/autorun/RhyLiveFace" | Out-Null
$lua=Join-Path $root 'vendor/lua'
$sources=@(Get-ChildItem -LiteralPath $lua -Filter '*.c' | Where-Object {$_.Name -notin @('lua.c','luac.c','onelua.c','ltests.c')} | ForEach-Object FullName)
if(!$sources.Count){throw 'Lua sources not found'}
& $ZigPath cc -target x86_64-windows-gnu -O2 -shared "-I$lua" "-I$root/vendor/reframework" "$root/src/receiver.c" @sources -lws2_32 -o "$package/reframework/plugins/RhyLiveFace.dll"
if($LASTEXITCODE){throw 'Receiver build failed'}
Copy-Item "$root/src/RhyLiveFace.lua" "$package/reframework/autorun"
foreach($name in @('face_math.lua','default_profile.lua','localization.lua')){Copy-Item "$root/src/$name" "$package/reframework/autorun/RhyLiveFace"}
Copy-Item "$root/README.md","$root/ThirdPartyNotices.txt" $package
