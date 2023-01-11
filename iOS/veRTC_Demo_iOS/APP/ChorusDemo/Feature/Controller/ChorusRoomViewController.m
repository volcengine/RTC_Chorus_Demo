//
//  ChorusRoomViewController.m
//  veRTC_Demo
//
//  Created by on 2021/5/18.
//  
//

#import "ChorusRoomViewController.h"
#import "ChorusRoomViewController+SocketControl.h"
#import "ChorusStaticView.h"
#import "ChorusRoomBottomView.h"
#import "ChorusPeopleNumView.h"
#import "ChorusMusicComponent.h"
#import "ChorusTextInputComponent.h"
#import "ChorusIMComponent.h"
#import "ChorusPickSongComponent.h"
#import "ChorusPickSongManager.h"
#import "ChorusRTCManager.h"
#import "ChorusRTSManager.h"
#import "ChorusDataManager.h"
#import "AlertActionManager.h"

@interface ChorusRoomViewController ()
<
ChorusRoomBottomViewDelegate,
ChorusRTCManagerDelegate,
ChorusPickSongComponentDelegate
>

@property (nonatomic, strong) ChorusStaticView *staticView;
@property (nonatomic, strong) ChorusRoomBottomView *bottomView;
@property (nonatomic, strong) ChorusMusicComponent *musicComponent;
@property (nonatomic, strong) ChorusTextInputComponent *textInputComponent;
@property (nonatomic, strong) ChorusIMComponent *imComponent;
@property (nonatomic, strong) ChorusPickSongComponent *pickSongComponent;
@property (nonatomic, strong) ChorusRoomModel *roomModel;
@property (nonatomic, strong) ChorusUserModel *hostUserModel;
@property (nonatomic, copy) NSString *rtcToken;

@end

@implementation ChorusRoomViewController

- (instancetype)initWithRoomModel:(ChorusRoomModel *)roomModel {
    self = [super init];
    if (self) {
        _roomModel = roomModel;
    }
    return self;
}

