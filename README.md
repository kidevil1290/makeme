# makeme





## Team Members

| Member         | GitHub       |
|----------------|--------------|
| Scout Peterson | @            |
| Karl Fernandez | @kidevil1290 |
| Moe Odaki      | @Moe175      |

## Prerequisites (download and install these first)
1. Flutter SDK -> https://docs.flutter.dev/install
2. Android Studio (requires 5GB space) -> https://developer.android.com/studio
    - Follow recommended installation wizard
    - Open Adroid Studio -> SDK Manager (cog icon located top-right) -> SDK Tools 
    - Check: Android SDK Command-line Tools (Accept all)
    - Check: Android Emulator
3. Open any IDE
4. VS Code Required Extension
    - Flutter (by Dart Code) - installs Dart Automatically
    (optional)
    - ErrorLens - shows errors inline while coding
    - Awesome Flutter Snippers - useful flutter shortcuts

## Optional - iOS Simulator (Mac only)
Only needed to test on an iPhone Simulator:
1. Xcode -> Mac App Store
2. Run after Xcode installs:
```bash
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    sudo xcodebuild -runFirstLaunch
    sudo gem install cocoapods
```

## Setup After Cloning

### Windows
```powershell
.\setup.ps1
```

### Mac
```bash
chmod +x setup.sh
./setup.sh
```

## Running the App
1. Open Android Studio -> Virtual Device Manager -> start your emulator
2. In VS Code terminal:
```bash
flutter run
```

## Project Structure
```
|-lib/ -- all Dart code lives here
    |-models/       data classes from UML diagram (no UI)
    |-screens/      full app screens/scene/pages that user navigates to
    |-widgets/      reusable UI components shared accross screens
    |-services/     logic, database operations, calculations
    |-utils/        constants, enums, and helper functions
    |-main.dart     app entry point
assets/
    |-fonts/
    |-images/
    |-sounds/
    |-sprites/
pubspec.yaml - dependency manager
```



A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
