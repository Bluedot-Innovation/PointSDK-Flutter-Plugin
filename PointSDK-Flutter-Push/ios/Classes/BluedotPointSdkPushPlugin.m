#import "BluedotPointSdkPushPlugin.h"

// Push notifications are Android-only. This iOS implementation is a no-op stub
// so the package can be included in cross-platform Flutter projects without errors.

@implementation BluedotPointSdkPushPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    // No-op on iOS.
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    result(FlutterMethodNotImplemented);
}

@end

