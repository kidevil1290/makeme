# Makes the Canvas submission zip for MakeMe: source code, scripts and the
# prebuilt web app in release/, without build output, IDE folders or .git.
# Usage (from the project folder):
#   powershell -ExecutionPolicy Bypass -File .\package.ps1
# Run build_release.ps1 first, so release/ matches the latest code.

# Any error stops the script
$ErrorActionPreference = 'Stop'

# Work from the folder this script is in
Set-Location $PSScriptRoot

# 1. The packaged app must exist
if (-not (Test-Path "release\web\index.html")) {
    Write-Host "release\web\index.html not found. Run build_release.ps1 first."
    exit 1
}

# 2. Warn when any Dart file is newer than the packaged app, because the
#    zip would then contain an old version of the app.
$builtAt = (Get-Item "release\web\index.html").LastWriteTime
$newest = Get-ChildItem "lib" -Recurse -Filter *.dart |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($newest.LastWriteTime -gt $builtAt) {
    Write-Host "WARNING: $($newest.FullName)"
    Write-Host "was changed after release\web was built ($builtAt)."
    Write-Host "Run build_release.ps1 again, or the zip will hold an old app."
    $answer = Read-Host "Make the zip anyway? (y/N)"
    if ($answer -ne 'y') { exit 1 }
}

# 3. Copy only what the professor needs into a temporary folder.
#    A list of wanted items is safer than a list of unwanted ones,
#    because nothing unexpected can slip in.
$stage = Join-Path $env:TEMP "makeme_package"
$target = Join-Path $stage "makeme"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory $target | Out-Null

$folders = 'lib', 'test', 'web', 'assets', 'release',
           'android', 'ios', 'macos', 'windows', 'linux'
$files = 'pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml',
         'README.md', '.gitattributes', '.gitignore', '.metadata',
         'run.sh', 'run.bat', 'build_release.sh', 'build_release.ps1',
         'package.ps1'

foreach ($folder in $folders) {
    if (Test-Path $folder) {
        # robocopy skips the big generated folders inside the platform
        # folders. Exit codes below 8 mean success.
        robocopy $folder (Join-Path $target $folder) /E /NFL /NDL /NJH /NJS /NP `
            /XD build .gradle .dart_tool .idea Pods | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "Copying $folder failed" }
    }
}
foreach ($file in $files) {
    if (Test-Path $file) { Copy-Item $file $target }
}

# 4. Zip it. The zip goes next to the project folder, not inside it,
#    so it can never end up inside itself.
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = Join-Path (Split-Path $PSScriptRoot -Parent) "makeme_final.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
# true = keep the top folder "makeme" inside the zip
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $stage, $zipPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)

# 5. Check the zip. Old versions of Windows PowerShell write backslashes in
#    zip paths, which breaks the folders when a Mac unzips them.
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$entries = $zip.Entries.FullName
$zip.Dispose()
if ($entries | Where-Object { $_ -like '*\*' }) {
    Write-Host "WARNING: the zip contains backslash paths. A Mac may unzip"
    Write-Host "it into oddly named files."
}

Remove-Item $stage -Recurse -Force

$size = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
Write-Host ""
Write-Host "Done: $zipPath ($size MB, $($entries.Count) entries)"
Write-Host "Unzip it somewhere else and run run.bat to check it before submitting."