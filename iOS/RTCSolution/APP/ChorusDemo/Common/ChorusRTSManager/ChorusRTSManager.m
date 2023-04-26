// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusRTSManager.h"
#import "ChorusRTCManager.h"
#import "JoinRTSParams.h"

@implementation ChorusRTSManager

#pragma mark - Get Voice data

+ (void)startLive:(NSString *)roomName
         userName:(NSString *)userName
      bgImageName:(NSString *)bgImageName
            block:(void (^)(NSString *RTCToken,
                            ChorusRoomModel *roomModel,
                            ChorusUserModel *hostUserModel,
                            RTSACKModel *model))block {
    NSDictionary *dic = @{@"room_name" : roomName,
                          @"background_image_name" : bgImageName,
                          @"user_name" : userName};
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcStartLive" with:dic block:^(RTSACKModel * _Nonnull ackModel) {

        NSString *RTCToken = @"";
        ChorusRoomModel *roomModel = nil;
        ChorusUserModel *hostUserModel = nil;
        if ([ChorusRTSManager ackModelResponseClass:ackModel]) {
            roomModel = [ChorusRoomModel yy_modelWithJSON:ackModel.response[@"room_info"]];
            hostUserModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"user_info"]];
            RTCToken = [NSString stringWithFormat:@"%@", ackModel.response[@"rtc_token"]];
        }
        if (block) {
            block(RTCToken, roomModel, hostUserModel, ackModel);
        }
        NSLog(@"[%@]-owcStartLive %@ \n %@", [self class], dic, ackModel.response);
    }];
}

+ (void)finishLive:(NSString *)roomID {
    if (IsEmptyStr(roomID)) {
        return;
    }
    NSDictionary *dic = @{@"room_id" : roomID};
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcFinishLive" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        NSLog(@"[%@]-owcFinishLive %@ \n %@", [self class], dic, ackModel.response);
    }];
}

+ (void)requestPickedSongList:(NSString *)roomID
                        block:(void(^)(RTSACKModel *model, NSArray<ChorusSongModel*> *list))block {
    
    if (IsEmptyStr(roomID)) {
        return;
    }
    NSDictionary *dic = @{@"room_id" : roomID};
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcGetRequestSongList" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSArray *list = nil;
        if ([ChorusRTSManager ackModelResponseClass:ackModel]) {
            list = [NSArray yy_modelArrayWithClass:[ChorusSongModel class] json:ackModel.response[@"song_list"]];
        }
        if (block) {
            block(ackModel, list);
        }
        NSLog(@"[%@]-owcGetRequestSongList %@ | %@", [self class], dic, ackModel.response);
    }];
}

+ (void)pickSong:(ChorusSongModel *)songModel
          roomID:(NSString *)roomID
           block:(void (^)(RTSACKModel * _Nonnull))complete {
    NSDictionary *dic = @{
        @"song_id" : songModel.musicId,
        @"room_id" : roomID,
        @"song_name" : songModel.musicName,
        @"song_duration" : @(songModel.musicAllTime),
        @"cover_url" : songModel.coverURLString,
    };
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcRequestSong" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (complete) {
            complete(ackModel);
        }
        NSLog(@"[%@]-owcRequestSong %@ | %@", [self class], dic, ackModel.response);
    }];
}

+ (void)cutOffSong:(NSString *)roomID
             block:(void(^)(RTSACKModel *model))complete {
    NSDictionary *dic = @{
        @"room_id" : roomID,
    };
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcCutOffSong" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (complete) {
            complete(ackModel);
        }
        
        NSLog(@"[%@]-owcCutOffSong %@ | %@", [self class], dic, ackModel.response);
    }];
}

+ (void)finishSing:(NSString *)roomID
            songID:(NSString *)songID
             score:(NSInteger)score
             block:(void(^)(ChorusSongModel *songModel,
                            RTSACKModel *model))complete {
    NSDictionary *dic = @{
        @"room_id" : roomID,
        @"song_id" : songID,
        @"score" : @(score),
    };
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcFinishSing" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        ChorusSongModel *songModel = nil;
        if ([ChorusRTSManager ackModelResponseClass:ackModel]) {
            songModel = [ChorusSongModel yy_modelWithJSON:ackModel.response[@"next_song"]];
        }
        
        if (complete) {
            complete(songModel, ackModel);
        }
        
        NSLog(@"[%@]-owcFinishSing %@ | %@", [self class], dic, ackModel.response);
    }];
}


