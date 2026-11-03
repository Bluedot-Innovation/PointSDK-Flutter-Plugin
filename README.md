# Bluedot Flutter Plugin release notes

Flutter Bluedot Point SDK (bluedot_point_sdk) is a wrapper around the [Android Point SDK](https://docs.bluedot.io/android-sdk/) and [iOS Point SDK](https://docs.bluedot.io/ios-sdk/), allowing for Bluedot integrations in Flutter apps. 
Core location functionality is provided by `bluedot_point_sdk`. Add the optional
`bluedot_point_sdk_push` package for PointSDK push notifications on Android and iOS,
including notifications from location-triggered campaigns configured in Canvas.

## Documentation

- To check out the package documentation, visit our [docs website](https://docs.bluedot.io/flutter-library/).
- To see an implementation example refer to our [Flutter Minimal Integration Example](https://github.com/Bluedot-Innovation/Flutter-Minimal-Integration)
- Push notification setup for both platforms is documented in the [Integration Guide](https://github.com/Bluedot-Innovation/PointSDK-Flutter-Plugin/blob/main/PointSDK-Flutter-Push/INTEGRATION.md).

## Current Support

- Android API 29+
- iOS 15.0+
- Flutter 3.44.0+
- iOS PointSDK 19.0.0

## iOS Package Management

Starting with `bluedot_point_sdk 3.0.0`, the iOS plugin is distributed only
through Swift Package Manager. Flutter 3.44 or newer enables SwiftPM integration
for Flutter plugins. If it was disabled locally, enable it before rebuilding:

```bash
flutter config --enable-swift-package-manager
flutter clean
flutter pub get
```

An application may keep CocoaPods for unrelated plugins. The Bluedot core and
push plugins must resolve through SwiftPM. Applications that require Bluedot
CocoaPods support must remain on core 2.x and push 1.x.

## Questions

For questions and support please use our [Help Desk](https://bluedotinnovation.zendesk.com/)
