#!/bin/bash
echo " Checking Flutter Installation..."
if ! command -v flutter &> /dev/null; 
    then echo "Flutter not found. Please install Flutter from https://docs.flutter.dev/install"
    exit 1

fi

echo "Installing project dependencies"
flutter pub get

echo "Running Flutter doctor"
flutter doctor

echo "Available Emulators"
flutter emulators

echo ""
echo "Setup Complete!"
echo "Next Steps:"
echo " 1. Start your Android emulator in Android Studio"
echo " 2. Run: flutter run"