#pragma mark - Audience API

+ (void)joinLiveRoom:(NSString *)roomID
            userName:(NSString *)userName
               block:(void (^)(NSString *RTCToken,
                               ChorusRoomModel *roomModel,
                               ChorusUserModel *userModel,
                               ChorusUserModel *hostUserModel,
                               ChorusSongModel *songModel,
                               ChorusUserModel *leadSingerUserModel,
                               ChorusUserModel *succentorUserModel,
                               ChorusSongModel *nextSongModel,
                               RTSACKModel *model))block {
    NSDictionary *dic = @{@"room_id" : roomID,
                          @"user_name" : userName};
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcJoinLiveRoom" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSString *RTCToken = @"";
        ChorusRoomModel *roomModel = nil;
        ChorusUserModel *hostUserModel = nil;
        ChorusUserModel *userModel = nil;
        ChorusSongModel *songModel = nil;
        ChorusUserModel *leadSingerUserModel = nil;
        ChorusUserModel *succentorUserModel = nil;
        ChorusSongModel *nextSongModel = nil;
        
        if ([ChorusRTSManager ackModelResponseClass:ackModel]) {
            NSDictionary *songDic = ackModel.response[@"cur_song"];
            songModel = [ChorusSongModel yy_modelWithJSON:songDic];
            
            roomModel = [ChorusRoomModel yy_modelWithJSON:ackModel.response[@"room_info"]];
            hostUserModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"host_info"]];
            userModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"user_info"]];
            RTCToken = [NSString stringWithFormat:@"%@", ackModel.response[@"rtc_token"]];
            leadSingerUserModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"leader_user"]];
            succentorUserModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"succentor_user"]];
            nextSongModel = [ChorusSongModel yy_modelWithJSON:ackModel.response[@"next_song"]];
        }
        if (block) {
            block(RTCToken,
                  roomModel,
                  userModel,
                  hostUserModel,
                  songModel,
                  leadSingerUserModel,
                  succentorUserModel,
                  nextSongModel,
                  ackModel);
        }
        NSLog(@"[%@]-owcJoinLiveRoom %@ \n %@", [self class], dic, ackModel.response);
    }];
}

+ (void)leaveLiveRoom:(NSString *)roomID {
    NSDictionary *dic = @{@"room_id" : roomID};
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcLeaveLiveRoom" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        NSLog(@"[%@]-owcLeaveLiveRoom %@ \n %@", [self class], dic, ackModel.response);
    }];
}


#pragma mark - Publish API

+ (void)getActiveLiveRoomListWithBlock:(void (^)(NSArray<ChorusRoomModel *> *roomList,
                                                 RTSACKModel *model))block {
    NSDictionary *dic = [JoinRTSParams addTokenToParams:nil];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcGetActiveLiveRoomList" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSMutableArray<ChorusRoomModel *> *roomModelList = [[NSMutableArray alloc] init];
        if ([ChorusRTSManager ackModelResponseClass:ackModel]) {
            NSArray *list = ackModel.response[@"room_list"];
            for (int i = 0; i < list.count; i++) {
                ChorusRoomModel *roomModel = [ChorusRoomModel yy_modelWithJSON:list[i]];
                [roomModelList addObject:roomModel];
            }
        }
        if (block) {
            block([roomModelList copy], ackModel);
        }
        NSLog(@"[%@]-owcGetActiveLiveRoomList %@ \n %@", [self class], dic, ackModel.response);
    }];
}

+ (void)sendMessage:(NSString *)roomID
            message:(NSString *)message
              block:(void (^)(RTSACKModel *model))block {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)message,NULL,NULL,kCFStringEncodingUTF8));
    NSDictionary *dic = @{@"room_id" : roomID,
                          @"message" : encodedString};
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcSendMessage" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
        NSLog(@"[%@]-owcSendMessage %@ \n %@", [self class], dic, ackModel.response);
    }];
}

