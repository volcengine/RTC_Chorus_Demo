//
//  ChorusPickSongListView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
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
