// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusDataManager.h"

@interface ChorusRTCManager () <ByteRTCVideoDelegate, ByteRTCAudioFrameObserver>
// RTC / RTS 房间
@property (nonatomic, strong, nullable) ByteRTCRoom *rtcRoom;

@property (nonatomic, assign) int audioMixingID;

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *streamViewDic;

// 副唱是否正在混音
@property (nonatomic, assign, getter=isSuccentorAudioMixing) BOOL succentorAudioMixing;

@property (nonatomic, assign) BOOL isHost;

@property (nonatomic, assign) BOOL isSinger;

@property (nonatomic, assign) ByteRTCAudioRoute currentAudioRoute;

@end

@implementation ChorusRTCManager

+ (ChorusRTCManager *_Nullable)shareRtc {
    static ChorusRTCManager *rtcManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rtcManager = [[ChorusRTCManager alloc] init];
    });
    return rtcManager;
}

#pragma mark - Publish Action

- (void)configeRTCEngine {
    _audioMixingID = 3001;
}

- (void)joinChannelWithToken:(NSString *)token
                      roomID:(NSString *)roomID
                      userID:(NSString *)userID
                      isHost:(BOOL)isHost {
    self.isHost = isHost;
    self.rtcRoom = [self.rtcEngineKit createRTCRoom:roomID];
    self.rtcRoom.delegate = self;
    
    // 设置音频场景类型为音乐场景
    [self.rtcEngineKit setAudioScenario:ByteRTCAudioScenarioMedia];
    
    // 设置用户可见
    [self.rtcRoom setUserVisibility:isHost];
    if (isHost) {
        [self enableLocalAudio:YES];
        [self bingCanvasViewToUserID:userID];
    }
    
    //设置视频镜像
    [self.rtcEngineKit setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];
    
    // 启用音频信息提示
    ByteRTCAudioPropertiesConfig *reportConfig = [[ByteRTCAudioPropertiesConfig alloc] init];
    reportConfig.interval = 300;
    [self.rtcEngineKit enableAudioPropertiesReport:reportConfig];
    
    ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
    userInfo.userId = userID;
    
    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.profile = ByteRTCRoomProfileKTV;
    config.isAutoPublish = YES;
    config.isAutoSubscribeAudio = YES;
    config.isAutoSubscribeVideo = YES;
    // 加入房间
    [self.rtcRoom joinRoom:token userInfo:userInfo roomConfig:config];
    
    // 设置音频场景类型为音乐场景
    [self.rtcEngineKit setAudioScenario:ByteRTCAudioScenarioMedia];
}

- (BOOL)canEarMonitor {
    return _currentAudioRoute == ByteRTCAudioRouteHeadset || _currentAudioRoute == ByteRTCAudioRouteHeadsetUSB;
}

#pragma mark - rtc method

- (void)enableLocalAudio:(BOOL)enable {
    //开启/关闭 本地音频采集
    if (enable) {
        [SystemAuthority authorizationStatusWithType:AuthorizationTypeAudio
                                               block:^(BOOL isAuthorize) {
            if (isAuthorize) {
                [self.rtcEngineKit startAudioCapture];
                self->_isMicrophoneOpen = YES;
            }
        }];
    } else {
        [self.rtcEngineKit stopAudioCapture];
        _isMicrophoneOpen = NO;
    }
}

- (void)enableLocalVideo:(BOOL)enable {
    
    if (enable) {
        [SystemAuthority authorizationStatusWithType:AuthorizationTypeCamera
                                               block:^(BOOL isAuthorize) {
            if (isAuthorize) {
                [self.rtcEngineKit startVideoCapture];
            }
        }];
    } else {
        [self.rtcEngineKit stopVideoCapture];
    }
    
    UIView *streamView = [self getStreamViewWithUserID:[LocalUserComponent userModel].uid];
    streamView.hidden = !enable;
    _isCameraOpen = enable;
}

/// 切换身份成为演唱者（上下麦）
/// @param isSinger 是否是演唱者
- (void)switchIdentifyBecomeSinger:(BOOL)isSinger {
    if (self.isSinger == isSinger) {
        return;
    }
    self.isSinger = isSinger;
    
    if (isSinger) {
        [self.rtcRoom setUserVisibility:YES];
        [self enableLocalAudio:YES];
        [self enableLocalVideo:NO];
        
        [self bingCanvasViewToUserID:[LocalUserComponent userModel].uid];
    }
    else {
        if (self.isHost) {
            [self enableLocalVideo:NO];
        }
        else {
            [self.rtcRoom setUserVisibility:NO];
            [self enableLocalAudio:NO];
            [self enableLocalVideo:NO];
            
            NSString *groupKey = [NSString stringWithFormat:@"self_%@", [LocalUserComponent userModel].uid];
            [self.streamViewDic removeObjectForKey:groupKey];
        }
    }
}

