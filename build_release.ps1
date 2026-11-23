# Builds the web version of MakeMe and copies it into release/web, which is
# the folder that run.sh and run.bat serve.
# Usage (from the project folder):  .\build_release.ps1
# If Windows blocks the script, run it like this instead:
#   powershell -ExecutionPolicy Bypass -File .\build_release.ps1

# Any error stops the script, so a failed build never touches release/
$ErrorActionPreference = 'Stop'

# Work from the folder this script is in, wherever it is started from
Set-Location $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Flutter was not found. Install it first (see the README)."
    exit 1
}

Write-Host "Building the web version..."
flutter build web --release
# Native commands do not throw on failure, so the exit code is checked by hand
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. release/ was not changed."
    exit 1
}

# The build must have produced an index.html, or something went wrong
if (-not (Test-Path "build\web\index.html")) {
    Write-Host "build\web\index.html is missing. release/ was not changed."
    exit 1
}

# Replace the old copy only now that the new build is known to be good
if (Test-Path "release") { Remove-Item "release" -Recurse -Force }
New-Item -ItemType Directory "release" | Out-Null
Copy-Item "build\web" "release\web" -Recurse

Write-Host ""
Write-Host "Done. release\web is up to date."
Write-Host "Test it with run.bat, then clear site data for localhost:8080."