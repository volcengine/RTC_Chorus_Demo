// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#ifndef LiveDemoConstants_h
#define LiveDemoConstants_h

#import "ChorusRTCManager.h"
#import "ChorusRTSManager.h"

#define HomeBundleName @"ChorusDemo"

/*
 HiFiveAppID 歌曲下载使用
 用来确认服务端有这个APPID的所有权
 https://open.hifiveai.com/api/base/V4.1.2/baseClient/startIntro
 */
#define HiFiveAppID @""

/*
 HiFiveServerCode 歌曲下载使用
 用来确认服务端有这个APPID的所有权
 https://open.hifiveai.com/api/base/V4.1.2/baseClient/startIntro
 */
#define HiFiveServerCode @""

/*
 歌曲下载使用
 电台 ID
 https://account.hifiveai.com/admin/song/operateList
 */
#define HiFiveGroupID @""

#define XH_1PX_WIDTH (1 / [UIScreen mainScreen].scale)

#define veString(key, ...) \
({ \
NSString *bundlePath = [[NSBundle mainBundle] pathForResource:HomeBundleName ofType:@"bundle"];\
NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];\
NSString *string = [resourceBundle localizedStringForKey:key value:nil table:nil];\
string == nil ? key : string; \
})

#endif /* LiveDemoConstants_h */