- (instancetype)initWithRoomModel:(ChorusRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(ChorusUserModel *)hostUserModel {
    self = [super init];
    if (self) {
        _hostUserModel = hostUserModel;
        _roomModel = roomModel;
        _rtcToken = rtcToken;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.view.backgroundColor = [UIColor colorFromHexString:@"#394254"];
    
    [ChorusDataManager shared].roomModel = self.roomModel;
    
    [self addSocketListener];
    [self addSubviewAndConstraints];
    [self joinRoom];
    
    __weak typeof(self) weakSelf = self;
    [ChorusRTCManager shareRtc].rtcJoinRoomBlock = ^(NSString * _Nonnull roomId, NSInteger errorCode, NSInteger joinType) {
        [weakSelf joinRTCRoomSuccessWithType:joinType];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - SocketControl

// The audience cannot receive a callback when they enter the room for the first time because they have not yet joined the room
- (void)receivedJoinUser:(ChorusUserModel *)userModel
                   count:(NSInteger)count {
    ChorusIMModel *model = [[ChorusIMModel alloc] init];
    model.userModel = userModel;
    model.isJoin = YES;
    [self.imComponent addIM:model];
    [self.staticView updatePeopleNum:count];
}

- (void)receivedLeaveUser:(ChorusUserModel *)userModel
                    count:(NSInteger)count {
    ChorusIMModel *model = [[ChorusIMModel alloc] init];
    model.userModel = userModel;
    model.isJoin = NO;
    [self.imComponent addIM:model];
    [self.staticView updatePeopleNum:count];
}

- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID {
    if (![roomID isEqualToString:self.roomModel.roomID]) {
        return;
    }
    [self hangUp:NO];
    if (type == 3) {
        [[ToastComponent shareToastComponent] showWithMessage:veString(@"直播间内容违规，直播间已被关闭") delay:0.8];
    }
    else if (type == 2 && [self isHost]) {
        [[ToastComponent shareToastComponent] showWithMessage:veString(@"本次体验时间已超过20分钟") delay:0.8];
    } else {
        if (![self isHost]) {
            [[ToastComponent shareToastComponent] showWithMessage:veString(@"房主已关闭合唱房") delay:0.8];
        }
    }
}

- (void)receivedMessageWithUser:(ChorusUserModel *)userModel
                        message:(NSString *)message {
    if (![userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        ChorusIMModel *model = [[ChorusIMModel alloc] init];
        NSString *imMessage = [NSString stringWithFormat:@"%@：%@",
                               userModel.name,
                               message];
        model.userModel = userModel;
        model.message = imMessage;
        [self.imComponent addIM:model];
    }
}

- (void)hangUp:(BOOL)isServer {
    if (isServer) {
        // socket api
        if ([self isHost]) {
            [ChorusRTSManager finishLive:self.roomModel.roomID];
        } else {
            [ChorusRTSManager leaveLiveRoom:self.roomModel.roomID];
        }
    }
    // sdk api
    [[ChorusRTCManager shareRtc] leaveChannel];
    
    // ui
    [self navigationControllerPop];
}

- (void)receivedPickedSong:(ChorusSongModel *)songModel {
    [self.pickSongComponent updatePickedSongList];
}

/// 开始进入演唱准备阶段（等待合唱者加入）
/// @param songModel 歌曲Model
/// @param leadSingerUserModel 主唱信息
- (void)receivedPrepareStartSingSong:(ChorusSongModel *)songModel
                 leadSingerUserModel:(ChorusUserModel *)leadSingerUserModel {
    /// 开始阶段，重置本地状态
    [[ChorusDataManager shared] resetDataManager];
    [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:NO];
    [[ChorusRTCManager shareRtc] stopSinging];
    
    // 赋值
    [ChorusDataManager shared].currentSongModel = songModel;
    [ChorusDataManager shared].leadSingerUserModel = leadSingerUserModel;
    
    if ([ChorusDataManager shared].isLeadSinger) {
        [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:YES];
    }
    
    [self.musicComponent prepareStartSingSong:songModel
                           leadSingerUserModel:leadSingerUserModel];
    [self.pickSongComponent updatePickedSongList];
    [self.bottomView updateBottomLists];
    [self.bottomView updateBottomStatus:ChorusRoomBottomStatusLocalMic
                               isActive:![ChorusRTCManager shareRtc].isMicrophoneOpen];
}

/// 真正开始演唱歌曲
/// @param songModel 歌曲信息
/// @param leadSingerUserModel 主唱信息
/// @param succentorUserModel 副唱信息
- (void)receivedReallyStartSingSong:(ChorusSongModel *)songModel
                leadSingerUserModel:(ChorusUserModel *)leadSingerUserModel
                 succentorUserModel:(ChorusUserModel *_Nullable)succentorUserModel {
    // 赋值
    [ChorusDataManager shared].succentorUserModel = succentorUserModel;
    
    if ([ChorusDataManager shared].isSuccentor) {
        [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:YES];
    }
    
    [self.musicComponent reallyStartSingSong:songModel];
    [self.pickSongComponent updatePickedSongList];
    [self.bottomView updateBottomLists];
    [self.bottomView updateBottomStatus:ChorusRoomBottomStatusLocalMic
                               isActive:![ChorusRTCManager shareRtc].isMicrophoneOpen];
}

- (void)receivedFinishSingSong:(NSInteger)score nextSongModel:(ChorusSongModel *)nextSongModel {
    
    [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:NO];
    
    [self.musicComponent showSongEndWithNextSongModel:nextSongModel];
    [self.pickSongComponent updatePickedSongList];
    [[ChorusRTCManager shareRtc] stopSinging];
}

#pragma mark - Load Data

- (void)loadDataWithJoinRoom {
    __weak typeof(self) weakSelf = self;
    [ChorusRTSManager joinLiveRoom:self.roomModel.roomID
                              userName:[LocalUserComponent userModel].name
                             block:^(NSString * _Nonnull RTCToken,
                                     ChorusRoomModel * _Nonnull roomModel,
                                     ChorusUserModel * _Nonnull userModel,
                                     ChorusUserModel * _Nonnull hostUserModel,
                                     ChorusSongModel * _Nullable songModel,
                                     ChorusUserModel * _Nullable leadSingerUserModel,
                                     ChorusUserModel * _Nullable succentorUserModel,
                                     ChorusSongModel * _Nullable nextSongModel,
                                     RTMACKModel * _Nonnull model) {
 
        if (NOEmptyStr(roomModel.roomID)) {
            [weakSelf updateRoomViewWithData:RTCToken
                                   roomModel:roomModel
                                   userModel:userModel
                               hostUserModel:hostUserModel
                                   songModel:songModel
                         leadSingerUserModel:leadSingerUserModel
                          succentorUserModel:succentorUserModel
                               nextSongModel:nextSongModel];
        } else {
            AlertActionModel *alertModel = [[AlertActionModel alloc] init];
            alertModel.title = @"确定";
            alertModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
                if ([action.title isEqualToString:@"确定"]) {
                    [weakSelf hangUp:NO];
                }
            };
            [[AlertActionManager shareAlertActionManager] showWithMessage:@"加入房间失败，回到房间列表页" actions:@[alertModel]];
        }
    }];
}

#pragma mark - ChorusPickSongComponentDelegate
- (void)ChorusPickSongComponent:(ChorusPickSongComponent *)component pickedSongCountChanged:(NSInteger)count {
    [self.bottomView updatePickedSongCount:count];
}

#pragma mark - ChorusRoomBottomViewDelegate

- (void)chorusRoomBottomView:(ChorusRoomBottomView *_Nonnull)ChorusRoomBottomView
                     itemButton:(ChorusRoomItemButton *_Nullable)itemButton
                didSelectStatus:(ChorusRoomBottomStatus)status {
    if (status == ChorusRoomBottomStatusInput) {
        [self.textInputComponent showWithRoomModel:self.roomModel];
        __weak __typeof(self) wself = self;
        self.textInputComponent.clickSenderBlock = ^(NSString * _Nonnull text) {
            ChorusIMModel *model = [[ChorusIMModel alloc] init];
            NSString *message = [NSString stringWithFormat:@"%@：%@",
                                 [LocalUserComponent userModel].name,
                                 text];
            model.message = message;
            [wself.imComponent addIM:model];
        };
    }
    else if (status == ChorusRoomBottomStatusPickSong) {
        [self showPickSongView];
    }
}

#pragma mark - ChorusRTCManagerDelegate

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onStreamSyncInfoReceived:(NSString *)json {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [self.musicComponent updateCurrentSongTime:json];
    });
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onSingEnded:(BOOL)result {
    [self.musicComponent stopSong];
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onAudioMixingPlayingProgress:(NSInteger)progress {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [self.musicComponent sendSongTime:progress];
    });
}

- (void)chorusRTCManager:(ChorusRTCManager *)chorusRTCManager onNetworkQualityStatus:(ChorusNetworkQualityStatus)status userID:(NSString *)userID {
    [self.musicComponent updateNetworkQuality:status uid:userID];
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onFirstVideoFrameRenderedWithUserID:(NSString *)uid {
    [self.musicComponent updateFirstVideoFrameRenderedWithUid:uid];
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onReportUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo {
    [self.musicComponent updateUserAudioVolume:volumeInfo];
}

- (void)chorusRTCManagerOnAudioRouteChanged:(ChorusRTCManager *)chorusRTCManager {
    [self.musicComponent updateAudioRouteChanged];
}

#pragma mark - Private Action

- (void)joinRTCRoomSuccessWithType:(NSInteger)joinType {
    // 不是重连不需要处理
    if (joinType != 1) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSString *roomID = self.roomModel.roomID ? self.roomModel.roomID : @"";
    [ChorusRTSManager reconnectWithBlock:^(NSString * _Nonnull RTCToken,
                                           ChorusRoomModel * _Nonnull roomModel,
                                           ChorusUserModel * _Nonnull userModel,
                                           ChorusUserModel * _Nonnull hostUserModel,
                                           ChorusSongModel * _Nonnull songModel,
                                           ChorusUserModel * _Nonnull leadSingerUserModel,
                                           ChorusUserModel * _Nonnull succentorUserModel,
                                           ChorusSongModel * _Nonnull nextSongModel,
                                           NSInteger audienceCount,
                                           RTMACKModel * _Nonnull model) {
        if (model.result) {
            [weakSelf updateRoomViewWithData:RTCToken
                                   roomModel:roomModel
                                   userModel:userModel
                               hostUserModel:hostUserModel
                                   songModel:songModel
                         leadSingerUserModel:leadSingerUserModel
                          succentorUserModel:succentorUserModel
                               nextSongModel:nextSongModel];
        } else if (model.code == RTMStatusCodeUserIsInactive ||
                   model.code == RTMStatusCodeRoomDisbanded ||
                   model.code == RTMStatusCodeUserNotFound) {
            [weakSelf hangUp:YES];
            [[ToastComponent shareToastComponent] showWithMessage:model.message delay:0.8];
        }
    }];
}

- (void)joinRoom {
    if (IsEmptyStr(self.hostUserModel.uid)) {
        [self loadDataWithJoinRoom];
        self.staticView.roomModel = self.roomModel;
    } else {
        [self updateRoomViewWithData:self.rtcToken
                           roomModel:self.roomModel
                           userModel:self.hostUserModel
                       hostUserModel:self.hostUserModel
                           songModel:nil
                 leadSingerUserModel:nil
                  succentorUserModel:nil
                       nextSongModel:nil];
    }
}

- (void)updateRoomViewWithData:(NSString *)rtcToken
                     roomModel:(ChorusRoomModel *)roomModel
                     userModel:(ChorusUserModel *)userModel
                 hostUserModel:(ChorusUserModel *)hostUserModel
                     songModel:(ChorusSongModel *)songModel
           leadSingerUserModel:(ChorusUserModel *)leadSingerUserModel
            succentorUserModel:(ChorusUserModel *)succentorUserModel
                 nextSongModel:(ChorusSongModel *)nextSongModel {
    _hostUserModel = hostUserModel;
    _roomModel = roomModel;
    _rtcToken = rtcToken;
    //Activate SDK
    [ChorusRTCManager shareRtc].delegate = self;
    [[ChorusRTCManager shareRtc] joinChannelWithToken:rtcToken
                                               roomID:self.roomModel.roomID
                                               userID:[LocalUserComponent userModel].uid
                                               isHost:[self isHost]];

    self.staticView.roomModel = self.roomModel;

    // 进入房间时赋值
    [ChorusDataManager shared].currentSongModel = songModel;
    [ChorusDataManager shared].leadSingerUserModel = leadSingerUserModel;
    [ChorusDataManager shared].succentorUserModel = succentorUserModel;

    if (([ChorusDataManager shared].isLeadSinger || [ChorusDataManager shared].isSuccentor) && songModel.singStatus != ChorusSongModelSingStatusFinish) {
        [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:YES];
    }

    if (songModel) {
        if (songModel.singStatus == ChorusSongModelSingStatusWaiting) {
            [self.musicComponent prepareStartSingSong:songModel
                                  leadSingerUserModel:nil];
        } else if (songModel.singStatus == ChorusSongModelSingStatusSinging) {
            [self.musicComponent prepareMaterialsWithSongModel:songModel];
            [self.musicComponent reallyStartSingSong:songModel];
        } else if (songModel.singStatus == ChorusSongModelSingStatusFinish) {
            [[ChorusDataManager shared] resetDataManager];

            [self.musicComponent showSongEndWithNextSongModel:nextSongModel];
        }
    }

    [self.bottomView updateBottomLists];
}

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.staticView];
    [self.staticView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([DeviceInforTool getVirtualHomeHeight] + 36 + 32);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view);
    }];
    
    [self musicComponent];
    [self imComponent];
    [self textInputComponent];
    [self pickSongComponent];
}