- (void)leaveChannel {
    
    [self.streamViewDic removeAllObjects];
    [self stopSinging];
    self.isSinger = NO;
    
    // 关闭音视频采集
    // Close audio and video capture
    [self enableLocalAudio:NO];
    [self enableLocalVideo:NO];
    
    // 关闭耳返
    // Close ear return
    [self enableEarMonitor:NO];
    
    // 离开频道
    // Leave the channel
    [self.rtcRoom leaveRoom];
}

#pragma mark - Render

- (UIView *)getStreamViewWithUserID:(NSString *)userID {
    if (IsEmptyStr(userID)) {
        return nil;
    }
    NSString *typeStr = @"";
    if ([userID isEqualToString:[LocalUserComponent userModel].uid]) {
        typeStr = @"self";
    } else {
        typeStr = @"remote";
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@", typeStr, userID];
    UIView *view = self.streamViewDic[key];
    NSLog(@"Manager RTCSDK getStreamViewWithUid : %@|%@", view, userID);
    return view;
}

- (void)bingCanvasViewToUserID:(NSString *)userID {
    dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
        if ([userID isEqualToString:[LocalUserComponent userModel].uid]) {
            UIView *view = [self getStreamViewWithUserID:userID];
            if (!view) {
                UIView *streamView = [[UIView alloc] init];
                ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
                canvas.renderMode = ByteRTCRenderModeHidden;
                canvas.view = streamView;
                [self.rtcEngineKit setLocalVideoCanvas:ByteRTCStreamIndexMain
                                            withCanvas:canvas];
                NSString *key = [NSString stringWithFormat:@"self_%@", userID];
                [self.streamViewDic setValue:streamView forKey:key];
            }
        } else {
            UIView *remoteRoomView = [self getStreamViewWithUserID:userID];
            if (!remoteRoomView) {
                remoteRoomView = [[UIView alloc] init];
                ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
                canvas.renderMode = ByteRTCRenderModeHidden;
                canvas.view = remoteRoomView;
                
                ByteRTCRemoteStreamKey *streamKey = [[ByteRTCRemoteStreamKey alloc] init];
                streamKey.userId = userID;
                streamKey.roomId = self.rtcRoom.getRoomId;
                streamKey.streamIndex = ByteRTCStreamIndexMain;
                
                [self.rtcEngineKit setRemoteVideoCanvas:streamKey
                                                withCanvas:canvas];
                
                NSString *groupKey = [NSString stringWithFormat:@"remote_%@", userID];
                [self.streamViewDic setValue:remoteRoomView forKey:groupKey];
            }
        }
        NSLog(@"Manager RTCSDK bingCanvasViewToUid : %@", self.streamViewDic);
    }));
}

// 更新音视频订阅状态
// @param status 合唱状态
- (void)updateAudioSubscribeWithChorusStatus:(ChorusStatus)status {
    
    // 恢复订阅所有人音视频流
    NSMutableSet<NSString *> *set = [NSMutableSet set];
    [set addObject:[ChorusDataManager shared].roomModel.hostUid];
    if ([ChorusDataManager shared].leadSingerUserModel) {
        [set addObject:[ChorusDataManager shared].leadSingerUserModel.uid];
    }
    if ([ChorusDataManager shared].succentorUserModel) {
        [set addObject:[ChorusDataManager shared].succentorUserModel.uid];
    }
    [set removeObject:[LocalUserComponent userModel].uid];
    
    for (NSString *uid in set) {
        [self.rtcRoom subscribeStream:uid mediaStreamType:ByteRTCMediaStreamTypeBoth];
    }
    
    // 根据情况取消音频流订阅
    // 不是演唱中或者不是合唱，不需要处理
    if (status != ChorusStatusSinging || ![ChorusDataManager shared].succentorUserModel) {
        return;
    }
    
    if ([ChorusDataManager shared].isLeadSinger) {
        // 自己是主唱，取消副唱音频订阅
        [self.rtcRoom unsubscribeStream:[ChorusDataManager shared].succentorUserModel.uid  mediaStreamType:ByteRTCMediaStreamTypeAudio];
        return;
    }
    
    if (![ChorusDataManager shared].isSuccentor) {
        // 自己不是副唱， 主播&观众 取消主唱音频订阅
        [self.rtcRoom unsubscribeStream:[ChorusDataManager shared].leadSingerUserModel.uid mediaStreamType:ByteRTCMediaStreamTypeAudio];
    }
    
}

