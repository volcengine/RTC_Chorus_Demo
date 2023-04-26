// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusIMModel : NSObject

@property (nonatomic, assign) BOOL isJoin;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) ChorusUserModel *userModel;

@end

NS_ASSUME_NONNULL_END
