@echo off
REM Generates native platform runners around the existing lib/ + pubspec.yaml.
REM Requires the Flutter SDK on your PATH. Run once after unzipping.
echo ==^> Generating platform scaffolding with flutter create ...
flutter create . --org com.laptopharbor --project-name laptopharbor --platforms=android,ios,web,windows,macos,linux
echo ==^> Fetching packages ...
flutter pub get
echo.
echo Done. Run it:
echo   Web (no backend, mock mode on):  flutter run -d chrome
echo   Android emulator:                flutter run
echo   Against real API:                flutter run --dart-define=MOCK=false
