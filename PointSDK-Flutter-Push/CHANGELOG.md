# `bluedot_point_sdk_push` release notes

## 2.0.0

- **Breaking:** requires `bluedot_point_sdk` `^3.0.0` (core bumped its native Android dependency to
  PointSDK 19.0.0; the push module's native Maven coordinates must match). Apps staying on
  `bluedot_point_sdk` 2.x should keep using `bluedot_point_sdk_push` 1.x.

## 1.0.0

- Initial release — PointSDK push notifications for Flutter on Android and iOS, including
  notifications from location-triggered campaigns configured in Bluedot Canvas.
- Android: notifications delivered over Firebase Cloud Messaging. A default messaging service is
  registered automatically; apps that run their own can forward messages to the plugin instead.
- iOS: APNs registration, foreground delivery and notification-tap events. The host app owns the
  `UNUserNotificationCenter` callbacks and forwards them to PointSDK.
- Versioned independently of `bluedot_point_sdk`, which it requires at `^2.2.0` or later (see
  2.0.0 for the 3.0.0-compatible release).
