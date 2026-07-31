# Flutter Bluedot Point SDK Plugin release notes

## 2.2.0
- Updated to iOS PointSDK v18.0.0.
- Added iOS support to the optional `bluedot_point_sdk_push` package, including APNs registration, foreground delivery, notification-click events, and Dart listener buffering.

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
