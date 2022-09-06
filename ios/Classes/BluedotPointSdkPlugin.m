#import "BluedotPointSdkPlugin.h"
#if __has_include(<bluedot_point_sdk/bluedot_point_sdk-Swift.h>)
#import <bluedot_point_sdk/bluedot_point_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bluedot_point_sdk-Swift.h"
#endif

@implementation BluedotPointSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBluedotPointSdkPlugin registerWithRegistrar:registrar];
}
@end


@implementation ObjC
+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
        return NO;
    }
}
@end
