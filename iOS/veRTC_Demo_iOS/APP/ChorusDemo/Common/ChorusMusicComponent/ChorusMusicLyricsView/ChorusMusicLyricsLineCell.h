//
//  ChorusMusicLyricsLineCell.h
//  veRTC_Demo
//
//  Created by on 2022/1/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChorusMusicLyricsLine;
@interface ChorusMusicLyricsLineCell : UITableViewCell

+ (NSString *)reuseIdentifier;

- (void)fillLyricsLine:(ChorusMusicLyricsLine *)lyricsLine;
- (void)showHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