/// 开始独唱或者合唱
/// @param roomID 房间ID
/// @param songID 歌曲ID
/// @param type 1独唱 2合唱
/// @param block 回调
+ (void)startSingWithRoomID:(NSString *)roomID
                     songID:(NSString *)songID
                       type:(NSInteger)type
                      block:(void(^)(RTSACKModel *model))block {
    NSDictionary *dic = @{
        @"room_id" : roomID,
        @"song_id" : songID,
        @"type" : @(type).stringValue
    };
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcStartSing" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
        NSLog(@"[%@]-owcStartSing %@ \n %@", [self class], dic, ackModel.response);
    }];
}

/// 清理用户状态
/// @param block 回调
+ (void)clearUser:(void(^)(RTSACKModel *model))block {
    NSDictionary *dic = @{};
    dic = [JoinRTSParams addTokenToParams:dic];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcClearUser" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
        NSLog(@"[%@]-owcClearUser %@ \n %@", [self class], dic, ackModel.response);
    }];
}

/// 断线重连
/// @param block Callback
+ (void)reconnectWithBlock:(void(^)(NSString *RTCToken,
                                    ChorusRoomModel *roomModel,
                                    ChorusUserModel *userModel,
                                    ChorusUserModel *hostUserModel,
                                    ChorusSongModel *songModel,
                                    ChorusUserModel *leadSingerUserModel,
                                    ChorusUserModel *succentorUserModel,
                                    ChorusSongModel *nextSongModel,
                                    NSInteger audienceCount,
                                    RTSACKModel *model))block {
    NSDictionary *dic = [JoinRTSParams addTokenToParams:nil];
    
    [[ChorusRTCManager shareRtc] emitWithAck:@"owcReconnect" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSString *RTCToken = @"";
        ChorusRoomModel *roomModel = nil;
        ChorusUserModel *hostUserModel = nil;
        ChorusUserModel *userModel = nil;
        ChorusSongModel *songModel = nil;
        ChorusUserModel *leadSingerUserModel = nil;
        ChorusUserModel *succentorUserModel = nil;
        ChorusSongModel *nextSongModel = nil;
        NSInteger count = -1;
        if ([ChorusRTSManager ackModelResponseClass:ackModel]) {
            NSDictionary *songDic = ackModel.response[@"cur_song"];
            songModel = [ChorusSongModel yy_modelWithJSON:songDic];
            
            roomModel = [ChorusRoomModel yy_modelWithJSON:ackModel.response[@"room_info"]];
            hostUserModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"host_info"]];
            userModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"user_info"]];
            RTCToken = [NSString stringWithFormat:@"%@", ackModel.response[@"rtc_token"]];
            leadSingerUserModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"leader_user"]];
            succentorUserModel = [ChorusUserModel yy_modelWithJSON:ackModel.response[@"succentor_user"]];
            nextSongModel = [ChorusSongModel yy_modelWithJSON:ackModel.response[@"next_song"]];
            NSString *str = [NSString stringWithFormat:@"%@", ackModel.response[@"audience_count"]];
            count = [str integerValue];
        }
        if (block) {
            block(RTCToken,
                  roomModel,
                  userModel,
                  hostUserModel,
                  songModel,
                  leadSingerUserModel,
                  succentorUserModel,
                  nextSongModel,
                  count,
                  ackModel);
        }
    }];
}

#pragma mark - Notification Message

+ (void)onAudienceJoinRoomWithBlock:(void (^)(ChorusUserModel *userModel,
                                              NSInteger count))block {
    [[ChorusRTCManager shareRtc] onSceneListener:@"owcOnAudienceJoinRoom" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        ChorusUserModel *model = nil;
        NSInteger count = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [ChorusUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"audience_count"]];
            count = [str integerValue];
        }
        if (block) {
            block(model, count);
        }
        NSLog(@"[%@]-owcOnAudienceJoinRoom %@", [self class], noticeModel.data);
    }];
}

+ (void)onAudienceLeaveRoomWithBlock:(void (^)(ChorusUserModel *userModel,
                                               NSInteger count))block {
    [[ChorusRTCManager shareRtc] onSceneListener:@"owcOnAudienceLeaveRoom" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        ChorusUserModel *model = nil;
        NSInteger count = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [ChorusUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"audience_count"]];
            count = [str integerValue];
        }
        if (block) {
            block(model, count);
        }
        NSLog(@"[%@]-owcOnAudienceLeaveRoom %@", [self class], noticeModel.data);
    }];
}

