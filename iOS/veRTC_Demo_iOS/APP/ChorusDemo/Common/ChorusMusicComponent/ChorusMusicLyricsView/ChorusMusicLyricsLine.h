//
//  ChorusMusicLyricsLine.h
//  veRTC_Demo
//
//  Created by on 2022/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicLyricsLine : NSObject

@property (nonatomic, assign) NSTimeInterval startTime; // 毫秒

@property (nonatomic, copy) NSString * lrc;

@end

NS_ASSUME_NONNULL_END
