# Installs the Tsunagi host on Windows (preview).
#   irm https://macfixkou.github.io/tsunagi-host/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$version = 'v0.2.0-windows-preview'
$file = 'tsunagi-windows-x86_64.exe'
$want = 'f8db3b48314a5278cf16c689a137b3bbf2a5a7fe9298d5b225a9262dd05e9bd6'
$dir = Join-Path $env:LOCALAPPDATA 'Tsunagi'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$tmp = Join-Path $dir 'tsunagi.download'
Write-Host "Downloading $file ($version)..."
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/macfixkou/tsunagi-host/releases/download/$version/$file" -OutFile $tmp
$got = (Get-FileHash -Algorithm SHA256 $tmp).Hash.ToLower()
if ($got -ne $want) { Remove-Item $tmp; throw 'Checksum mismatch. Nothing was installed.' }
$exe = Join-Path $dir 'tsunagi.exe'
Move-Item -Force $tmp $exe
Write-Host "Installed: $exe"
Write-Host "Start it with:  & '$exe' host"
