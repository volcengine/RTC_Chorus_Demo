// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusMusicComponent.h"
#import "ChorusMusicNullView.h"
#import "ChorusMusicEndView.h"
#import "ChorusMusicControlView.h"
#import "ChorusMusicTuningView.h"
#import "ChorusSingerComponent.h"
#import "ChorusWaitingSingerJoinView.h"
#import "ChorusMusicLyricsView.h"
#import "ChorusDataManager.h"
#import "ChorusPickSongManager.h"



@interface ChorusMusicComponent ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) ChorusMusicNullView *musicNullView;
@property (nonatomic, strong) ChorusMusicEndView *musicEndView;
@property (nonatomic, strong) ChorusMusicControlView *musicControlView;
@property (nonatomic, strong) ChorusMusicTuningView *tuningView;
@property (nonatomic, strong) UIButton *maskButton;
@property (nonatomic, strong) ChorusSingerComponent *singerComponent;
@property (nonatomic, strong) ChorusWaitingSingerJoinView *waitingJoinView;
@property (nonatomic, strong) ChorusMusicLyricsView *lrcView;
@property (nonatomic, assign) BOOL downloadCompleteNeedPlay;

@end

@implementation ChorusMusicComponent

#pragma mark - Publish Action

- (instancetype)initWithSuperView:(UIView *)view {
    self = [super init];
    if (self) {
        
        [self setupViewsWithSuperView:view];
        
        [self updateWithChorusStatus:ChorusStatusIdle];
    }
    return self;
}

// init UI
- (void)setupViewsWithSuperView:(UIView *)superView {
    [superView addSubview:self.backgroundView];
    [superView addSubview:self.musicControlView];
    
    [self singerComponent];
    
    [self.backgroundView addSubview:self.musicNullView];
    [self.backgroundView addSubview:self.musicEndView];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(superView);
        make.top.mas_equalTo([DeviceInforTool getStatusBarHight] + 72);
        make.height.mas_equalTo(264);
    }];
    [self.musicNullView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backgroundView);
    }];
    [self.musicEndView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backgroundView);
    }];
    [self.musicControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backgroundView);
        make.top.equalTo(self.backgroundView.mas_bottom).offset(-14);
        make.height.mas_equalTo(69);
    }];
    
    [superView addSubview:self.waitingJoinView];
    [self.waitingJoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backgroundView);
        make.bottom.equalTo(self.backgroundView).offset(74);
    }];
    [self.backgroundView addSubview:self.lrcView];
    [self.lrcView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backgroundView);
        make.height.mas_equalTo(100);
        make.bottom.equalTo(self.backgroundView).offset(-5);
    }];
    
    UIView *keyView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [keyView addSubview:self.maskButton];
    [self.maskButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.height.equalTo(keyView);
        make.top.equalTo(keyView).offset(SCREEN_HEIGHT);
    }];
    [self.maskButton addSubview:self.tuningView];
    [self.tuningView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.maskButton);
    }];
}

