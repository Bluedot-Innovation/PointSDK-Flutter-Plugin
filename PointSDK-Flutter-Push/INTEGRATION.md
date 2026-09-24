# `bluedot_point_sdk_push` — Integration Guide

The `bluedot_point_sdk_push` package adds PointSDK push notifications to a Flutter app on both
Android and iOS, including notifications from location-triggered campaigns configured in
Bluedot Canvas. It is optional — the core `bluedot_point_sdk` package does not depend on it.

- [Add the package](#1--add-the-package)
- [Listen for events in Dart](#2--listen-for-events-in-dart)
- [Android setup](#3--android-setup)
- [iOS setup](#4--ios-setup)
- [Event payload](#event-payload)
- [Location-triggered campaigns](#location-triggered-campaigns)

---

## 1 — Add the package

```yaml
dependencies:
  bluedot_point_sdk: ^2.2.0
  bluedot_point_sdk_push: ^2.2.0
```

---

## 2 — Listen for events in Dart

Register the listener **before** requesting notification permission, so a notification that
launches the app is still delivered once Dart is ready. On iOS the plugin buffers events until
the listener is registered.

```dart
import 'package:bluedot_point_sdk_push/bluedot_point_sdk_push.dart';

await BluedotPointSdkPush.instance.setNotificationListener(
  onReceived: (data) => print('Received: ${data['title']} — ${data['body']}'),
  onClicked:  (data) => print('Clicked: ${data['notificationId']}'),
);
```

Call `removeNotificationListener()` to unregister both callbacks.

---

## 3 — Android setup

### 3.1 Prerequisites

- A [Firebase](https://console.firebase.google.com/) project with an Android app registered.
- The registered package name must match your `applicationId`.
- **Android 13 (API 33) and above:** declare and request `POST_NOTIFICATIONS` at runtime before
  notifications can be displayed.
- A Bluedot Canvas project with a push campaign configured.

### 3.2 Registering for push

The package handles FCM automatically. It registers two components in its own manifest, so no
manifest entries are needed in your app:

| Component | Purpose |
|---|---|
| `DefaultMessagingService` | Receives FCM messages. Declared at intent-filter priority `-1`. |
| `AppPushNotificationsEventReceiver` | Bridges PointSDK callbacks to Flutter. |

Because `DefaultMessagingService` sits at priority `-1` and the Android default is `0`, **any
`FirebaseMessagingService` your app declares takes precedence and Bluedot's service is never
reached.** That gives three integration patterns:

**Pattern A — no FCM in your app (automatic).**
Nothing to do. `DefaultMessagingService` receives messages and forwards Bluedot ones.

**Pattern B — you already use `firebase_messaging`.**
Your service pre-empts the default one, so forward the relevant events yourself:

```dart
FirebaseMessaging.onMessage.listen((message) {
  BluedotPointSdkPush.instance.onMessageReceived(message.data);
});

FirebaseMessaging.instance.onTokenRefresh.listen((token) {
  BluedotPointSdkPush.instance.onNewFcmToken(token);
});
```

Both calls are harmless on iOS.

**Pattern C — native FCM in your own `FirebaseMessagingService`.**
Forward from Kotlin instead:

```kotlin
import io.bluedot.pushnotifications.BluedotPushPlugin

override fun onMessageReceived(remoteMessage: RemoteMessage) {
    // Returns true if the message was a Bluedot push notification.
    if (BluedotPushPlugin.onMessageReceived(remoteMessage, this)) return
    // Handle your own messages here.
}

override fun onNewToken(token: String) {
    BluedotPushPlugin.onNewFcmToken(token, this)
}
```

To remove Bluedot's default service from the merged manifest entirely, add a `service` element
targeting `io.bluedot.pushnotifications.DefaultMessagingService` with `tools:node="remove"`.

---

## 4 — iOS setup

### 4.1 Prerequisites

- An Apple Developer App ID and provisioning profile with the **Push Notifications** capability.
- A bundle identifier matching that App ID.
- **Background Modes → Remote notifications** enabled.
- An APNs authentication key or certificate configured for the app in Bluedot Canvas.
- The iOS deployment target set to 15.0 or later.
- **A physical device.** APNs registration and location-triggered delivery cannot be validated
  on the simulator.

### 4.2 Registering for push

The plugin forwards the APNs device token to PointSDK automatically, but it deliberately does
**not** implement `UNUserNotificationCenterDelegate`. Flutter forwards those callbacks to every
registered plugin with the *same* completion handler, so a plugin completing them can race with
your app or another plugin completing them too. Your app owns them instead — which also means
your app decides the presentation options for notifications it or another provider owns.

In your `AppDelegate`:

```swift
import Flutter
import UserNotifications
import bluedot_point_sdk_push

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for UNUserNotificationCenter callbacks to reach this delegate.
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let handled = BluedotPointSdkPushPlugin.handleForegroundNotification(notification)
    // Your choice — the plugin does not impose presentation options.
    completionHandler(handled ? [.banner, .list, .sound, .badge] : [.banner, .list])
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    BluedotPointSdkPushPlugin.handleNotificationResponse(response)
    completionHandler()
  }
}
```

> **Do not call `super` in the two methods above** while also completing the handler yourself.
> `FlutterAppDelegate` forwards them to every plugin, and if any plugin also completes the
> handler it is invoked twice, which iOS treats as an error. If another plugin in your app needs
> these callbacks, reconcile the completion between them and complete it exactly once.

### 4.3 Requesting permission

Request notification permission, then register with APNs **only if it was granted**:

```dart
import 'package:permission_handler/permission_handler.dart';
import 'package:bluedot_point_sdk_push/bluedot_point_sdk_push.dart';

final status = await Permission.notification.request();
if (status.isGranted || status.isProvisional) {
  await BluedotPointSdkPush.instance.registerForRemoteNotifications();
}
```

### 4.4 Build

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

## Event payload

`onReceived` and `onClicked` both receive a `Map<String, dynamic>`. The keys are identical on
Android and iOS.

| Field | Type | Description |
|---|---|---|
| `title` | `String` | Notification title |
| `body` | `String` | Notification body text |
| `pushVersion` | `String` | PointSDK push schema version |
| `campaignId` | `String` | Campaign UUID |
| `zoneId` | `String` | Zone UUID |
| `notificationId` | `String` | Notification UUID |
| `data` | `Map<String, String>` | Additional payload values |

---

## Location-triggered campaigns

Configure the campaign and its zone entry, exit, or dwell trigger in Bluedot Canvas. The
application must initialize PointSDK and start Geo-triggering for location-triggered
notifications to be delivered.
