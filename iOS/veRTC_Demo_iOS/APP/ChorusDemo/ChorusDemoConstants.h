//
//  LiveDemoConstants.h
//  Pods
//
//  Created by on 2022/4/29.
//

#ifndef LiveDemoConstants_h
#define LiveDemoConstants_h

#import "ChorusRTCManager.h"
#import "ChorusRTSManager.h"
#import "AlertActionManager.h"

#define HomeBundleName @"ChorusDemo"
#define XH_1PX_WIDTH (1 / [UIScreen mainScreen].scale)
#define HiFiveAppID @""
#define HiFiveServerCode @""
#define HiFiveGroupID @""

#define veString(key, ...) \
({ \
NSString *bundlePath = [[NSBundle mainBundle] pathForResource:HomeBundleName ofType:@"bundle"];\
NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];\
NSString *string = [resourceBundle localizedStringForKey:key value:nil table:nil];\
string == nil ? key : string; \
})

#endif /* LiveDemoConstants_h */
