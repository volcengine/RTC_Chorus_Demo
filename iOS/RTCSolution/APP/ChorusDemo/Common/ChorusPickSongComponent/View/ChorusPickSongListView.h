// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <UIKit/UIKit.h>
#import "ChorusPickSongTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusPickSongListView : UIView

@property (nonatomic, copy) NSArray<ChorusSongModel*> *dataArray;
@property (nonatomic, copy) void(^pickSongBlock)(ChorusSongModel *songModel);

- (instancetype)initWithType:(ChorusSongListViewType)type;

- (void)refreshView;

@end

NS_ASSUME_NONNULL_END
