// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>
@class ChorusPickSongComponent;

NS_ASSUME_NONNULL_BEGIN

@protocol ChorusPickSongComponentDelegate <NSObject>

- (void)ChorusPickSongComponent:(ChorusPickSongComponent *)component pickedSongCountChanged:(NSInteger)count;

@end

@interface ChorusPickSongComponent : NSObject

@property (nonatomic, weak) id<ChorusPickSongComponentDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)superView roomID:(NSString *)roomID;

- (void)show;

/// Update pieked song list
- (void)updatePickedSongList;

@end

NS_ASSUME_NONNULL_END
