//
//  ChorusNetworkQualityView.m
//  ChorusDemo
//
//  Created by on 2022/6/6.
//

#import "ChorusNetworkQualityView.h"

@interface ChorusNetworkQualityView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation ChorusNetworkQualityView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(15, 15));
            make.left.mas_equalTo(5);
            make.centerY.equalTo(self);
        }];

        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(4);
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-5);
        }];
        
        [self updateNetworkQualityStstus:ChorusNetworkQualityStatusGood];
    }
    return self;
}

- (void)updateNetworkQualityStstus:(ChorusNetworkQualityStatus)status {
    switch (status) {
        case ChorusNetworkQualityStatusGood:
        case ChorusNetworkQualityStatusNone:
            self.messageLabel.text = @"网络良好";
            self.iconImageView.image = [UIImage imageNamed:@"chorus_net_good" bundleName:HomeBundleName];
            break;
        case ChorusNetworkQualityStatusBad:
            self.messageLabel.text = @"网络卡顿";
            self.iconImageView.image = [UIImage imageNamed:@"chorus_net_bad" bundleName:HomeBundleName];
            break;
            
        default:
            break;
    }
}

#pragma mark - getter

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)messageLabel {
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    return _messageLabel;
}

@end
