# `bluedot_point_sdk_push` — Android Integration Guide

## Overview

The `bluedot_point_sdk_push` Flutter plugin bridges the Bluedot push notifications module
to Flutter. Because a Flutter app may already use Firebase Cloud Messaging (FCM) for its own
purposes, **the plugin does not register a `FirebaseMessagingService`**. Instead, you wire up
FCM in your own app and forward the relevant events to the plugin with two method calls.

---

## Step 1 — Add the plugin

In your app's `pubspec.yaml`:

```yaml
dependencies:
  bluedot_point_sdk: ^2.0.0
  bluedot_point_sdk_push: ^1.0.0
```

---

## Step 2 — Set up Firebase

If your app doesn't use Firebase yet, follow the
[official Android FCM setup guide](https://firebase.google.com/docs/cloud-messaging/android/get-started)
to add Firebase to your project (`google-services.json`, `google-services` Gradle plugin, etc.).

> **Android 13 (API 33) and above:** You must declare `POST_NOTIFICATIONS` in your manifest
> and request it at runtime before notifications can be displayed.
> See the [Android documentation](https://developer.android.com/training/permissions/requesting).

---

## Step 3 — Implement `FirebaseMessagingService`

Create a `FirebaseMessagingService` subclass in your app's Android source and forward the two
FCM events to the plugin using `BluedotPushPlugin`:

```kotlin
// android/app/src/main/kotlin/com/yourcompany/yourapp/MyFirebaseMessagingService.kt

package com.yourcompany.yourapp

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import io.bluedot.bluedot_point_sdk_push.BluedotPushPlugin

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        // Forward the new token to Bluedot.
        BluedotPushPlugin.onNewFcmToken(token, this)

        // Add any other token-refresh handling here.
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // Let Bluedot handle its own messages first.
        // Returns true if the message was a Bluedot push notification.
        if (BluedotPushPlugin.onMessageReceived(remoteMessage, this)) return

        // Handle your own non-Bluedot FCM messages here.
    }
}
```

---

## Step 4 — Register the service in `AndroidManifest.xml`

Add the service declaration inside the `<application>` tag of your
`android/app/src/main/AndroidManifest.xml`:

```xml
<service
    android:name=".MyFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

> The `AppPushNotificationsReceiver` (required for event callbacks to Flutter) is registered
> automatically by the plugin's own manifest — no additional entry is needed for it.

---

## Step 5 — Listen for push notification events in Flutter

Set up the event listener early in your app, before any notifications can arrive
(e.g. in `main.dart` or your root widget's `initState`):

```dart
import 'package:flutter/services.dart';
import 'package:bluedot_point_sdk_push/bluedot_point_sdk_push.dart';

void _initPushListener() {
  const channel = MethodChannel(BluedotPointSdkPush.pushNotifications);
  channel.setMethodCallHandler((call) async {
    final data = Map<String, dynamic>.from(call.arguments as Map);
    switch (call.method) {
      case PushNotificationEvents.onNotificationReceived:
        // Notification delivered to the device.
        print('Received: ${data['title']} — ${data['body']}');
        print('Campaign: ${data['campaignId']}, Zone: ${data['zoneId']}');
        break;
      case PushNotificationEvents.onNotificationClicked:
        // User tapped the notification.
        print('Clicked: ${data['notificationId']}');
        break;
    }
  });
}
```

### Event payload fields

| Field            | Type                 | Description                             |
|------------------|----------------------|-----------------------------------------|
| `title`          | `String`             | Notification title                      |
| `body`           | `String`             | Notification body text                  |
| `pushVersion`    | `String`             | Push schema version                     |
| `campaignId`     | `String`             | Campaign UUID                           |
| `zoneId`         | `String`             | Zone UUID                               |
| `notificationId` | `String`             | Notification UUID                       |
| `data`           | `Map<String, String>`| Custom key-value pairs from the payload |
