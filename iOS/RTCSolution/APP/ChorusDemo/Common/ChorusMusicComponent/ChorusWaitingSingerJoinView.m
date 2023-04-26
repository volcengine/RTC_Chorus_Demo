// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusWaitingSingerJoinView.h"
#import "ChorusDataManager.h"

@interface ChorusWaitingSingerJoinView ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, assign) ChorusSingingType actionType;

@end

@implementation ChorusWaitingSingerJoinView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topView];
        [self addSubview:self.actionButton];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.centerX.equalTo(self);
            make.height.mas_equalTo(24);
        }];
        [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.songNameLabel.mas_bottom).offset(42);
            make.bottom.equalTo(self);
            make.centerX.equalTo(self);
            make.size.mas_offset(CGSizeMake(240, 44));
        }];
    }
    return self;
}

- (void)updateUI {
    if ([ChorusDataManager shared].isLeadSinger) {
        self.songNameLabel.text = veString(@"等待合唱者加入");
        self.topView.hidden = YES;
        [self.actionButton setTitle:@"不等了,开始独唱" forState:UIControlStateNormal];
        self.actionType = ChorusSingingTypeSolo;
    }
    else {
        self.songNameLabel.text = [NSString stringWithFormat:@"《%@》", [ChorusDataManager shared].currentSongModel.musicName];
        self.topView.hidden = NO;
        [self.actionButton setTitle:@"加入合唱" forState:UIControlStateNormal];
        self.actionType = ChorusSingingTypeChorus;
    }
}

- (void)actionButtonClick {
    if (self.startSingingTypeBlock) {
        self.startSingingTypeBlock(self.actionType);
    }
}

#pragma mark - getter
- (UILabel *)songNameLabel {
    if (!_songNameLabel) {
        _songNameLabel = [[UILabel alloc] init];
        _songNameLabel.font = [UIFont systemFontOfSize:14];
        _songNameLabel.textColor = [UIColor whiteColor];
    }
    return _songNameLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        _actionButton.layer.cornerRadius = 22;
        _actionButton.layer.borderWidth = 0.5;
        _actionButton.layer.borderColor = [[UIColor colorFromHexString:@"#FFFFFF"] colorWithAlphaComponent:0.4].CGColor;
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_actionButton setImage:[UIImage imageNamed:@"chorus_waiting_icon" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(actionButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chorus_prepare_singing_icon" bundleName:HomeBundleName]];
        
        [_topView addSubview:imageView];
        [_topView addSubview:self.songNameLabel];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_topView);
            make.centerY.equalTo(_topView);
        }];
        [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right);
            make.centerY.equalTo(_topView);
            make.right.equalTo(_topView);
        }];
    }
    return _topView;
}

@end
