// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 展示用户画面以及网络状况
/// Display the user screen and network status
@interface ChorusSingerComponent : NSObject

@property (nonatomic, strong) UIView *backgroundView;

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)updateSingerUIWithChorusStatus:(ChorusStatus)status;

/// 更新演唱者网络质量
/// @param status 网络质量
/// @param uid 用户ID
- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status uid:(NSString *)uid;

/// 用户首帧渲染完成后刷新展示UI
/// @param uid 用户ID
- (void)updateFirstVideoFrameRenderedWithUid:(NSString *)uid;

/// 更新用户说话声音动画
/// @param dict 用户ID ： 说话音量
- (void)updateUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *)dict;

@end

NS_ASSUME_NONNULL_END