/// 更新副唱混音状态
/// @param status 当前合唱状态
- (void)updateSuccentorAudioMixingWithChorusState:(ChorusStatus)status {
    /// 自己是副唱 演唱阶段，没有开启混音则需要开启混音
    BOOL needStartAudioMixing = ([ChorusDataManager shared].isSuccentor &&
                                 status == ChorusStatusSinging &&
                                 !self.isSuccentorAudioMixing);
    if (needStartAudioMixing) {
        self.succentorAudioMixing = YES;
        
        ByteRTCAudioMixingManager *manager = [self.rtcEngineKit getAudioMixingManager];
        [manager enableAudioMixingFrame:_audioMixingID type:ByteRTCAudioMixingTypePublish];
        
        [self.rtcEngineKit registerAudioFrameObserver:self];
        ByteRTCAudioFormat *format = [[ByteRTCAudioFormat alloc] init];
        format.sampleRate = ByteRTCAudioSampleRateAuto;
        format.channel = ByteRTCAudioChannelAuto;
        [self.rtcEngineKit enableAudioFrameCallback:ByteRTCAudioFrameCallbackRemoteUser format:format];
    }
    else {
        // 需要关闭混音
        if (self.isSuccentorAudioMixing) {
            /// 不需要混音，并且自己是混音状态，关闭混音
            self.succentorAudioMixing = NO;
            [self.rtcEngineKit registerAudioFrameObserver:nil];
            [self.rtcEngineKit disableAudioFrameCallback:ByteRTCAudioFrameCallbackRemoteUser];
            
            ByteRTCAudioMixingManager *manager = [self.rtcEngineKit getAudioMixingManager];
            [manager disableAudioMixingFrame:_audioMixingID];
        }
    }
}

#pragma mark - Singing Music Method

- (void)startAudioMixingWithFilePath:(NSString *)filePath {
    if (IsEmptyStr(filePath)) {
        return;
    }
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    ByteRTCAudioMixingConfig *config = [[ByteRTCAudioMixingConfig alloc] init];
    config.type = ByteRTCAudioMixingTypePlayoutAndPublish;
    config.playCount = 1;
    [audioMixingManager startAudioMixing:_audioMixingID
                                filePath:filePath
                                  config:config];
    [audioMixingManager setAudioMixingProgressInterval:_audioMixingID interval:100];
}

- (void)stopSinging {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    [audioMixingManager stopAudioMixing:_audioMixingID];
}

- (void)switchAccompaniment:(BOOL)isAccompaniment {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    if (isAccompaniment) {
        [audioMixingManager setAudioMixingDualMonoMode:_audioMixingID
                                                  mode:ByteRTCAudioMixingDualMonoModeR];
    } else {
        [audioMixingManager setAudioMixingDualMonoMode:_audioMixingID
                                                  mode:ByteRTCAudioMixingDualMonoModeL];
    }
}

- (void)sendStreamSyncTime:(NSString *)time {
    NSData *data = [time dataUsingEncoding:NSUTF8StringEncoding];
    ByteRTCStreamSycnInfoConfig *config = [[ByteRTCStreamSycnInfoConfig alloc] init];
    [self.rtcEngineKit sendStreamSyncInfo:data config:config];
}

- (void)setVoiceReverbType:(ByteRTCVoiceReverbType)reverbType {
    [self.rtcEngineKit setVoiceReverbType:reverbType];
}

- (void)enableEarMonitor:(BOOL)isEnable {
    [self.rtcEngineKit setEarMonitorMode:isEnable ? ByteRTCEarMonitorModeOn : ByteRTCEarMonitorModeOff];
}

- (void)setEarMonitorVolume:(NSInteger)volume {
    [self.rtcEngineKit setEarMonitorVolume:volume];
}

- (void)setRecordingVolume:(NSInteger)volume {
    [self.rtcEngineKit setCaptureVolume:ByteRTCStreamIndexMain volume:(int)volume];
}

