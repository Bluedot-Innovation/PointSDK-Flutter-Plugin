# `bluedot_point_sdk_push` release notes

## 1.0.0

- Initial release — PointSDK push notifications for Flutter on Android and iOS, including
  notifications from location-triggered campaigns configured in Bluedot Canvas.
- Android: notifications delivered over Firebase Cloud Messaging. A default messaging service is
  registered automatically; apps that run their own can forward messages to the plugin instead.
- iOS: APNs registration, foreground delivery and notification-tap events. The host app owns the
  `UNUserNotificationCenter` callbacks and forwards them to PointSDK.
- Versioned independently of `bluedot_point_sdk`, which it requires at `^2.2.0` or later.
