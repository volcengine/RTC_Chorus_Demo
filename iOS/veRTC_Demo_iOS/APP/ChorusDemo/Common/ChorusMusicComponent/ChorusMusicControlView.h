//
//  ChorusMusicTopView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <UIKit/UIKit.h>
#import "ChorusSongModel.h"

typedef NS_ENUM(NSInteger, MusicControlState) {
    MusicControlStateNone = 0,
    MusicControlStateOriginal,
    MusicControlStateTuning,
    MusicControlStateNext,
};

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicControlView : UIView

@property (nonatomic, copy) void (^clickButtonBlock) (MusicControlState state,
                                                      BOOL isSelect,
                                                      BaseButton *button);

@property (nonatomic, assign) NSTimeInterval time;

/// 更新UI
- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
