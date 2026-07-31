# `bluedot_point_sdk_push` — iOS integration guide

The push package supports PointSDK push notifications on iOS, including location-triggered campaigns configured in Bluedot Canvas. No PointSDK-specific AppDelegate implementation is required.

## Add the packages

```yaml
dependencies:
  bluedot_point_sdk: ^2.2.0
  bluedot_point_sdk_push: ^2.2.0
```

## Configure the iOS application

1. Set the deployment target to iOS 15.0 or later.
2. Enable the **Push Notifications** capability in Xcode.
3. Enable **Background Modes > Remote notifications**.
4. Use an APNs-enabled App ID and provisioning profile.
5. Configure the matching bundle identifier and APNs credentials in Bluedot Canvas.

## Configure Dart

Install the listener before requesting permission so an event that opens the app can be delivered after Dart is ready.

```dart
import 'package:bluedot_point_sdk_push/bluedot_point_sdk_push.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> configurePushNotifications() async {
  await BluedotPointSdkPush.instance.setNotificationListener(
    onReceived: (data) {
      print('Received: ${data['title']} — ${data['body']}');
    },
    onClicked: (data) {
      print('Clicked: ${data['notificationId']}');
    },
  );

  final status = await Permission.notification.request();
  if (status.isGranted || status.isProvisional) {
    await BluedotPointSdkPush.instance.registerForRemoteNotifications();
  }
}
```

The plugin automatically forwards the APNs token, foreground notifications, and notification responses to PointSDK. Valid PointSDK notifications received in the foreground use banner, list, sound, and badge presentation options.

## Event payload

| Field | Type | Description |
|---|---|---|
| `title` | `String` | Notification title |
| `body` | `String` | Notification body |
| `pushVersion` | `String` | PointSDK push schema version |
| `campaignId` | `String` | Campaign UUID |
| `zoneId` | `String` | Zone UUID |
| `notificationId` | `String` | Notification UUID |
| `data` | `Map<String, String>` | Additional payload values |

## Location-triggered notifications

Configure the campaign and its zone entry, exit, or dwell trigger in Bluedot Canvas. The application must initialize PointSDK and start Geo-triggering. Test APNs registration and location-triggered delivery on a physical iOS device.