/// 更新音乐部位相关UI
/// @param status 合唱状态
- (void)updateUIWithChorusStatus:(ChorusStatus)status {
    
    self.musicNullView.hidden = YES;
    self.musicEndView.hidden = YES;
    self.musicControlView.hidden = YES;
    self.singerComponent.backgroundView.hidden = YES;
    self.waitingJoinView.hidden = YES;
    self.lrcView.hidden = YES;
    
    switch (status) {
        case ChorusStatusIdle: {
            self.musicNullView.hidden = NO;
        }
            break;
        case ChorusStatusPrepare: {
            self.singerComponent.backgroundView.hidden = NO;
            self.waitingJoinView.hidden = NO;
            [self.waitingJoinView updateUI];
        }
            break;
        case ChorusStatusSinging: {
            self.musicControlView.hidden = NO;
            self.singerComponent.backgroundView.hidden = NO;
            self.lrcView.hidden = NO;
        }
            break;
        
        case ChorusStatusSingEnd: {
            self.singerComponent.backgroundView.hidden = NO;
            self.musicEndView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Publish Action

- (void)updateWithChorusStatus:(ChorusStatus)status {
    [self updateUIWithChorusStatus:status];
    [self.singerComponent updateSingerUIWithChorusStatus:status];
    [[ChorusRTCManager shareRtc] updateAudioSubscribeWithChorusStatus:status];
    [[ChorusRTCManager shareRtc] updateSuccentorAudioMixingWithChorusState:status];
}

/// 开始进入演唱准备阶段（等待合唱者加入），此方法会调用prepareMaterialsWithSongModel
/// @param songModel 歌曲Model
/// @param leadSingerUserModel 主唱信息
- (void)prepareStartSingSong:(ChorusSongModel *_Nullable)songModel
         leadSingerUserModel:(ChorusUserModel *_Nullable)leadSingerUserModel {
    
    [self.tuningView resetUI];
    
    if (!songModel) {
        [self updateWithChorusStatus:ChorusStatusIdle];
        return;
    }
    
    [self updateWithChorusStatus:ChorusStatusPrepare];
    
    
    [self prepareMaterialsWithSongModel:songModel];
    
}

- (void)reallyStartSingSong:(ChorusSongModel *)songModel {
    
    if (!songModel) {
        return;
    }
    
    [self updateWithChorusStatus:ChorusStatusSinging];
    [self.musicControlView updateUI];

    if ([ChorusDataManager shared].isLeadSinger) {
        // 播放伴奏
        self.downloadCompleteNeedPlay = NO;
        NSString *filePath = [ChorusPickSongManager getMP3FilePath:songModel.musicId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[ChorusRTCManager shareRtc] startAudioMixingWithFilePath:filePath];
            [[ChorusRTCManager shareRtc] switchAccompaniment:YES];
            [[ChorusRTCManager shareRtc] setMusicVolume:10];
            [[ToastComponent shareToastComponent] showWithMessage:veString(@"开始演唱吧")];
        } else {
            // 如果开始演唱伴奏还没有下载完成，则下载完成后开始播放伴奏
            self.downloadCompleteNeedPlay = YES;
        }
    }
    
    if ([ChorusDataManager shared].isSuccentor) {
        [[ChorusRTCManager shareRtc] setMusicVolume:100];
        [self.tuningView setMusicVolume:100];
    }
}

/// 准备伴奏歌词等物料
/// @param songModel 歌曲信息
- (void)prepareMaterialsWithSongModel:(ChorusSongModel *)songModel {
    // 准备物料
    self.downloadCompleteNeedPlay = NO;
    __weak typeof(self) weakSelf = self;
    [ChorusPickSongManager requestDownSongModel:songModel complete:^(ChorusDownloadSongModel * _Nonnull downloadSongModel) {
        // LRC
        [ChorusPickSongManager getLRCFilePath:downloadSongModel
                                  complete:^(NSString * _Nonnull filePath) {
            if (NOEmptyStr(filePath)) {
                [weakSelf.lrcView loadLrcByPath:filePath error:nil];
                [weakSelf.lrcView playAtTime:0];
                // Singer
                if ([ChorusDataManager shared].isLeadSinger) {
                    [[ChorusRTCManager shareRtc] sendStreamSyncTime:@"0"];
                }
            } else {
                NSLog(@"歌词下载失败，请稍后再试");
            }
        }];
        
        // Music
        if ([ChorusDataManager shared].isLeadSinger) {
            [ChorusPickSongManager getMP3FilePath:downloadSongModel
                                      complete:^(NSString * _Nonnull filePath) {
                if (weakSelf.downloadCompleteNeedPlay) {
                    [[ChorusRTCManager shareRtc] startAudioMixingWithFilePath:filePath];
                    [[ChorusRTCManager shareRtc] switchAccompaniment:YES];
                    [[ChorusRTCManager shareRtc] setMusicVolume:10];
                    [[ToastComponent shareToastComponent] showWithMessage:veString(@"开始演唱吧")];
                }
            }];
        }
    }];
}

- (void)stopSong {
    if (IsEmptyStr([ChorusDataManager shared].roomModel.roomID) ||
        IsEmptyStr([ChorusDataManager shared].currentSongModel.musicId)) {
        return;
    }
    [ChorusRTSManager finishSing:[ChorusDataManager shared].roomModel.roomID
                          songID:[ChorusDataManager shared].currentSongModel.musicId
                           score:75
                           block:^(ChorusSongModel * _Nonnull songModel,
                                       RTSACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
    
    // close ear return
    [[ChorusRTCManager shareRtc] enableEarMonitor:NO];
    // turn off the reverb effect
    [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbOriginal];
    // close the tuning panel
    [self maskButtonAction];
}

- (void)showSongEndWithNextSongModel:(ChorusSongModel *)nextSongModel {
    
    if (nextSongModel) {
        [self updateWithChorusStatus:ChorusStatusSingEnd];
        
        [self.musicEndView showEndViewWithNextSongModel:nextSongModel];
        
        // 播放结束展示5秒，5秒后播放下一首
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf cutOffSongWithHost];
        });
    }
    else {
        [self updateWithChorusStatus:ChorusStatusIdle];
        
        [self cutOffSongWithHost];
    }
}

- (void)cutOffSongWithHost {
    if ([ChorusDataManager shared].isLeadSinger) {
        [self loadDataWithCutOffSong:^(RTSACKModel *model) {
            
        }];
    }
}

- (void)updateCurrentSongTime:(NSString *)json {
    NSDictionary *dic = [NetworkingTool decodeJsonMessage:json];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSInteger progress = [dic[@"progress"] integerValue];
        NSString *musicId = dic[@"music_id"];
        if ([musicId isEqualToString:[ChorusDataManager shared].currentSongModel.musicId]) {
            [self.lrcView playAtTime:progress];
            self.musicControlView.time = progress;
        }
    }
}

