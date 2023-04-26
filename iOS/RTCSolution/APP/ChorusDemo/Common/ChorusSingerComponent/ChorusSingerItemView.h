// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusSingerItemView : UIView

@property (nonatomic, strong) ChorusUserModel * _Nullable userModel;

- (instancetype)initWithLocationRight:(BOOL)isRight;

/// 更新用户网络状态
/// @param status 网络状态
- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status;

/// 更新用户渲染画面
- (void)updateFirstVideoFrameRendered;

/// 更新用户说话声音动画
/// @param volume 说话音量
- (void)updateUserAudioVolume:(NSInteger)volume;

/// 独唱需要隐藏副唱位置“等待合唱者加入”文案
/// @param isHidden Hidden
- (void)hiddenEmptyLabel:(BOOL)isHidden;


@end

NS_ASSUME_NONNULL_END
