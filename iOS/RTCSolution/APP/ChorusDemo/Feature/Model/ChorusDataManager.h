// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 数据管理类
/// Data Management
@interface ChorusDataManager : NSObject

@property (nonatomic, strong) ChorusRoomModel *roomModel;
@property (nonatomic, strong) ChorusUserModel *_Nullable leadSingerUserModel;
@property (nonatomic, strong) ChorusUserModel *_Nullable succentorUserModel;
@property (nonatomic, strong) ChorusSongModel *_Nullable currentSongModel;

/// 自己是主播
@property (nonatomic, assign, readonly) BOOL isHost;
/// 自己是主唱
@property (nonatomic, assign, readonly) BOOL isLeadSinger;
/// 自己是副唱
@property (nonatomic, assign, readonly) BOOL isSuccentor;

+ (instancetype)shared;

+ (void)destroyDataManager;

- (void)resetDataManager;

@end

NS_ASSUME_NONNULL_END