+ (void)onFinishLiveWithBlock:(void (^)(NSString *rommID, NSInteger type))block {
    [[ChorusRTCManager shareRtc] onSceneListener:@"owcOnFinishLive" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        NSInteger type = -1;
        NSString *rommID = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"type"]];
            type = [str integerValue];
            rommID = [NSString stringWithFormat:@"%@", noticeModel.data[@"room_id"]];
        }
        if (block) {
            block(rommID, type);
        }
        NSLog(@"[%@]-owcOnFinishLive %@", [self class], noticeModel.data);
    }];
}

+ (void)onMessageWithBlock:(void (^)(ChorusUserModel *userModel,
                                     NSString *message))block {
    [[ChorusRTCManager shareRtc] onSceneListener:@"owcOnMessage" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        ChorusUserModel *model = nil;
        NSString *message = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [ChorusUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            message = [NSString stringWithFormat:@"%@", noticeModel.data[@"message"]];
        }
        if (block) {
            block(model, message);
        }
        NSLog(@"[%@]-owcOnMessage %@", [self class], noticeModel.data);
    }];
}

+ (void)onPickSongBlock:(void(^)(ChorusSongModel *songModel))block {
    [[ChorusRTCManager shareRtc] onSceneListener:@"owcOnRequestSong" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        ChorusSongModel *songModel = nil;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            songModel = [ChorusSongModel yy_modelWithJSON:noticeModel.data[@"song"]];
        }
        if (block) {
            block(songModel);
        }
        NSLog(@"[%@]-owcOnRequestSong %@", [self class], noticeModel.data);
    }];
}

/// Prepare start sing song
/// @param block Callback
+ (void)onPrepareStartSingSongBlock:(void(^)(ChorusSongModel *_Nullable songModel,
                                             ChorusUserModel *_Nullable leadSingerUserModel))block {
    [[ChorusRTCManager shareRtc] onSceneListener:@"owcOnWaitSing" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        ChorusSongModel *songModel = nil;
        ChorusUserModel *leadSingerUserModel = nil;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            songModel = [ChorusSongModel yy_modelWithJSON:noticeModel.data[@"song"]];
            leadSingerUserModel = [ChorusUserModel yy_modelWithJSON:noticeModel.data[@"leader_user"]];
        }
        if (block) {
            block(songModel, leadSingerUserModel);
        }
        NSLog(@"[%@]-owcOnWaitSing %@", [self class], noticeModel.data);
    }];
}

/// Really start sing song
/// @param block Callback
+ (void)onReallyStartSingSongBlock:(void(^)(ChorusSongModel *songModel,
                                            ChorusUserModel *leadSingerUserModel,
                                            ChorusUserModel *succentorUserModel))block {
    [[ChorusRTCManager shareRtc] onSceneListener:@"owcOnStartSing" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        ChorusSongModel *songModel = nil;
        ChorusUserModel *leadSingerUserModel = nil;
        ChorusUserModel *succentorUserModel = nil;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            songModel = [ChorusSongModel yy_modelWithJSON:noticeModel.data[@"song"]];
            leadSingerUserModel = [ChorusUserModel yy_modelWithJSON:noticeModel.data[@"leader_user"]];
            succentorUserModel = [ChorusUserModel yy_modelWithJSON:noticeModel.data[@"succentor_user"]];
        }
        if (block) {
            block(songModel, leadSingerUserModel, succentorUserModel);
        }
        NSLog(@"[%@]-owcOnStartSing %@", [self class], noticeModel.data);
    }];
}

+ (void)onFinishSingSongBlock:(void(^)(ChorusSongModel *nextSongModel, NSInteger score))block {
    [[ChorusRTCManager shareRtc] onSceneListener:@"owcOnFinishSing" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        ChorusSongModel *nextSongModel = nil;
        NSInteger score = 0;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            nextSongModel = [ChorusSongModel yy_modelWithJSON:noticeModel.data[@"next_song"]];
            score = [noticeModel.data[@"score"] integerValue];
        }
        if (block) {
            block(nextSongModel, score);
        }
        NSLog(@"[%@]-owcOnFinishSing %@", [self class], noticeModel.data);
    }];
}

#pragma mark - tool

+ (BOOL)ackModelResponseClass:(RTSACKModel *)ackModel {
    if ([ackModel.response isKindOfClass:[NSDictionary class]]) {
        return YES;
    } else {
        return NO;
    }
}

@end
