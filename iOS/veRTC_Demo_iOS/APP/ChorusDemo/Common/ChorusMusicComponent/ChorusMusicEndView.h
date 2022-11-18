//
//  ChorusMusicEndView.h
//  veRTC_Demo
//
//  Created by on 2022/1/20.
//  
//

#import <UIKit/UIKit.h>
#import "ChorusSongModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 歌曲播放完后，展示下一首提示
@interface ChorusMusicEndView : UIView

/// 展示播放结束View
/// @param songModel 下一首歌曲信息
- (void)showEndViewWithNextSongModel:(ChorusSongModel *_Nullable)songModel;

@end

NS_ASSUME_NONNULL_END
