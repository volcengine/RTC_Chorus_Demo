// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusSingerItemView.h"
#import "ChorusAvatarComponent.h"
#import "ChorusNetworkQualityView.h"
#import "ChorusRTCManager.h"

@interface ChorusSingerItemView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) ChorusAvatarComponent *avatarComponent;
@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) ChorusNetworkQualityView *networkQualityView;
@property (nonatomic, assign) BOOL isRight;
@property (nonatomic, strong) UIView *emptyContentView;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation ChorusSingerItemView

- (instancetype)initWithLocationRight:(BOOL)isRight; {
    if (self = [super init]) {
        self.isRight = isRight;
        [self setupViews];
        
        self.userModel = nil;
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.contentView];
    [self addSubview:self.emptyContentView];
    [self.contentView addSubview:self.animationView];
    [self.contentView addSubview:self.avatarComponent];
    [self.contentView addSubview:self.renderView];
    [self.contentView addSubview:self.networkQualityView];
    
    [self.emptyContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(80);
        make.center.equalTo(self);
    }];
    [self.avatarComponent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(70);
        make.center.equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.networkQualityView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.isRight) {
            make.right.equalTo(self).offset(-8);
        } else {
            make.left.equalTo(self).offset(8);
        }
        
        make.top.equalTo(self).offset(8);
        make.height.mas_equalTo(20);
    }];
}

- (void)setUserModel:(ChorusUserModel *)userModel {
    _userModel = userModel;
    if (userModel) {
        self.contentView.hidden = NO;
        self.emptyContentView.hidden = YES;
        self.avatarComponent.text = userModel.name;
        
        [self updateFirstVideoFrameRendered];
    }
    else {
        self.contentView.hidden = YES;
        self.emptyContentView.hidden = NO;
    }
}

- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status {
    [self.networkQualityView updateNetworkQualityStstus:status];
}

- (void)updateFirstVideoFrameRendered {

    UIView *streamView = [[ChorusRTCManager shareRtc] getStreamViewWithUserID:self.userModel.uid];
    if (streamView) {
        [self.renderView removeAllSubviews];
        [self.renderView addSubview:streamView];
        [streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.renderView);
        }];
    }
}

/// 独唱需要隐藏副唱位置“等待合唱者加入”文案
/// @param isHidden Hidden
- (void)hiddenEmptyLabel:(BOOL)isHidden {
    self.emptyLabel.hidden = isHidden;
}

/// 更新用户说话声音动画
/// @param volume 说话音量
- (void)updateUserAudioVolume:(NSInteger)volume {
    self.animationView.hidden = (volume < 26);
}

- (void)addWiggleAnimation:(UIView *)view {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.81), @(1.0), @(1.0)];
    animation.keyTimes = @[@(0), @(0.27), @(1.0)];
    
    CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation2.values = @[@(0), @(0.2), @(0.4), @(0.2)];
    animation2.keyTimes = @[@(0), @(0.27), @(0.27), @(1.0)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation,animation2];
    group.duration = 1.1;
    group.repeatCount = MAXFLOAT;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:group forKey:@"transformKey"];
}


#pragma mark - getter
- (UIView *)renderView {
    if (!_renderView) {
        _renderView = [[UIView alloc] init];
    }
    return _renderView;
}

- (ChorusAvatarComponent *)avatarComponent {
    if (!_avatarComponent) {
        _avatarComponent = [[ChorusAvatarComponent alloc] init];
        _avatarComponent.layer.cornerRadius = 24;
        _avatarComponent.layer.masksToBounds = YES;
        _avatarComponent.fontSize = 24;
    }
    return _avatarComponent;
}

- (ChorusNetworkQualityView *)networkQualityView {
    if (!_networkQualityView) {
        _networkQualityView = [[ChorusNetworkQualityView alloc] init];
        _networkQualityView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
        _networkQualityView.layer.cornerRadius = 10;
    }
    return _networkQualityView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIView *)animationView {
    if (!_animationView) {
        _animationView = [[UIView alloc] init];
        _animationView.backgroundColor = [UIColor colorFromRGBHexString:@"#F93D89"];
        _animationView.layer.cornerRadius =  40;
        _animationView.layer.masksToBounds = YES;
        [self addWiggleAnimation:_animationView];
    }
    return _animationView;
}

- (UIView *)emptyContentView {
    if (!_emptyContentView) {
        _emptyContentView = [[UIView alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chorus_singer_item_seat" bundleName:HomeBundleName]];
        
        
        [_emptyContentView addSubview:imageView];
        [_emptyContentView addSubview:self.emptyLabel];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_emptyContentView);
            make.left.right.equalTo(_emptyContentView);
            make.bottom.equalTo(_emptyContentView);
        }];
        [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyContentView);
            make.bottom.equalTo(_emptyContentView).offset(-20);
        }];
    }
    return _emptyContentView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.font = [UIFont systemFontOfSize:10];
        _emptyLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        _emptyLabel.text = veString(@"等待合唱者加入");
    }
    return _emptyLabel;
}


@end
