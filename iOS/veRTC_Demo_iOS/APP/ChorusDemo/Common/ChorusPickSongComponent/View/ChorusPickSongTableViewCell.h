//
//  ChorusPickSongTableViewCell.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
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
