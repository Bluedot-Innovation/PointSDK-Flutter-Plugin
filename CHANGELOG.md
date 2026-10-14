# Flutter Bluedot Point SDK Plugin release notes

## 3.0.0
- Updated to Android PointSDK v19.0.0.
- **Breaking:** The Android Point SDK no longer starts, owns, or displays a foreground service notification for GeoTriggering/Tempo. Your app must now implement and own its own foreground `Service`, and link it to the Point SDK:
  - Removed `GeoTriggeringBuilder.androidNotification(...)` and `TempoBuilder.androidNotification(...)`.
  - Removed `BluedotPointSdk.setNotificationIcon(...)`.
  - Added `BluedotPointSdk.linkForegroundService()` / `unlinkForegroundService()` (Android only, no-op on iOS). Call `linkForegroundService()` once your own foreground service has successfully started (e.g. from its `onCreate()` after `startForeground()`), and `unlinkForegroundService()` when it stops. Both calls are idempotent (linking while already linked, or unlinking while not linked, is a no-op). Added `BluedotPointSdk.isForegroundServiceLinked()` (Android only, always `false` on iOS) to query the current link state.
  - GeoTriggering continues to run via a background worker regardless of whether a foreground service is linked; linking it is optional and only reduces location-update latency.
  - Tempo now **requires** a linked foreground service to start; starting Tempo without one fails synchronously. If the linked foreground service is lost while Tempo is tracking, Tempo stops and reports it asynchronously via the `tempoTrackingStoppedWithError` event, with the new `isForegroundServiceNotLinked: true` argument.
  - There is a single, shared link state (not one per feature) — apps using both GeoTriggering and Tempo should share one foreground service/link.
  - Added a native-Android helper, `io.bluedot.bluedot_point_sdk.BluedotForegroundServiceLinker` (with `link(context)` / `unlink(context)`, both idempotent, and `isForegroundServiceLinked(context)`), exposed by the plugin for your app's own foreground `Service` to call directly. Since the plugin already depends on the Point SDK internally, your app does **not** need to add its own `point_sdk_android` Gradle dependency just to link/unlink - avoiding a second SDK version to keep in sync.
  - See the updated example app (`example/lib/geo_triggering_page.dart`, `example/lib/tempo_page.dart`, and `example/android/app/src/main/kotlin/.../BluedotTrackingService.kt`) for a reference implementation of an app-owned foreground service using `BluedotForegroundServiceLinker`.

## 2.2.0
- Updated to iOS PointSDK v18.1.0.
- Added iOS support to the optional `bluedot_point_sdk_push` package, including APNs registration, foreground delivery, notification-click events, and Dart listener buffering.
- **Breaking:** Minimum Android API level raised from 19 to 29. Devices on Android 5–9 (API 21–28) are no longer supported.
- Updated to Android PointSDK v18.0.0.

## 2.1.4
- Updated to iOS PointSDK v17.2.1 for custom event metadata persistence after app termination.
- Android remains on PointSDK v17.4.1.

## 2.1.3
- Fixed an iOS crash when a GeoTriggering or Tempo event is delivered during a background app launch.

## 2.1.1
- Updated to Android Point SDK v17.4.1 and iOS Point SDK v17.2.0
- Added new GeoTriggering event `didDwellInZone`.

## 2.1.0
- Updated to Android Point SDK v17.3.0 and iOS Point SDK v17.1.0
- Fix added to reinit channels if it is null instead of crashing the App

## 2.0.1
- Updated to Android PointSDK v16.1.1

## 2.0.0
- Updated to latest PointSDK for both iOS v16.0.0 and Android v16.1.0

## 1.0.1
- Updated to latest iOS PointSDK 15.6.7 and Android PointSDK 15.5.3
- In Android, PointSDK by default will use `ic_stat_name` resource in res/drawable or res/mipmap of android folder as notification icon for GeoTriggering and Tempo foreground service notifications. 
- If you are using `setNotificationIdResourceId(int resourceId)` to set a custom icon for notification, change to `setNotificationIcon(String icon)` and make sure resource `icon` exists in either res/drawable or res/mipmap folder.   
