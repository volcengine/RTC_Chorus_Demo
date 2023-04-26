// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>
#import "ChorusIMModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusIMComponent : NSObject

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)addIM:(ChorusIMModel *)model;

@end

NS_ASSUME_NONNULL_END