- (void)showEndView {
    __weak __typeof(self) wself = self;
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = @"结束直播";
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        if ([action.title isEqualToString:@"结束直播"]) {
            [wself hangUp:YES];
        }
    };
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = @"取消";
    NSString *message = @"是否结束直播？";
    [[AlertActionManager shareAlertActionManager] showWithMessage:message actions:@[ alertCancelModel, alertModel ]];
}

- (void)navigationControllerPop {
    UIViewController *jumpVC = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([NSStringFromClass([vc class]) isEqualToString:@"ChorusRoomListsViewController"]) {
            jumpVC = vc;
            break;
        }
    }
    if (jumpVC) {
        [self.navigationController popToViewController:jumpVC animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)isHost {
    return [self.roomModel.hostUid isEqualToString:[LocalUserComponent userModel].uid];
}

- (void)showPickSongView {
    [self.pickSongComponent show];
}

#pragma mark - Getter

- (ChorusTextInputComponent *)textInputComponent {
    if (!_textInputComponent) {
        _textInputComponent = [[ChorusTextInputComponent alloc] init];
    }
    return _textInputComponent;
}

- (ChorusStaticView *)staticView {
    if (!_staticView) {
        _staticView = [[ChorusStaticView alloc] init];
        __weak typeof(self) weakSelf = self;
        _staticView.closeButtonDidClickBlock = ^{
            if ([weakSelf isHost]) {
                [weakSelf showEndView];
            } else {
                [weakSelf hangUp:YES];
            }
        };
    }
    return _staticView;
}

- (ChorusRoomBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[ChorusRoomBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (ChorusIMComponent *)imComponent {
    if (!_imComponent) {
        _imComponent = [[ChorusIMComponent alloc] initWithSuperView:self.view];
    }
    return _imComponent;
}

- (ChorusMusicComponent *)musicComponent {
    if (!_musicComponent) {
        _musicComponent = [[ChorusMusicComponent alloc] initWithSuperView:self.view];
    }
    return _musicComponent;
}

- (void)dealloc {
    [self.musicComponent dismissTuningPanel];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[AlertActionManager shareAlertActionManager] dismiss:nil];
    [ChorusDataManager destroyDataManager];
}

- (ChorusPickSongComponent *)pickSongComponent {
    if (!_pickSongComponent) {
        _pickSongComponent = [[ChorusPickSongComponent alloc] initWithSuperView:self.view roomID:self.roomModel.roomID];
        _pickSongComponent.delegate = self;
    }
    return _pickSongComponent;
}

@end
