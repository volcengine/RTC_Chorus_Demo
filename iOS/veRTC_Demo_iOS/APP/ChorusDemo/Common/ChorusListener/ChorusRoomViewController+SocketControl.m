//
//  ChorusRoomViewController+SocketControl.m
//  veRTC_Demo
//
//  Created by on 2021/5/28.
//  
//

#import "ChorusRoomViewController+SocketControl.h"
#import "ChorusPickSongManager.h"

@implementation ChorusRoomViewController (SocketControl)

- (void)addSocketListener {
    __weak __typeof(self) wself = self;
    [ChorusRTSManager onAudienceJoinRoomWithBlock:^(ChorusUserModel * _Nonnull userModel, NSInteger count) {
        if (wself) {
            [wself receivedJoinUser:userModel count:count];
        }
    }];
    
    
    [ChorusRTSManager onAudienceLeaveRoomWithBlock:^(ChorusUserModel * _Nonnull userModel, NSInteger count) {
        if (wself) {
            [wself receivedLeaveUser:userModel count:count];
        }
    }];

    
    [ChorusRTSManager onFinishLiveWithBlock:^(NSString * _Nonnull rommID, NSInteger type) {
        if (wself) {
            [wself receivedFinishLive:type roomID:rommID];
        }
    }];

    
    [ChorusRTSManager onMessageWithBlock:^(ChorusUserModel * _Nonnull userModel, NSString * _Nonnull message) {
        if (wself) {
            message = [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [wself receivedMessageWithUser:userModel message:message];
        }
    }];
    
    [ChorusRTSManager onPickSongBlock:^(ChorusSongModel * _Nonnull songModel) {
        [wself receivedPickedSong:songModel];
    }];
    
    [ChorusRTSManager onPrepareStartSingSongBlock:^(ChorusSongModel * _Nullable songModel,
                                                    ChorusUserModel * _Nullable leadSingerUserModel) {
        [wself receivedPrepareStartSingSong:songModel
                        leadSingerUserModel:leadSingerUserModel];
    }];
    
    [ChorusRTSManager onReallyStartSingSongBlock:^(ChorusSongModel * _Nonnull songModel,
                                                   ChorusUserModel * _Nonnull leadSingerUserModel,
                                                   ChorusUserModel * _Nullable succentorUserModel) {
        
        [wself receivedReallyStartSingSong:songModel
                       leadSingerUserModel:leadSingerUserModel
                        succentorUserModel:succentorUserModel];
    }];
    
    [ChorusRTSManager onFinishSingSongBlock:^(ChorusSongModel * _Nonnull nextSongModel, NSInteger score) {
        [wself receivedFinishSingSong:score nextSongModel:nextSongModel];
    }];
}
@end