- (void)setMusicVolume:(NSInteger)volume {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    if ([ChorusDataManager shared].isSuccentor) {
        [audioMixingManager setAudioMixingVolume:_audioMixingID volume:(int)volume type:ByteRTCAudioMixingTypePublish];
        [self.rtcEngineKit setRemoteAudioPlaybackVolume:[ChorusDataManager shared].roomModel.roomID remoteUid:[ChorusDataManager shared].leadSingerUserModel.uid playVolume:volume];
    } else {
        [audioMixingManager setAudioMixingVolume:_audioMixingID volume:(int)volume type:ByteRTCAudioMixingTypePlayoutAndPublish];
    }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onStreamSyncInfoReceived:(ByteRTCRemoteStreamKey *)remoteStreamKey streamType:(ByteRTCSyncInfoStreamType)streamType data:(NSData *)data {
    if ([ChorusDataManager shared].isLeadSinger) {
        return;
    }
    
    NSString *json = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    
    if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onStreamSyncInfoReceived:)]) {
        [self.delegate chorusRTCManager:self onStreamSyncInfoReceived:json];
    }
    
    // 副唱转发主唱时间
    if ([ChorusDataManager shared].isSuccentor) {
        ByteRTCStreamSycnInfoConfig *config = [[ByteRTCStreamSycnInfoConfig alloc] init];
        [self.rtcEngineKit sendStreamSyncInfo:data config:config];
    }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onAudioMixingStateChanged:(NSInteger)mixId state:(ByteRTCAudioMixingState)state error:(ByteRTCAudioMixingError)error {
    if (state == ByteRTCAudioMixingStateFinished) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onSingEnded:)]) {
                [self.delegate chorusRTCManager:self onSingEnded:YES];
            }
        });
    }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onAudioMixingPlayingProgress:(NSInteger)mixId progress:(int64_t)progress {
    if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onAudioMixingPlayingProgress:)]) {
        [self.delegate chorusRTCManager:self onAudioMixingPlayingProgress:progress];
    }
}


#pragma mark - ByteRTCVideoDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId
        withUid:(NSString *)uid
          state:(NSInteger)state
      extraInfo:(NSString *)extraInfo {
    [super rtcRoom:rtcRoom onRoomStateChanged:roomId withUid:uid state:state extraInfo:extraInfo];
    
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        RTCJoinModel *joinModel = [RTCJoinModel modelArrayWithClass:extraInfo state:state roomId:roomId];
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onRoomStateChanged:)]) {
            [self.delegate chorusRTCManager:self onRoomStateChanged:joinModel];
        }
    });
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserJoined:(ByteRTCUserInfo *)userInfo elapsed:(NSInteger)elapsed {
    
    [self bingCanvasViewToUserID:userInfo.userId];
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason {
    
    NSString *groupKey = [NSString stringWithFormat:@"remote_%@", uid];
    [self.streamViewDic removeObjectForKey:groupKey];
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onLocalStreamStats:(ByteRTCLocalStreamStats *)stats {

    ChorusNetworkQualityStatus liveStatus = ChorusNetworkQualityStatusNone;
    if (stats.tx_quality == ByteRTCNetworkQualityExcellent ||
        stats.tx_quality == ByteRTCNetworkQualityGood) {
        liveStatus = ChorusNetworkQualityStatusGood;
    } else {
        liveStatus = ChorusNetworkQualityStatusBad;
    }
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onNetworkQualityStatus:userID:)]) {
            [self.delegate chorusRTCManager:self onNetworkQualityStatus:liveStatus userID:[LocalUserComponent userModel].uid];
        }
    });
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRemoteStreamStats:(ByteRTCRemoteStreamStats *)stats {
    ChorusNetworkQualityStatus liveStatus = ChorusNetworkQualityStatusNone;
    if (stats.tx_quality == ByteRTCNetworkQualityExcellent ||
        stats.tx_quality == ByteRTCNetworkQualityGood) {
        liveStatus = ChorusNetworkQualityStatusGood;
    } else {
        liveStatus = ChorusNetworkQualityStatusBad;
    }
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onNetworkQualityStatus:userID:)]) {
            [self.delegate chorusRTCManager:self onNetworkQualityStatus:liveStatus userID:stats.uid];
        }
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onFirstRemoteVideoFrameRendered:(ByteRTCRemoteStreamKey *)streamKey withFrameInfo:(ByteRTCVideoFrameInfo *)frameInfo {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onFirstVideoFrameRenderedWithUserID:)]) {
            [self.delegate chorusRTCManager:self onFirstVideoFrameRenderedWithUserID:streamKey.userId];
        }
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onFirstLocalVideoFrameCaptured:(ByteRTCStreamIndex)streamIndex withFrameInfo:(ByteRTCVideoFrameInfo *)frameInfo {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onFirstVideoFrameRenderedWithUserID:)]) {
            [self.delegate chorusRTCManager:self onFirstVideoFrameRenderedWithUserID:[LocalUserComponent userModel].uid];
        }
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onUserStartVideoCapture:(NSString *)roomId uid:(NSString *)uid {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        UIView *view = [self getStreamViewWithUserID:uid];
        view.hidden = NO;
    })
}

