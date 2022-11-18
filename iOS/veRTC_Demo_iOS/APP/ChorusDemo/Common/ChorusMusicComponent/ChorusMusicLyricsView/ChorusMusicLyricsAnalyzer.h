//
//  ChorusMusicLyricsAnalyzer.h
//  veRTC_Demo
//
//  Created by on 2022/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ChorusMusicLyricsInfo;
@interface ChorusMusicLyricsAnalyzer : NSObject

+ (nullable ChorusMusicLyricsInfo *)analyzeLrcByPath:(NSString *)path error:(NSError * _Nullable *)error;

+ (ChorusMusicLyricsInfo *)analyzeLrcBylrcString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
