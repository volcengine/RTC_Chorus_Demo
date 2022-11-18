//
//  ChorusMusicLyricsInfo.h
//  veRTC_Demo
//
//  Created by on 2022/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ChorusMusicLyricsLine;
@interface ChorusMusicLyricsInfo : NSObject

@property (nonatomic, copy) NSArray<ChorusMusicLyricsLine *> * lrcArray;

@property (nonatomic, assign, readonly) NSUInteger numberOfLines;

@end

NS_ASSUME_NONNULL_END
