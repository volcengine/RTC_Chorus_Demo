// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <UIKit/UIKit.h>
@class ChorusSongModel;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChorusSongListViewType) {
    ChorusSongListViewTypeOnline,
    ChorusSongListViewTypePicked,
};

@interface ChorusPickSongTableViewCell : UITableViewCell

@property (nonatomic, assign) ChorusSongListViewType type;

@property (nonatomic, strong) ChorusSongModel *songModel;
@property (nonatomic, copy) void(^pickSongBlock)(ChorusSongModel *model);

@end

NS_ASSUME_NONNULL_END
