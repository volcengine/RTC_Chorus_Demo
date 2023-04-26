// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <UIKit/UIKit.h>
#import "ChorusSongModel.h"

typedef NS_ENUM(NSInteger, MusicControlState) {
    MusicControlStateNone = 0,
    MusicControlStateOriginal,
    MusicControlStateTuning,
    MusicControlStateNext,
};

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicControlView : UIView

@property (nonatomic, copy) void (^clickButtonBlock) (MusicControlState state,
                                                      BOOL isSelect,
                                                      BaseButton *button);

@property (nonatomic, assign) NSTimeInterval time;

/// 更新UI
- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
