// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChorusSingingType) {
    /// 独唱
    ChorusSingingTypeSolo = 1,
    /// 合唱
    ChorusSingingTypeChorus = 2,
};

/// 等待合唱者加入
/// Wait for the chorus to join in
@interface ChorusWaitingSingerJoinView : UIView

@property (nonatomic, copy) void(^startSingingTypeBlock)(ChorusSingingType actionType);

- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
