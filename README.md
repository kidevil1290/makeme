# MakeMe's Progress
A gamified fitness application that aims to integrate a visual avatar and
progression system into conventional fitness applications core functionality.

## Team Members

| Member         | GitHub        |
|----------------|---------------|
| Scout Peterson | @ScoutPeterson|
| Karl Fernandez | @kidevil1290  |
| Moe Odaki      | @Moe175       |

## Run on hosted link via GitHub Pages (nothing to install)
https://kidevil1290.github.io/makeme-web/

## Run on local web server
1. Open a terminal in the project folder
2. Run script for your machine

### Mac (terminal)
Requires: Python 3 (macOS offers to install it)
The script will open in the machine's default browser, Chrome is recommended.
1. Run
```
bash run.sh
```
2. If macOS asks to install the Command Line Tools, install them and run it again.
3. If the browser says the page cannot be reached, wait a moment and refresh.

### Exiting the App
1. On the terminal press Ctrl + c

### Windows (Powershell)
Requires: Dart on the system's PATH (comes with Flutter)
Initial run will require internet
1. Run 
```
.\run.bat
```
2. If the browser says the page cannot be reached, wait a moment and refresh.
3. if run.bat fails, check that dart is in your machine and it works
```
dart --version
```

### Exiting the App
1. On the terminal press Ctrl + c and type y/Y

### Open On Any Browser
1. Leave the server running from the initial run.
2. Copy and paste the URL to the desired browser.

## Saved Data

### Hosted Link
Saved in the browser where it is opened.
Another browser starts empty

### Local Link
Saved in the browser for the address localhost:8080 (Windows) and 57100 (Mac).
Another browser or another port starts empty.

### How To Reset Data
1. Clear browser cookies and site data.
2. Close or reload.

## Developer Section

### Prerequisites (download and install these first)
1. Flutter SDK -> https://docs.flutter.dev/install
2. Android Studio (requires 5GB space) -> https://developer.android.com/studio
    - Follow recommended installation wizard
    - Open Android Studio -> SDK Manager (cog icon located top-right) -> SDK Tools 
    - Check: Android SDK Command-line Tools (Accept all)
    - Check: Android Emulator
3. Open any IDE
4. VS Code Required Extensions
    - Flutter (by Dart Code) - installs Dart Automatically
5. VS Code Optional Extensions
    - ErrorLens - shows errors inline while coding
    - Awesome Flutter Snippets - useful flutter shortcuts

### One-time Emulator Setup
1. Open Android Studio -> Virtual Device Manager
2. Click "Create Device"
3. Select Pixel 6 or Pixel 7
4. Download system image API 33 or 34
5. Click Finish
   
### Optional - iOS Simulator (Mac only)
Only needed to test on an iPhone Simulator:
1. Xcode -> Mac App Store
2. Run after Xcode installs:
```bash
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    sudo xcodebuild -runFirstLaunch
    sudo gem install cocoapods
```

## Setup After Cloning
A fresh clone does not include the release/ folder.
Build it first (see Updating The Local Web Server)
### Windows (Powershell)
```powershell
.\setup.ps1
```

### Mac (Terminal)
```bash
chmod +x setup.sh
./setup.sh
```

## Running the App
1. Open Android Studio -> Virtual Device Manager -> start emulator
2. In VS Code terminal:
```bash
flutter run
```
### Set Up from Zip File
Unzipped source shows red errors until dependencies are downloaded
1. Open a terminal in the project folder
2. Download all dependencies with
```
flutter pub get
```

## Updating the Local Web Server

### Windows (Powershell)
1. Ensure main is fully up to date with a clean working tree
2. Run 
```
powershell -ExecutionPolicy Bypass -File .\build_release.ps1
```

### Mac (Terminal)
1. Ensure main is fully up to date with a clean working tree
2. Run 
```
bash build_release.sh
```

## Packaging the Zip File (Windows Only)
1. Update the local web server
2. Run `powershell -ExecutionPolicy Bypass -File .\package.ps1`

## Run Tests
```
flutter test
```

## Project Structure
```
|-lib/              all Dart code lives here
    |-models/       data classes from UML diagram and app state
    |-screens/      full app screens/scene/pages that user navigates to
    |-widgets/      reusable UI components shared accross screens
    |-services/     logic, database operations, calculations
    |-theme/        app theme
    |-utils/        enums, asset path helpers
    |-app.dart      root widget, provider and screen switching
    |-main.dart     app entry point
|-assets/
    |-fonts/
    |-images/
    |-sounds/
    |-sprites/
|-pubspec.yaml      dependency manager
|-test/             unit tests                 
```
## AI Disclosure
AI tool, Claude, by Anthropic was used to clarify technical concepts that helped the team better understand and formulate system designs. It also assisted on debugging unfamiliar Dart or Flutter syntax, reducing the time required to resolve implementation issues. Additionally, scripts for automating the web build and application execution were generated to simplify access and facilitate project demonstration. 

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
