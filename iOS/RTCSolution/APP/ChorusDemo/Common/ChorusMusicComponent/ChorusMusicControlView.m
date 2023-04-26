// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusMusicControlView.h"
#import "ChorusDataManager.h"

@interface ChorusMusicControlView ()

@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) UIImageView *scoreImageView;

@property (nonatomic, strong) UILabel *musicTitleLabel;
@property (nonatomic, strong) UILabel *musicTimeLabel;
@property (nonatomic, strong) BaseButton *nextButton;
@property (nonatomic, strong) BaseButton *tuningButton;
@property (nonatomic, strong) BaseButton *originalButton;

@end

@implementation ChorusMusicControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.lineImageView];
        [self addSubview:self.scoreImageView];
        [self addSubview:self.musicTitleLabel];
        [self addSubview:self.musicTimeLabel];
        [self addSubview:self.nextButton];
        [self addSubview:self.tuningButton];
        [self addSubview:self.originalButton];
        
        [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(14);
        }];
        
        [self.scoreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.left.mas_equalTo(13);
        }];
        
        [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 36));
            make.top.mas_equalTo(28);
            make.right.mas_equalTo(-16);
        }];
        
        [self.tuningButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 36));
            make.top.mas_equalTo(28);
            make.right.equalTo(self.nextButton.mas_left).offset(-20);
        }];
        
        [self.originalButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 36));
            make.top.mas_equalTo(28);
            make.right.equalTo(self.tuningButton.mas_left).offset(-20);
        }];
        
        [self.musicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(25);
            make.left.equalTo(self.scoreImageView.mas_right).offset(11);
            make.right.lessThanOrEqualTo(self.originalButton.mas_left).offset(-5);
        }];
        
        [self.musicTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicTitleLabel.mas_bottom).offset(4);
            make.left.equalTo(self.musicTitleLabel);
        }];
    }
    return self;
}

#pragma mark - Publish Action
/// 更新UI
- (void)updateUI {
    
    if ([ChorusDataManager shared].isLeadSinger) {
        self.nextButton.hidden = NO;
        self.tuningButton.hidden = NO;
        self.originalButton.hidden = NO;
        
        [self.tuningButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 36));
            make.top.mas_equalTo(28);
            make.right.equalTo(self.nextButton.mas_left).offset(-20);
        }];
    }
    else if ([ChorusDataManager shared].isSuccentor) {
        self.nextButton.hidden = YES;
        self.tuningButton.hidden = NO;
        self.originalButton.hidden = YES;
        
        [self.tuningButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 36));
            make.top.mas_equalTo(28);
            make.right.equalTo(self).offset(-16);
        }];
    }
    else {
        self.nextButton.hidden = YES;
        self.tuningButton.hidden = YES;
        self.originalButton.hidden = YES;
    }
    
    self.musicTitleLabel.text = [ChorusDataManager shared].currentSongModel.musicName;
    self.originalButton.status = ButtonStatusNone;
    self.time = 0;
}

- (void)setTime:(NSTimeInterval)time {
    _time = time;
    
    self.musicTimeLabel.text = [NSString stringWithFormat:@"%@ / %@", [self secondsToMinutes:time], [self secondsToMinutes:(long)[ChorusDataManager shared].currentSongModel.musicAllTime]];
}

- (NSString *)secondsToMinutes:(NSInteger)allSecond {
    NSInteger minute = allSecond / 60;
    NSInteger second = allSecond - (minute * 60);
    NSString *minuteStr = (minute < 10) ? [NSString stringWithFormat:@"0%ld", minute] : [NSString stringWithFormat:@"%ld", (long)minute];
    NSString *secondStr = (second < 10) ? [NSString stringWithFormat:@"0%ld", second] : [NSString stringWithFormat:@"%ld", (long)second];
    return [NSString stringWithFormat:@"%@:%@", minuteStr, secondStr];
}

- (void)buttonAction:(BaseButton *)sender {
    MusicControlState state = MusicControlStateNone;
    if (sender == self.originalButton) {
        state = MusicControlStateOriginal;
        sender.status = (sender.status == ButtonStatusNone) ? ButtonStatusActive : ButtonStatusNone;
    } else if (sender == self.tuningButton) {
        state = MusicControlStateTuning;
    } else if (sender == self.nextButton) {
        state = MusicControlStateNext;
    } else {
        //error
    }
    
    BOOL isSelect = (sender.status == ButtonStatusActive) ? YES : NO;
    if (self.clickButtonBlock) {
        self.clickButtonBlock(state, isSelect, sender);
    }
}

#pragma mark - Getter

- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chorus_control_line" bundleName:HomeBundleName]];
    }
    return _lineImageView;
}

- (UIImageView *)scoreImageView {
    if (!_scoreImageView) {
        _scoreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chorus_control_music" bundleName:HomeBundleName]];
    }
    return _scoreImageView;
}

- (UILabel *)musicTitleLabel {
    if (!_musicTitleLabel) {
        _musicTitleLabel = [[UILabel alloc] init];
        _musicTitleLabel.textColor = [UIColor whiteColor];
        _musicTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _musicTitleLabel;
}

- (UILabel *)musicTimeLabel {
    if (!_musicTimeLabel) {
        _musicTimeLabel = [[UILabel alloc] init];
        _musicTimeLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.7];
        _musicTimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _musicTimeLabel;
}

- (BaseButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [[BaseButton alloc] init];
        [_nextButton setImage:[UIImage imageNamed:@"chorus_next" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (BaseButton *)tuningButton {
    if (!_tuningButton) {
        _tuningButton = [[BaseButton alloc] init];
        [_tuningButton setImage:[UIImage imageNamed:@"chorus_tuning" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_tuningButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tuningButton;
}

- (BaseButton *)originalButton {
    if (!_originalButton) {
        _originalButton = [[BaseButton alloc] init];
        [_originalButton bingImage:[UIImage imageNamed:@"chorus_switch" bundleName:HomeBundleName] status:ButtonStatusNone];
        [_originalButton bingImage:[UIImage imageNamed:@"chorus_switch_s" bundleName:HomeBundleName] status:ButtonStatusActive];
        [_originalButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _originalButton;
}

@end
