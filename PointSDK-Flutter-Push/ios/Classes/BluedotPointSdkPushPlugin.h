#import <Flutter/Flutter.h>
#import <UserNotifications/UserNotifications.h>

@interface BluedotPointSdkPushPlugin : NSObject <FlutterPlugin>

/// Forwards a notification received in the foreground to PointSDK, and emits the
/// `onNotificationReceived` event to Dart when PointSDK owns the notification.
///
/// Call this from your AppDelegate's
/// `userNotificationCenter:willPresentNotification:withCompletionHandler:`.
///
/// @return YES when PointSDK handled the notification.
+ (BOOL)handleForegroundNotification:(UNNotification *)notification
    NS_SWIFT_NAME(handleForegroundNotification(_:));

/// Forwards a notification tap to PointSDK, and emits the `onNotificationClicked` event to Dart
/// when PointSDK owns the notification.
///
/// Call this from your AppDelegate's
/// `userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:`.
+ (void)handleNotificationResponse:(UNNotificationResponse *)response
    NS_SWIFT_NAME(handleNotificationResponse(_:));

@end