- (void)dismissTuningPanel {
    [self maskButtonAction];
}

- (void)sendSongTime:(NSInteger)songTime {
    ChorusSongModel *songModel = [ChorusDataManager shared].currentSongModel;
    if ([ChorusDataManager shared].isLeadSinger &&
        songModel && NOEmptyStr(songModel.musicId)) {
        NSTimeInterval second = (NSTimeInterval)songTime / 1000;
        
        NSDictionary *dic = @{@"progress" : @(second),
                              @"music_id" : songModel.musicId};
        NSString *json = [dic yy_modelToJSONString];
        
        // 发送给远端歌词进度
        [[ChorusRTCManager shareRtc] sendStreamSyncTime:json];
        
        // 更新本地歌词进度
        [self updateCurrentSongTime:json];
    }
}

- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status uid:(NSString *)uid {
    [self.singerComponent updateNetworkQuality:status uid:uid];
}

- (void)updateFirstVideoFrameRenderedWithUid:(NSString *)uid {
    [self.singerComponent updateFirstVideoFrameRenderedWithUid:uid];
}

/// 更新用户说话声音动画
/// @param dict 用户ID ： 说话音量
- (void)updateUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *)dict {
    [self.singerComponent updateUserAudioVolume:dict];
}

/// 音频播放路由改变
- (void)updateAudioRouteChanged {
    [self.tuningView updateAudioRouteChanged];
}

