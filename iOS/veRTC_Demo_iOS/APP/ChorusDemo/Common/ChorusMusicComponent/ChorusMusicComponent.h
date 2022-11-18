//
//  ChorusMusicComponent.h
//  veRTC_Demo
//
//  Created by on 2021/11/30.
//  
//

#import <Foundation/Foundation.h>
#import "ChorusUserModel.h"
#import "ChorusSongModel.h"
@class ChorusMusicComponent;

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicComponent : NSObject

- (instancetype)initWithSuperView:(UIView *)view;

/// 准备伴奏歌词等物料
/// @param songModel 歌曲信息
- (void)prepareMaterialsWithSongModel:(ChorusSongModel *)songModel;

/// 开始进入演唱准备阶段（等待合唱者加入），此方法会调用prepareMaterialsWithSongModel
/// @param songModel 歌曲Model
/// @param leadSingerUserModel 主唱信息
- (void)prepareStartSingSong:(ChorusSongModel *_Nullable)songModel
         leadSingerUserModel:(ChorusUserModel *_Nullable)leadSingerUserModel;

/// 真正开始演唱
/// @param songModel songModel
- (void)reallyStartSingSong:(ChorusSongModel *)songModel;

/// 歌曲播放结束
- (void)stopSong;

/// 展示歌曲播放结束UI
/// @param nextSongModel 下一首歌曲信息
- (void)showSongEndWithNextSongModel:(ChorusSongModel * _Nullable)nextSongModel;

/// Update current song progress
/// @param songTime song progress
- (void)updateCurrentSongTime:(NSInteger)songTime;

/// 发送歌曲当前播放时长
/// @param songTime 歌曲播放时长
- (void)sendSongTime:(NSInteger)songTime;

/// 关闭调音界面
- (void)dismissTuningPanel;

/// 更新演唱者网络质量
/// @param status 网络质量
/// @param uid 用户ID
- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status uid:(NSString *)uid;

/// 用户首帧渲染完成后刷新展示UI
/// @param uid 用户ID
- (void)updateFirstVideoFrameRenderedWithUid:(NSString *)uid;

/// 更新用户说话声音动画
/// @param dict 用户ID : 说话音量
- (void)updateUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *)dict;

/// 音频播放路由改变
- (void)updateAudioRouteChanged;

@end

NS_ASSUME_NONNULL_END
