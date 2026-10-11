param([string]$ZigPath='zig')
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
& "$root/Build.ps1" -ZigPath $ZigPath
& "$root/Test.ps1" -ZigPath $ZigPath
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$version='0.2.0'
if(!(Select-String -LiteralPath "$root/src/RhyLiveFace.lua" -SimpleMatch "local VERSION='$version'" -Quiet)){throw 'Panel version mismatch'}
if(!(Select-String -LiteralPath "$root/src/receiver.c" -SimpleMatch "#define RHYLIVE_PRODUCT_VERSION `"$version`"" -Quiet)){throw 'Receiver product version mismatch'}
$package=Join-Path $root 'build/package'
$release=Join-Path $root 'output/release'
New-Item -ItemType Directory -Force -Path $release | Out-Null
$files=@('README.md','LICENSE','ThirdPartyNotices.txt','reframework/plugins/RhyLiveFace.dll','reframework/autorun/RhyLiveFace.lua','reframework/autorun/RhyLiveFace/face_math.lua','reframework/autorun/RhyLiveFace/default_profile.lua','reframework/autorun/RhyLiveFace/localization.lua')
$zipPath=Join-Path $release "RE4R-RhyLive-Face-v$version.zip"
if(Test-Path -LiteralPath $zipPath){throw "Output already exists: $zipPath; preserve it before rebuilding"}
$hashes=@{}
foreach($name in $files){$hashes[$name]=(Get-FileHash -LiteralPath (Join-Path $package $name) -Algorithm SHA256).Hash}
$zip=[IO.Compression.ZipFile]::Open($zipPath,[IO.Compression.ZipArchiveMode]::Create)
try {
 foreach($name in $files){[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,(Join-Path $package $name),$name,[IO.Compression.CompressionLevel]::Optimal) | Out-Null}
 $entry=$zip.CreateEntry('release-info.json')
 $writer=[IO.StreamWriter]::new($entry.Open())
 try {$writer.Write((@{product_version=$version;receiver_version=$version;license_status='MIT for project-authored code; third-party files retain original licenses';files=$hashes} | ConvertTo-Json -Depth 4))} finally {$writer.Dispose()}
} finally {$zip.Dispose()}
$zip=[IO.Compression.ZipFile]::OpenRead($zipPath)
try {
 if($zip.Entries.Count -ne ($files.Count+1)){throw 'Unexpected archive entry count'}
 foreach($name in $files){
  $entry=$zip.GetEntry($name);if(!$entry){throw "Missing $name"}
  $stream=$entry.Open();$sha=[Security.Cryptography.SHA256]::Create()
  try {$actual=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','')} finally {$sha.Dispose();$stream.Dispose()}
  if($actual -ne $hashes[$name]){throw "ZIP hash mismatch: $name"}
 }
} finally {$zip.Dispose()}
$zipHash=(Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
Set-Content -LiteralPath "$zipPath.sha256" -Value "$zipHash  $([IO.Path]::GetFileName($zipPath))" -Encoding ascii
Write-Output "PACKAGE_ALLOWLIST_AND_HASH_PASS: $zipPath"
Write-Output "SHA256: $zipHash"
