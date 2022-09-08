#import <Flutter/Flutter.h>

@interface BluedotPointSdkPlugin : NSObject<FlutterPlugin>
@end

@interface ObjC : NSObject
+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;
@end