#import "BluedotPointSdkPushPlugin.h"
#if __has_include(<bluedot_point_sdk_push/bluedot_point_sdk_push-Swift.h>)
#import <bluedot_point_sdk_push/bluedot_point_sdk_push-Swift.h>
#else
#import "bluedot_point_sdk_push-Swift.h"
#endif

@implementation BluedotPointSdkPushPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    [SwiftBluedotPointSdkPushPlugin registerWithRegistrar:registrar];
}

+ (BOOL)handleForegroundNotification:(UNNotification *)notification {
    return [SwiftBluedotPointSdkPushPlugin handleForegroundNotification:notification];
}

+ (void)handleNotificationResponse:(UNNotificationResponse *)response {
    [SwiftBluedotPointSdkPushPlugin handleNotificationResponse:response];
}

@end
