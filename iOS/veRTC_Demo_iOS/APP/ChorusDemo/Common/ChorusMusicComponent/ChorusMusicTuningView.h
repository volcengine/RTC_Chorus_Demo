//
//  ChorusMusicTuningView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicTuningView : UIView

- (void)resetUI;

/// 音频播放路由改变
- (void)updateAudioRouteChanged;

- (void)setMusicVolume:(NSInteger)volume;

@end

NS_ASSUME_NONNULL_END
