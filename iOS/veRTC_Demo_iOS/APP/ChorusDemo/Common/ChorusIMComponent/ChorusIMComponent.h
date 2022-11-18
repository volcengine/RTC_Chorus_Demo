//
//  ChorusIMComponent.h
//  veRTC_Demo
//
//  Created by on 2021/5/23.
//  
//

#import <Foundation/Foundation.h>
#import "ChorusIMModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusIMComponent : NSObject

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)addIM:(ChorusIMModel *)model;

@end

NS_ASSUME_NONNULL_END
