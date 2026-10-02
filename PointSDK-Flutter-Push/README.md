# bluedot_point_sdk_push

Optional push notifications module for the [Bluedot Point SDK Flutter plugin](https://pub.dev/packages/bluedot_point_sdk).

Adds PointSDK push notifications on Android and iOS, including notifications from location-triggered
campaigns configured in Bluedot Canvas.

This package is optional — `bluedot_point_sdk` does not depend on it. Add it only if your app uses
PointSDK push notifications. It is versioned independently of the core plugin.

## Install

```yaml
dependencies:
  bluedot_point_sdk: ^2.2.0
  bluedot_point_sdk_push: ^1.0.0
```

## Usage

Register the listener **before** requesting notification permission, so a notification that launches
the app is still delivered once Dart is ready. On iOS the plugin buffers events until the listener is
registered.

```dart
import 'package:bluedot_point_sdk_push/bluedot_point_sdk_push.dart';

await BluedotPointSdkPush.instance.setNotificationListener(
  onReceived: (data) => print('Received: ${data['title']} — ${data['body']}'),
  onClicked:  (data) => print('Clicked: ${data['notificationId']}'),
);
```

On iOS, register with APNs once notification permission has been granted:

```dart
final status = await Permission.notification.request();
if (status.isGranted || status.isProvisional) {
  await BluedotPointSdkPush.instance.registerForRemoteNotifications();
}
```

On Android, FCM registration is managed by Firebase and this call is not needed.

## Platform setup

Both platforms need configuration beyond the package itself — APNs credentials, the Push
Notifications capability and entitlements on iOS; Firebase and a `google-services.json` on Android.
The host app also owns the notification delegate callbacks on iOS and forwards them to PointSDK.

See the **[Integration Guide](https://github.com/Bluedot-Innovation/PointSDK-Flutter-Plugin/blob/main/PointSDK-Flutter-Push/INTEGRATION.md)**
for the full setup, including the three Android FCM integration patterns.

## Event payload

`onReceived` and `onClicked` both receive a map with the same keys on both platforms.

| Field | Type | Description |
|---|---|---|
| `title` | `String` | Notification title |
| `body` | `String` | Notification body text |
| `pushVersion` | `String` | PointSDK push schema version |
| `campaignId` | `String` | Campaign UUID |
| `zoneId` | `String` | Zone UUID |
| `notificationId` | `String` | Notification UUID |
| `data` | `Map<String, String>` | Additional payload values |

## Requirements

- Dart 3.0 or later, Flutter 3.0 or later
- iOS 15.0 or later
- Android API 29 or later
- `bluedot_point_sdk` 2.2.0 or later

## Support

Questions and support: [Bluedot Help Desk](https://bluedotinnovation.zendesk.com/)