- (void)rtcEngine:(ByteRTCVideo *)engine onUserStopVideoCapture:(NSString *)roomId uid:(NSString *)uid {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        UIView *view = [self getStreamViewWithUserID:uid];
        view.hidden = YES;
    })
}

/**
 * @type callback
 * @region 音频事件回调
 * @author dixing
 * @brief 音频播放路由变化时，收到该回调。
 * @param device 新的音频播放路由，详见 ByteRTCAudioRouteDevice{@link #ByteRTCAudioRouteDevice}
 * @notes 关于音频路由设置，详见 setAudioRoute:{@link #ByteRTCEngineKit#setAudioRoute:}。
 */
- (void)rtcEngine:(ByteRTCVideo *)engine onAudioRouteChanged:(ByteRTCAudioRoute)device {
    _currentAudioRoute = device;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManagerOnAudioRouteChanged:)]) {
            [self.delegate chorusRTCManagerOnAudioRouteChanged:self];
        }
    });
}

// 调用 enableAudioPropertiesReport:{@link #ByteRTCEngineKit#enableAudioPropertiesReport:} 后，根据设置的 interval 值，你会周期性地收到此回调
- (void)rtcEngine:(ByteRTCVideo *)engine onLocalAudioPropertiesReport:(NSArray<ByteRTCLocalAudioPropertiesInfo *> *)audioPropertiesInfos {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (ByteRTCLocalAudioPropertiesInfo *info in audioPropertiesInfos) {
        [dict setValue:@(info.audioPropertiesInfo.linearVolume) forKey:[LocalUserComponent userModel].uid ? : @""];
    }
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onReportUserAudioVolume:)]) {
            [self.delegate chorusRTCManager:self onReportUserAudioVolume:dict];
        }
    });
    
}
// 远端用户进房后，本地调用 enableAudioPropertiesReport:{@link #ByteRTCEngineKit#enableAudioPropertiesReport:} ，根据设置的 interval 值，本地会周期性地收到此回调
- (void)rtcEngine:(ByteRTCVideo *)engine onRemoteAudioPropertiesReport:(NSArray<ByteRTCRemoteAudioPropertiesInfo *> *)audioPropertiesInfos totalRemoteVolume:(NSInteger)totalRemoteVolume {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (ByteRTCRemoteAudioPropertiesInfo *info in audioPropertiesInfos) {
        [dict setValue:@(info.audioPropertiesInfo.linearVolume) forKey:info.streamKey.userId];
    }
    
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onReportUserAudioVolume:)]) {
            [self.delegate chorusRTCManager:self onReportUserAudioVolume:dict];
        }
    });
}

#pragma mark - ByteRTCAudioFrameObserver
- (void)onRemoteUserAudioFrame:(ByteRTCRemoteStreamKey * _Nonnull)streamKey audioFrame:(ByteRTCAudioFrame * _Nonnull)audioFrame {
    // 自己是副唱，需要转推房间内主唱的PCM
    if ([streamKey.roomId isEqualToString:[ChorusDataManager shared].roomModel.roomID] &&
        [streamKey.userId isEqualToString:[ChorusDataManager shared].leadSingerUserModel.uid] &&
        [ChorusDataManager shared].isSuccentor) {
        
        ByteRTCAudioMixingManager *manager = [self.rtcEngineKit getAudioMixingManager];
        [manager pushAudioMixingFrame:_audioMixingID audioFrame:audioFrame];
    }
}

- (void)onMixedAudioFrame:(ByteRTCAudioFrame * _Nonnull)audioFrame {
    
}


- (void)onPlaybackAudioFrame:(ByteRTCAudioFrame * _Nonnull)audioFrame {
    
}


- (void)onRecordAudioFrame:(ByteRTCAudioFrame * _Nonnull)audioFrame {
    
}


#pragma mark - getter
- (NSMutableDictionary<NSString *, UIView *> *)streamViewDic {
    if (!_streamViewDic) {
        _streamViewDic = [[NSMutableDictionary alloc] init];
    }
    return _streamViewDic;
}

@end
