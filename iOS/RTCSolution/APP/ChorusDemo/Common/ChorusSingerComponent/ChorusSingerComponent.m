// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusSingerComponent.h"
#import "ChorusSingerItemView.h"
#import "ChorusDataManager.h"

@interface ChorusSingerComponent ()

@property (nonatomic, strong) ChorusSingerItemView *leadSingerView;
@property (nonatomic, strong) ChorusSingerItemView *succentorView;
@property (nonatomic, strong) UIView *gradientView;

@end

@implementation ChorusSingerComponent

- (instancetype)initWithSuperView:(UIView *)superView {
    if (self = [super init]) {
        [superView addSubview:self.backgroundView];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superView);
        }];
        
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.backgroundView addSubview:self.leadSingerView];
    [self.backgroundView addSubview:self.succentorView];
    [self.backgroundView addSubview:self.gradientView];
    
    [self.leadSingerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.backgroundView);
        make.right.equalTo(self.backgroundView.mas_centerX);
    }];
    [self.succentorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundView.mas_centerX);
        make.top.bottom.right.equalTo(self.backgroundView);
    }];
    [self.gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backgroundView);
        make.height.mas_equalTo(100);
    }];
}

- (void)updateSingerUIWithChorusStatus:(ChorusStatus)status {
    
    if (status == ChorusStatusPrepare || status == ChorusStatusSinging) {
        self.leadSingerView.userModel = [ChorusDataManager shared].leadSingerUserModel;
        self.succentorView.userModel = [ChorusDataManager shared].succentorUserModel;
    } else {
        self.leadSingerView.userModel = nil;
        self.succentorView.userModel = nil;
    }

    [self.succentorView hiddenEmptyLabel:status != ChorusStatusPrepare];
}

- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status uid:(NSString *)uid {
    if ([[ChorusDataManager shared].leadSingerUserModel.uid isEqualToString:uid]) {
        [self.leadSingerView updateNetworkQuality:status];
    }
    else if ([[ChorusDataManager shared].succentorUserModel.uid isEqualToString:uid]) {
        [self.succentorView updateNetworkQuality:status];
    }
}

- (void)updateFirstVideoFrameRenderedWithUid:(NSString *)uid {
    if ([[ChorusDataManager shared].leadSingerUserModel.uid isEqualToString:uid]) {
        [self.leadSingerView updateFirstVideoFrameRendered];
    }
    else if ([[ChorusDataManager shared].succentorUserModel.uid isEqualToString:uid]) {
        [self.succentorView updateFirstVideoFrameRendered];
    }
}

/// 更新用户说话声音动画
/// @param dict 用户ID ： 说话音量
- (void)updateUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *)dict {
    NSString *leadSingerUserID = [ChorusDataManager shared].leadSingerUserModel.uid;
    if (leadSingerUserID && dict[leadSingerUserID]) {
        [self.leadSingerView updateUserAudioVolume:[dict[leadSingerUserID] integerValue]];
    }
    NSString *succentorUserID = [ChorusDataManager shared].succentorUserModel.uid;
    if (succentorUserID && dict[succentorUserID]) {
        [self.succentorView updateUserAudioVolume:[dict[succentorUserID] integerValue]];
    }
}

#pragma mark - getter
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
    }
    return _backgroundView;
}

- (ChorusSingerItemView *)leadSingerView {
    if (!_leadSingerView) {
        _leadSingerView = [[ChorusSingerItemView alloc] initWithLocationRight:NO];
        [_leadSingerView hiddenEmptyLabel:YES];
    }
    return _leadSingerView;
}

- (ChorusSingerItemView *)succentorView {
    if (!_succentorView) {
        _succentorView = [[ChorusSingerItemView alloc] initWithLocationRight:YES];
    }
    return _succentorView;
}

- (UIView *)gradientView {
    if (!_gradientView) {
        _gradientView = [[UIView alloc] init];
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.colors = @[
            (id)[[UIColor colorFromHexString:@"#020422"] colorWithAlphaComponent:0].CGColor,
            (id)[[UIColor colorFromHexString:@"#020422"] colorWithAlphaComponent:0.8].CGColor,
        ];
        [_gradientView.layer addSublayer:gradientLayer];
    }
    return _gradientView;
}

@end
