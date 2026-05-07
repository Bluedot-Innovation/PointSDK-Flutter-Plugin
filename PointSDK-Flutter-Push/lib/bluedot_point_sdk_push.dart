import 'package:flutter/services.dart';

/// Called when a Bluedot push notification is received in the foreground.
typedef NotificationReceivedHandler = void Function(Map<String, dynamic> data);

/// Called when the user taps a Bluedot push notification.
typedef NotificationClickedHandler = void Function(Map<String, dynamic> data);

/// ### Receiving events
/// ```dart
/// BluedotPointSdkPush.instance.setNotificationListener(
///   onReceived: (data) => print('Received: $data'),
///   onClicked:  (data) => print('Clicked: $data'),
/// );
/// ```
class BluedotPointSdkPush {
  BluedotPointSdkPush._();
  static final instance = BluedotPointSdkPush._();

  /// Event channel name for push notification callbacks.
  ///
  /// See [PushNotificationEvents] for the available event method names.
  static const pushNotifications = 'bluedot_point_flutter/push_notification_events';

  static const _eventsChannel  = MethodChannel(pushNotifications);
  static const _commandChannel = MethodChannel('bluedot_point_flutter/push_sdk');

  /// Register callbacks for push notification events.
  ///
  /// Both parameters are optional — pass only the ones you need.
  void setNotificationListener({
    NotificationReceivedHandler? onReceived,
    NotificationClickedHandler? onClicked,
  }) {
    _eventsChannel.setMethodCallHandler((call) async {
      final data = Map<String, dynamic>.from(call.arguments as Map);
      switch (call.method) {
        case PushNotificationEvents.onNotificationReceived:
          onReceived?.call(data);
          break;
        case PushNotificationEvents.onNotificationClicked:
          onClicked?.call(data);
          break;
      }
    });
  }

  /// Remove all push notification listeners.
  void removeNotificationListener() {
    _eventsChannel.setMethodCallHandler(null);
  }

  /// Forward a new FCM token to the Bluedot push module.
  ///
  /// Call this from your `FirebaseMessaging.instance.onTokenRefresh` listener
  /// when your app manages FCM directly (e.g. via the `firebase_messaging` package).
  ///
  /// Android only — no-op on iOS.
  Future<void> onNewFcmToken(String token) async {
    await _commandChannel.invokeMethod('onNewFcmToken', {'token': token});
  }

  /// Forward an incoming FCM message to the Bluedot push module.
  ///
  /// Call this from your `FirebaseMessaging.onMessage` / `onBackgroundMessage` handler
  /// when your app manages FCM directly (e.g. via the `firebase_messaging` package).
  /// Bluedot will silently ignore messages that are not Bluedot push notifications.
  ///
  /// Pass `remoteMessage.data` (the data payload map from the FCM message).
  /// Bluedot push notifications carry all fields inside the data payload, so
  /// the notification title/body and Bluedot-specific fields are all present there.
  ///
  /// Example:
  /// ```dart
  /// FirebaseMessaging.onMessage.listen((remoteMessage) {
  ///   BluedotPointSdkPush.instance.onMessageReceived(remoteMessage.data);
  /// });
  /// ```
  ///
  /// Android only — no-op on iOS.
  Future<void> onMessageReceived(Map<String, dynamic> message) async {
    await _commandChannel.invokeMethod('onMessageReceived', message);
  }
}

/// Event method names fired on the [BluedotPointSdkPush.pushNotifications]
/// channel.
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

