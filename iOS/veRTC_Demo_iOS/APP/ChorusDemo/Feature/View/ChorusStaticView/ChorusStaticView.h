//
//  ChorusStaticView.h
//  veRTC_Demo
//
//  Created by on 2021/11/29.
//  
//

#import <UIKit/UIKit.h>
@class ChorusRoomModel;
@class ChorusRoomParamInfoModel;

NS_ASSUME_NONNULL_BEGIN

/// 背景图片、房主信息以及观众人数展示
/// Background pictures, owner information and audience size display
@interface ChorusStaticView : UIView

@property (nonatomic, copy) void(^closeButtonDidClickBlock)(void);

@property (nonatomic, strong) ChorusRoomModel *roomModel;

- (void)updatePeopleNum:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
