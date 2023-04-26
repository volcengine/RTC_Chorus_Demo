// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ChorusMusicLyricsLine;
@interface ChorusMusicLyricsInfo : NSObject

@property (nonatomic, copy) NSArray<ChorusMusicLyricsLine *> * lrcArray;

@property (nonatomic, assign, readonly) NSUInteger numberOfLines;

@end

NS_ASSUME_NONNULL_END
