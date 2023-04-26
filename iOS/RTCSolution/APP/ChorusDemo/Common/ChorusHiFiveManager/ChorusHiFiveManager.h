// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>
@class ChorusDownloadSongModel;

NS_ASSUME_NONNULL_BEGIN

@interface ChorusHiFiveManager : NSObject

/// HiFive register
+ (void)registerHiFive;

/// Request HiFive song list
/// @param complete Callback
+ (void)requestHiFiveSongListComplete:(void(^)(NSArray<ChorusSongModel*> *_Nullable list, NSString *_Nullable errorMessage))complete;

/// Request download song model
/// @param songModel Song model
/// @param complete Callback
+ (void)requestDownloadSongModel:(ChorusSongModel *)songModel complete:(void(^)(ChorusDownloadSongModel *downloadSongModel, NSError *error))complete;

@end

NS_ASSUME_NONNULL_END
