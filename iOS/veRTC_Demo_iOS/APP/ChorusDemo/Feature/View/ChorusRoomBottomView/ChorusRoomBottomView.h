//
//  ChorusRoomBottomView.h
//  quickstart
//
//  Created by on 2021/3/23.
//  
//

#import <UIKit/UIKit.h>
#import "ChorusRoomItemButton.h"
@class ChorusRoomBottomView;

typedef NS_ENUM(NSInteger, ChorusRoomBottomStatus) {
    ChorusRoomBottomStatusLocalMic = 0,
    ChorusRoomBottomStatusInput,
    ChorusRoomBottomStatusPickSong,
    ChorusRoomBottomStatusLocalCamera,
};

@protocol ChorusRoomBottomViewDelegate <NSObject>

- (void)chorusRoomBottomView:(ChorusRoomBottomView *_Nonnull)ChorusRoomBottomView
                     itemButton:(ChorusRoomItemButton *_Nullable)itemButton
                didSelectStatus:(ChorusRoomBottomStatus)status;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ChorusRoomBottomView : UIView

@property (nonatomic, weak) id<ChorusRoomBottomViewDelegate> delegate;

- (void)updateBottomLists;

- (void)updatePickedSongCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
