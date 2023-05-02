# Flutter Bluedot Point SDK Plugin release notes

## 1.0.1
- Updated to latest iOS PointSDK 15.6.7 and Android PointSDK 15.5.3
- In Android, PointSDK by default will use `ic_stat_name` resource in res/drawable or res/mipmap of android folder as notification icon for GeoTriggering and Tempo foreground service notifications. 
- If you are using `setNotificationIdResourceId(int resourceId)` to set a custom icon for notification, change to `setNotificationIcon(String icon)` and make sure resource `icon` exists in either res/drawable or res/mipmap folder.   

