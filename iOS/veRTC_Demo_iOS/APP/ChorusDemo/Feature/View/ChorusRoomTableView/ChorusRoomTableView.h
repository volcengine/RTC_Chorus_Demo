//
//  ChorusRoomTableView.h
//  veRTC_Demo
//
//  Created by on 2021/5/18.
//  
//

#import <UIKit/UIKit.h>
#import "ChorusRoomCell.h"
@class ChorusRoomTableView;

NS_ASSUME_NONNULL_BEGIN

@protocol ChorusRoomTableViewDelegate <NSObject>

- (void)ChorusRoomTableView:(ChorusRoomTableView *)ChorusRoomTableView didSelectRowAtIndexPath:(ChorusRoomModel *)model;

@end

@interface ChorusRoomTableView : UIView

@property (nonatomic, copy) NSArray *dataLists;

@property (nonatomic, weak) id<ChorusRoomTableViewDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
