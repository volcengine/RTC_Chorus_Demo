// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusMusicEndView.h"

@interface ChorusMusicEndView ()

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation ChorusMusicEndView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-12);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)showEndViewWithNextSongModel:(ChorusSongModel *)songModel {
    if (NOEmptyStr(songModel.musicName)) {
        self.tipLabel.text = [NSString stringWithFormat:veString(@"播放结束，即将播放《%@》"), songModel.musicName];
    } else {
        self.tipLabel.text = veString(@"播放结束");
    }
}

#pragma mark - Getter

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.6];
    }
    return _tipLabel;
}

@end
