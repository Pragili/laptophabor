#!/usr/bin/env bash
# Generates the native platform runners (android/ios/macos/web/desktop) around
# the existing lib/ + pubspec.yaml, then fetches packages. Run once after
# unzipping. Requires the Flutter SDK on your PATH.
set -e

echo "==> Generating platform scaffolding with flutter create ..."
flutter create . --org com.laptopharbor --project-name laptopharbor \
  --platforms=android,ios,web,windows,macos,linux

echo "==> Fetching packages ..."
flutter pub get

# macOS apps are sandboxed and cannot make network calls (API requests or the
# Inter web font) without the network-client entitlement. Ensure it's present
# in both entitlement files (idempotent).
if [ -d macos/Runner ] && [ -x /usr/libexec/PlistBuddy ]; then
  for plist in macos/Runner/DebugProfile.entitlements macos/Runner/Release.entitlements; do
    /usr/libexec/PlistBuddy -c "Add :com.apple.security.network.client bool true" "$plist" 2>/dev/null \
      || /usr/libexec/PlistBuddy -c "Set :com.apple.security.network.client true" "$plist"
  done
  echo "==> macOS: network-client entitlement ensured."
fi

echo ""
echo "Done. Run it:"
echo "  • Web (no backend needed, mock mode on):   flutter run -d chrome"
echo "  • macOS desktop:                           flutter run -d macos"
echo "  • Android emulator:                        flutter run"
echo "  • Against the real API instead of mock:    flutter run --dart-define=MOCK=false"
