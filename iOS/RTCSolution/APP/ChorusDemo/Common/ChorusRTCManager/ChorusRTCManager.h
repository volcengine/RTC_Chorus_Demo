// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusRTCManager.h"
#import "BaseRTCManager.h"

NS_ASSUME_NONNULL_BEGIN
/// 网络质量
/// Network quality
typedef NS_ENUM(NSInteger, ChorusNetworkQualityStatus) {
    ChorusNetworkQualityStatusNone,
    ChorusNetworkQualityStatusGood,
    ChorusNetworkQualityStatusBad,
};

/// 合唱状态
/// A chorus of state
typedef NS_ENUM(NSInteger, ChorusStatus) {
    ChorusStatusIdle,
    ChorusStatusPrepare,
    ChorusStatusSinging,
    ChorusStatusSingEnd,
};

@class ChorusRTCManager;
@protocol ChorusRTCManagerDelegate <NSObject>

/**
 * @brief 房间状态改变时的回调。 通过此回调，您会收到与房间相关的警告、错误和事件的通知。 例如，用户加入房间，用户被移出房间等。
 * @param manager GameRTCManager 模型
 * @param joinModel RTCJoinModel模型房间信息、加入成功失败等信息。
 */
- (void)chorusRTCManager:(ChorusRTCManager *)manager
      onRoomStateChanged:(RTCJoinModel *)joinModel;


/// 收到歌词同步信息回调
/// @param chorusRTCManager RTC manager
/// @param json 歌词进度时间
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onStreamSyncInfoReceived:(NSString *)json;

/// 伴奏播放完成回调
/// @param chorusRTCManager RTC manager
/// @param result 伴奏播放完成
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onSingEnded:(BOOL)result;

/// 伴奏播放进度回调
/// @param chorusRTCManager RTC manager
/// @param progress 播放进度 毫秒
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onAudioMixingPlayingProgress:(NSInteger)progress;

/// 网络状况改变回调
/// @param chorusRTCManager RTC manager
/// @param status 网络状况
/// @param userID UserID
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onNetworkQualityStatus:(ChorusNetworkQualityStatus)status userID:(NSString *)userID;

/// 首帧渲染回调
/// @param chorusRTCManager RTC manager
/// @param userID UserID
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onFirstVideoFrameRenderedWithUserID:(NSString *)userID;

/// 用户音量变化回调
/// @param chorusRTCManager RTC manager
/// @param volumeInfo 用户音量信息{ UserID : 音量大小 }
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onReportUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo;

/// 用户音频播放路由改变回调
/// @param chorusRTCManager RTC manager
- (void)chorusRTCManagerOnAudioRouteChanged:
    (ChorusRTCManager *_Nonnull)chorusRTCManager;

@end

@interface ChorusRTCManager : BaseRTCManager

@property (nonatomic, weak) id<ChorusRTCManagerDelegate> delegate;

/// 是否可以开启耳返
@property(nonatomic, assign, readonly) BOOL canEarMonitor;

/// 是否开启摄像头
@property (nonatomic, assign, readonly) BOOL isCameraOpen;

/// 是否开启摄像头
@property (nonatomic, assign, readonly) BOOL isMicrophoneOpen;

/*
 * RTC Manager Singletons
 */
+ (ChorusRTCManager *_Nullable)shareRtc;

#pragma mark - Base Method

/// 加入房间
/// @param token RTC token
/// @param roomID RoomID
/// @param userID UserID
/// @param isHost Host
- (void)joinChannelWithToken:(NSString *)token
                      roomID:(NSString *)roomID
                      userID:(NSString *)userID
                      isHost:(BOOL)isHost;

/*
 * Switch local audio capture
 * @param enable ture:Turn on audio capture false：Turn off audio capture
 */
- (void)enableLocalAudio:(BOOL)enable;

- (void)enableLocalVideo:(BOOL)enable;

/// 切换身份成为演唱者（上下麦）
/// @param isSinger 是否是演唱者
- (void)switchIdentifyBecomeSinger:(BOOL)isSinger;

/*
 * Leave the room
 */
- (void)leaveChannel;

#pragma mark - Render & audio

/// 根据UserID获取渲染视图
/// @param userID User id
- (UIView *)getStreamViewWithUserID:(NSString *)userID;

/// 根据用户ID生成渲染视图
/// @param userID User id
- (void)bingCanvasViewToUserID:(NSString *)userID;

/// 更新音视频订阅状态
/// @param status 合唱状态
- (void)updateAudioSubscribeWithChorusStatus:(ChorusStatus)status;

/// 更新副唱混音状态
/// @param status 当前合唱状态
- (void)updateSuccentorAudioMixingWithChorusState:(ChorusStatus)status;

#pragma mark - Singing Music Method

/*
 * Modify the collection volume
 */
- (void)setRecordingVolume:(NSInteger)volume;

/*
 * Modify the background music volume
 */
- (void)setMusicVolume:(NSInteger)volume;


- (void)startAudioMixingWithFilePath:(NSString *)filePath;

- (void)stopSinging;

- (void)setVoiceReverbType:(ByteRTCVoiceReverbType)reverbType;

- (void)sendStreamSyncTime:(NSString *)time;

- (void)switchAccompaniment:(BOOL)isAccompaniment;

- (void)enableEarMonitor:(BOOL)isEnable;

- (void)setEarMonitorVolume:(NSInteger)volume;

@end

NS_ASSUME_NONNULL_END
