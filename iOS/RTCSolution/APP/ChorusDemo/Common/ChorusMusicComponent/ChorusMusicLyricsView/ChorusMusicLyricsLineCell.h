// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChorusMusicLyricsLine;
@interface ChorusMusicLyricsLineCell : UITableViewCell

+ (NSString *)reuseIdentifier;

- (void)fillLyricsLine:(ChorusMusicLyricsLine *)lyricsLine;
- (void)showHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
