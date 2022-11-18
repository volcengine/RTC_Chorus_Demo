//
//  ChorusStaticView.m
//  veRTC_Demo
//
//  Created by on 2021/11/29.
//  
//

#import "ChorusStaticView.h"
#import "ChorusPeopleNumView.h"
#import "ChorusRoomModel.h"
#import "ChorusAvatarComponent.h"

@interface ChorusStaticView ()

@property (nonatomic, strong) UIImageView *bgImageImageView;
@property (nonatomic, strong) UILabel *roomTitleLabel;
@property (nonatomic, strong) ChorusPeopleNumView *peopleNumView;
@property (nonatomic, strong) UIView *avatarBackgroundView;
@property (nonatomic, strong) UILabel *roomIDLabel;
@property (nonatomic, strong) ChorusAvatarComponent *avatarView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation ChorusStaticView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.bgImageImageView];
        [self.bgImageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self setupAvatarBackgroundView];
        
        [self addSubview:self.closeButton];
        [self addSubview:self.peopleNumView];
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarBackgroundView);
            make.right.equalTo(self).offset(-15);
        }];
        [self.peopleNumView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(28);
            make.right.equalTo(self.closeButton.mas_left).offset(-16);
            make.centerY.equalTo(self.closeButton);
        }];
    }
    return self;
}

// 主播信息
- (void)setupAvatarBackgroundView {
    [self addSubview:self.avatarBackgroundView];
    [self.avatarBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.equalTo(self).offset([DeviceInforTool getStatusBarHight] + 8);
        make.height.mas_equalTo(36);
    }];
    
    [self.avatarBackgroundView addSubview:self.avatarView];
    [self.avatarBackgroundView addSubview:self.roomTitleLabel];
    [self.avatarBackgroundView addSubview:self.roomIDLabel];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self.avatarBackgroundView);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [self.roomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(9);
        make.top.equalTo(self.avatarBackgroundView).offset(5);
        make.right.lessThanOrEqualTo(self.avatarBackgroundView).offset(-20);
        make.width.mas_lessThanOrEqualTo(200);
    }];
    [self.roomIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(9);
        make.top.equalTo(self.roomTitleLabel.mas_bottom);
        make.height.mas_equalTo(12);
        make.right.lessThanOrEqualTo(self.avatarBackgroundView).offset(-20);
    }];
}

#pragma mark - Publish Action

- (void)setRoomModel:(ChorusRoomModel *)roomModel {
    _roomModel = roomModel;
    
    self.roomTitleLabel.text = roomModel.roomName;
    self.avatarView.text = roomModel.hostName;
    self.roomIDLabel.text = [NSString stringWithFormat:@"ID:%@", roomModel.roomID];
    // background image
    NSString *bgImageName = roomModel.extDic[@"background_image_name"];
    self.bgImageImageView.image = [UIImage imageNamed:bgImageName];
    // The number of the audience
    // 观众人数
    [self.peopleNumView updateTitleLabel:roomModel.audienceCount];
}

- (void)updatePeopleNum:(NSInteger)count {
    [self.peopleNumView updateTitleLabel:count];
}

- (void)closeButtonClick {
    if (self.closeButtonDidClickBlock) {
        self.closeButtonDidClickBlock();
    }
}

#pragma mark - Getter

- (UIImageView *)bgImageImageView {
    if (!_bgImageImageView) {
        _bgImageImageView = [[UIImageView alloc] init];
        _bgImageImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageImageView.clipsToBounds = YES;
    }
    return _bgImageImageView;
}

- (UILabel *)roomTitleLabel {
    if (!_roomTitleLabel) {
        _roomTitleLabel = [[UILabel alloc] init];
        _roomTitleLabel.textColor = [UIColor whiteColor];
        _roomTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _roomTitleLabel;
}

- (ChorusPeopleNumView *)peopleNumView {
    if (!_peopleNumView) {
        _peopleNumView = [[ChorusPeopleNumView alloc] init];
        _peopleNumView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.2];
        _peopleNumView.layer.cornerRadius = 14;
        _peopleNumView.layer.masksToBounds = YES;
    }
    return _peopleNumView;
}

- (ChorusAvatarComponent *)avatarView {
    if (!_avatarView) {
        _avatarView = [[ChorusAvatarComponent alloc] init];
        _avatarView.layer.cornerRadius = 17;
        _avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
        _avatarView.layer.borderWidth = 0.5;
    }
    return _avatarView;
}

- (UIView *)avatarBackgroundView {
    if (!_avatarBackgroundView) {
        _avatarBackgroundView = [[UIView alloc] init];
        _avatarBackgroundView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
        _avatarBackgroundView.layer.cornerRadius = 18;
    }
    return _avatarBackgroundView;
}

- (UILabel *)roomIDLabel {
    if (!_roomIDLabel) {
        _roomIDLabel = [[UILabel alloc] init];
        _roomIDLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.6];
        _roomIDLabel.font = [UIFont systemFontOfSize:8];
    }
    return _roomIDLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"chorus_room_close" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
