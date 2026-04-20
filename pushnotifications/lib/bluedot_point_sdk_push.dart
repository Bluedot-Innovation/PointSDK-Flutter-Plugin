import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Push notifications support for the Bluedot Point SDK (Android only).
///
/// ### Setup
/// Add this package to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   bluedot_point_sdk_push:
///     path: ../push   # or a pub.dev version once published
/// ```
///
/// ### Receiving events
/// ```dart
/// MethodChannel(BluedotPointSdkPush.pushNotifications)
///   .setMethodCallHandler((call) async {
///     final data = Map<String, dynamic>.from(call.arguments as Map);
///     if (call.method == PushNotificationEvents.onNotificationReceived) {
///       // handle received notification
///     } else if (call.method == PushNotificationEvents.onNotificationClicked) {
///       // handle notification tap
///     }
///   });
/// ```
class BluedotPointSdkPush {
  static const _commandChannel =
      MethodChannel('bluedot_point_flutter/push_sdk');

  /// Event channel name for push notification callbacks (Android only).
  ///
  /// See [PushNotificationEvents] for the available event method names.
  static const pushNotifications =
      'bluedot_point_flutter/push_notification_events';

  static final instance = BluedotPointSdkPush();

  /// Configures a custom notification appearance for the Bluedot push
  /// notifications module (Android only — no-op on iOS).
  ///
  /// Call this early in the app lifecycle, before the first push notification
  /// arrives (e.g. right after `BluedotPointSdk.instance.initialize(...)`).
  ///
  /// ### Parameters
  /// - [channelId]   — Android notification channel ID (required).
  /// - [channelName] — Notification channel display name (required).
  /// - [icon]        — Drawable/mipmap resource name for the small icon.
  ///                   Falls back to the app launcher icon when omitted.
  /// - [importance]  — Android `NotificationManager.IMPORTANCE_*` constant.
  ///                   Defaults to `IMPORTANCE_DEFAULT` (3).
  ///
  /// The module fills in the notification title and body automatically from
  /// the message payload — do not set them here.
  Future<void> setCustomPushNotification({
    required String channelId,
    required String channelName,
    String? icon,
    int? importance,
  }) {
    if (!Platform.isAndroid) return Future.value();
    return _commandChannel.invokeMethod('setCustomPushNotification', {
      'channelId': channelId,
      'channelName': channelName,
      'icon': icon,
      'importance': importance,
    });
  }
}

/// Event method names fired on the [BluedotPointSdkPush.pushNotifications]
/// channel (Android only).
///
/// `call.arguments` is a `Map<String, dynamic>` with the following fields:
///
/// | Field            | Type                | Description                        |
/// |------------------|---------------------|------------------------------------|
/// | `title`          | `String`            | Notification title                 |
/// | `body`           | `String`            | Notification body text             |
/// | `pushVersion`    | `String`            | Push schema version                |
/// | `campaignId`     | `String`            | Campaign UUID                      |
/// | `zoneId`         | `String`            | Zone UUID                          |
/// | `notificationId` | `String`            | Notification UUID                  |
/// | `data`           | `Map<String,String>`| Custom key-value pairs from payload|
class PushNotificationEvents {
  static const onNotificationReceived = 'onNotificationReceived';
  static const onNotificationClicked  = 'onNotificationClicked';
}

