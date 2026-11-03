#import <Foundation/Foundation.h>

@interface BluedotPointSdkExceptionCatcher : NSObject
+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;
@end