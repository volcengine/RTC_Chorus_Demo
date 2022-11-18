//
//  ChorusRoomViewController.h
//  veRTC_Demo
//
//  Created by on 2021/5/18.
//  
//

#import <UIKit/UIKit.h>
#import "ChorusSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusRoomViewController : UIViewController

- (instancetype)initWithRoomModel:(ChorusRoomModel *)roomModel;

- (instancetype)initWithRoomModel:(ChorusRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(ChorusUserModel *)hostUserModel;

- (void)receivedJoinUser:(ChorusUserModel *)userModel
                   count:(NSInteger)count;

- (void)receivedLeaveUser:(ChorusUserModel *)userModel
                    count:(NSInteger)count;

- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID;

- (void)receivedMessageWithUser:(ChorusUserModel *)userModel
                            message:(NSString *)message;

- (void)receivedPickedSong:(ChorusSongModel *)songModel;


/// 开始进入演唱准备阶段（等待合唱者加入）
/// @param songModel 歌曲Model
/// @param leadSingerUserModel 主唱信息
- (void)receivedPrepareStartSingSong:(ChorusSongModel *_Nullable)songModel
                 leadSingerUserModel:(ChorusUserModel *_Nullable)leadSingerUserModel;

/// 真正开始演唱歌曲
/// @param songModel 歌曲信息
/// @param leadSingerUserModel 主唱信息
/// @param succentorUserModel 副唱信息
- (void)receivedReallyStartSingSong:(ChorusSongModel *)songModel
                leadSingerUserModel:(ChorusUserModel *)leadSingerUserModel
                 succentorUserModel:( ChorusUserModel * _Nullable)succentorUserModel;

- (void)receivedFinishSingSong:(NSInteger)score nextSongModel:(ChorusSongModel *)nextSongModel;

@end

NS_ASSUME_NONNULL_END
