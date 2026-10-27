Write-Host "Checking Flutter installation..."
if(!(Get-Command flutter - ErrorAction SilentlyContinue))
{
    Write-Host "Flutter not found. Please install Flutter from https://docs.flutter.dev/install"
    exit 1
}

Write-Host "Installing project dependencies..."
flutter pub get

Write-Host "Running Flutter doctor..."
flutter doctor

Write-Host "Available emulators:"
flutter emulators

Write-Host ""
Write-Host ""Setup Complete!""
Write-Host "Next Steps:"
Write-Host " 1. Start your Android emulator in Android Studio"
Write-Host " 2. Run: flutter run"