#pragma mark - Private Action
- (void)startSingWithActionType:(ChorusSingingType)actionType {
    [[ToastComponent shareToastComponent] showLoading];
    [ChorusRTSManager startSingWithRoomID:[ChorusDataManager shared].roomModel.roomID
                                   songID:[ChorusDataManager shared].currentSongModel.musicId
                                     type:actionType
                                    block:^(RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
}

#pragma mark - musicControl
- (void)musicControlViewClick:(MusicControlState)state
                     isSelect:(BOOL)isSelect
                       button:(BaseButton *)button {
    if (state == MusicControlStateOriginal) {
        [[ChorusRTCManager shareRtc] switchAccompaniment:!isSelect];
        if (isSelect) {
            [[ToastComponent shareToastComponent] showWithMessage:veString(@"已开启原唱")];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:veString(@"已开启伴奏")];
        }
    } else if (state == MusicControlStateTuning) {
        [self tuningViewShow];
    } else if (state == MusicControlStateNext) {
        [[ToastComponent shareToastComponent] showLoading];
        button.userInteractionEnabled = NO;
        [self loadDataWithCutOffSong:^(RTSACKModel * _Nonnull model) {
            [[ToastComponent shareToastComponent] dismiss];
            button.userInteractionEnabled = YES;
            if (!model.result) {
                [[ToastComponent shareToastComponent] showWithMessage:model.message];
            }
        }];
    } else {
        
    }
}

- (void)tuningViewShow {
    self.maskButton.hidden = NO;
    
    // Start animation
    [self.maskButton.superview layoutIfNeeded];
    [self.maskButton.superview setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25
                     animations:^{
        [self.maskButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.maskButton.superview).offset(0);
        }];
        [self.maskButton.superview layoutIfNeeded];
    }];
}

- (void)maskButtonAction {
    self.maskButton.hidden = YES;
    [self.maskButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.maskButton.superview).offset(SCREEN_HEIGHT);
    }];
}

- (void)loadDataWithCutOffSong:(void(^)(RTSACKModel *model))complete {
    [ChorusRTSManager cutOffSong:[ChorusDataManager shared].roomModel.roomID
                               block:^(RTSACKModel * _Nonnull model) {
        if (complete) {
            complete(model);
        }
    }];
}

#pragma mark - Getter

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [[UIColor colorFromRGBHexString:@"#eeeeee"] colorWithAlphaComponent:0.1];
    }
    return _backgroundView;
}

- (ChorusMusicNullView *)musicNullView {
    if (!_musicNullView) {
        _musicNullView = [[ChorusMusicNullView alloc] init];
        _musicNullView.backgroundColor = [UIColor clearColor];
        _musicNullView.hidden = NO;
    }
    return _musicNullView;
}

- (ChorusMusicEndView *)musicEndView {
    if (!_musicEndView) {
        _musicEndView = [[ChorusMusicEndView alloc] init];
        [_musicEndView setBackgroundColor:[UIColor clearColor]];
        _musicEndView.hidden = YES;
    }
    return _musicEndView;
}

- (ChorusMusicControlView *)musicControlView {
    if (!_musicControlView) {
        _musicControlView = [[ChorusMusicControlView alloc] init];
        _musicControlView.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _musicControlView.clickButtonBlock = ^(MusicControlState state, BOOL isSelect, BaseButton * _Nonnull button) {
            [weakSelf musicControlViewClick:state
                                   isSelect:isSelect
                                     button:button];
        };
    }
    return _musicControlView;
}

- (ChorusMusicTuningView *)tuningView {
    if (!_tuningView) {
        _tuningView = [[ChorusMusicTuningView alloc] init];
    }
    return _tuningView;
}

- (UIButton *)maskButton {
    if (!_maskButton) {
        _maskButton = [[UIButton alloc] init];
        [_maskButton addTarget:self action:@selector(maskButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_maskButton setBackgroundColor:[UIColor clearColor]];
    }
    return _maskButton;
}

- (ChorusSingerComponent *)singerComponent {
    if (!_singerComponent) {
        _singerComponent = [[ChorusSingerComponent alloc] initWithSuperView:self.backgroundView];
    }
    return _singerComponent;
}

- (ChorusWaitingSingerJoinView *)waitingJoinView {
    if (!_waitingJoinView) {
        _waitingJoinView = [[ChorusWaitingSingerJoinView alloc] init];
        __weak typeof(self) weakSelf = self;
        _waitingJoinView.startSingingTypeBlock = ^(ChorusSingingType actionType) {
            [weakSelf startSingWithActionType:actionType];
        };
    }
    return _waitingJoinView;
}

- (ChorusMusicLyricsView *)lrcView {
    if (!_lrcView) {
        _lrcView = [[ChorusMusicLyricsView alloc] init];
    }
    return _lrcView;
}

@end
