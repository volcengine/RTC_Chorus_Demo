// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>
#import "ChorusUserModel.h"
#import "ChorusRoomModel.h"
#import "ChorusControlRecordModel.h"
#import "RTSACKModel.h"
#import "ChorusSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusRTSManager : NSObject

#pragma mark - Host API

/// The host creates a live room
/// @param roomName Room Name
/// @param userName User Name
/// @param bgImageName Bg Image Name
/// @param block Callback
+ (void)startLive:(NSString *)roomName
         userName:(NSString *)userName
      bgImageName:(NSString *)bgImageName
            block:(void (^)(NSString *RTCToken,
                            ChorusRoomModel *roomModel,
                            ChorusUserModel *hostUserModel,
                            RTSACKModel *model))block;

/// The host ends the live broadcast
/// @param roomID Room ID
+ (void)finishLive:(NSString *)roomID;

/// Request picked list
/// @param block Callback
+ (void)requestPickedSongList:(NSString *)roomID
                        block:(void(^)(RTSACKModel *model, NSArray<ChorusSongModel*> *list))block;

/// Request pick song
/// @param songModel Song model
/// @param roomID RoomID
/// @param complete Callback
+ (void)pickSong:(ChorusSongModel *)songModel
          roomID:(NSString *)roomID
           block:(void(^)(RTSACKModel *model))complete;


+ (void)cutOffSong:(NSString *)roomID
             block:(void(^)(RTSACKModel *model))complete;

+ (void)finishSing:(NSString *)roomID
            songID:(NSString *)songID
             score:(NSInteger)score
             block:(void(^)(ChorusSongModel *songModel,
                            RTSACKModel *model))complete;


#pragma mark - Audience API


/// The audience joins the room
/// @param roomID Room ID
/// @param userName User Name
/// @param block Callback
+ (void)joinLiveRoom:(NSString *)roomID
            userName:(NSString *)userName
               block:(void (^)(NSString *RTCToken,
                               ChorusRoomModel *roomModel,
                               ChorusUserModel *userModel,
                               ChorusUserModel *hostUserModel,
                               ChorusSongModel *_Nullable songModel,
                               ChorusUserModel *_Nullable leadSingerUserModel,
                               ChorusUserModel *_Nullable succentorUserModel,
                               ChorusSongModel *_Nullable nextSongModel,
                               RTSACKModel *model))block;


/// The audience leaves the room
/// @param roomID Room ID
+ (void)leaveLiveRoom:(NSString *)roomID;


#pragma mark - Publish API


/// Received the audience
/// @param block Callback
+ (void)getActiveLiveRoomListWithBlock:(void (^)(NSArray<ChorusRoomModel *> *roomList,
                                                 RTSACKModel *model))block;

/// Send IM message
/// @param roomID Room ID
/// @param message Message
/// @param block Callback
+ (void)sendMessage:(NSString *)roomID
            message:(NSString *)message
              block:(void (^)(RTSACKModel *model))block;

/// 开始独唱或者合唱
/// @param roomID 房间ID
/// @param songID 歌曲ID
/// @param type 1独唱 2合唱
/// @param block 回调
+ (void)startSingWithRoomID:(NSString *)roomID
                     songID:(NSString *)songID
                       type:(NSInteger)type
                      block:(void(^)(RTSACKModel *model))block;

/// 清理用户状态
/// @param block Callback
+ (void)clearUser:(void(^)(RTSACKModel *model))block;

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
                                    RTSACKModel *model))block;

#pragma mark - Notification Message


/// The audience joins the room
/// @param block Callback
+ (void)onAudienceJoinRoomWithBlock:(void (^)(ChorusUserModel *userModel,
                                              NSInteger count))block;


/// The audience leaves the room
/// @param block Callback
+ (void)onAudienceLeaveRoomWithBlock:(void (^)(ChorusUserModel *userModel,
                                               NSInteger count))block;


/// Received the end of the live broadcast room
/// @param block Callback
+ (void)onFinishLiveWithBlock:(void (^)(NSString *rommID, NSInteger type))block;


/// IM message received
/// @param block Callback
+ (void)onMessageWithBlock:(void (^)(ChorusUserModel *userModel,
                                     NSString *message))block;

/// Pick song received
/// @param block Callback
+ (void)onPickSongBlock:(void(^)(ChorusSongModel *songModel))block;

/// Prepare start sing song
/// @param block Callback
+ (void)onPrepareStartSingSongBlock:(void(^)(ChorusSongModel *_Nullable songModel,
                                             ChorusUserModel *_Nullable leadSingerUserModel))block;

/// Really start sing song
/// @param block Callback
+ (void)onReallyStartSingSongBlock:(void(^)(ChorusSongModel *songModel,
                                            ChorusUserModel *leadSingerUserModel,
                                            ChorusUserModel *_Nullable succentorUserModel))block;

/// Finish sing song
/// @param block Callback
+ (void)onFinishSingSongBlock:(void(^)(ChorusSongModel *nextSongModel, NSInteger score))block;

@end

NS_ASSUME_NONNULL_END
