//
//  ChorusRoomBottomView.m
//  quickstart
//
//  Created by on 2021/3/23.
//  
//

#import "ChorusRoomBottomView.h"
#import "UIView+Fillet.h"
#import "ChorusRTSManager.h"
#import "ChorusDataManager.h"

@interface ChorusRoomBottomView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ChorusRoomItemButton *inputButton;
@property (nonatomic, strong) NSMutableArray *buttonLists;
@property (nonatomic, strong) ChorusRoomItemButton *pickSongButton;
@property (nonatomic, strong) UILabel *songCountLabel;

@end

@implementation ChorusRoomBottomView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.contentView];
        [self addSubview:self.inputButton];
        [self addSubview:self.pickSongButton];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self);
            make.width.mas_equalTo(0);
        }];
        
        [self.inputButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
            make.left.top.equalTo(self);
            make.right.equalTo(self.contentView.mas_left).offset(-18);
        }];
        
        [self.pickSongButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(82, 36));
        }];
        
        [self addSubviewAndConstraints];
    }
    return self;
}

- (void)inputButtonAction {
    if ([self.delegate respondsToSelector:@selector(chorusRoomBottomView:itemButton:didSelectStatus:)]) {
        [self.delegate chorusRoomBottomView:self itemButton:self.inputButton didSelectStatus:ChorusRoomBottomStatusInput];
    }
}

- (void)buttonAction:(ChorusRoomItemButton *)sender {
    if ([self.delegate respondsToSelector:@selector(chorusRoomBottomView:itemButton:didSelectStatus:)]) {
        [self.delegate chorusRoomBottomView:self itemButton:sender didSelectStatus:sender.tagNum];
    }
    
    if (sender.tagNum == ChorusRoomBottomStatusLocalMic) {
        BOOL isEnableMic = YES;
        if (sender.status == ButtonStatusActive) {
            sender.status = ButtonStatusNone;
            isEnableMic = YES;
        } else {
            sender.status = ButtonStatusActive;
            isEnableMic = NO;
        }
        [[ChorusRTCManager shareRtc] enableLocalAudio:isEnableMic];
    }
    
    if (sender.tagNum == ChorusRoomBottomStatusLocalCamera) {
        BOOL isEnableCamera = YES;
        if (sender.status == ButtonStatusActive) {
            sender.status = ButtonStatusNone;
            isEnableCamera = YES;
        } else {
            sender.status = ButtonStatusActive;
            isEnableCamera = NO;
        }
        
        [[ChorusRTCManager shareRtc] enableLocalVideo:isEnableCamera];
    }
}

- (void)addSubviewAndConstraints {
    NSInteger groupNum = 4;
    for (int i = 0; i < groupNum; i++) {
        ChorusRoomItemButton *button = [[ChorusRoomItemButton alloc] init];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonLists addObject:button];
        [self.contentView addSubview:button];
    }
}

#pragma mark - Publish Action

- (void)updateBottomLists {

    CGFloat itemWidth = 36;
    
    NSArray *status = [self getBottomLists];
    NSNumber *number = status.firstObject;
    if (number.integerValue == ChorusRoomBottomStatusInput) {
        self.inputButton.hidden = NO;
        NSMutableArray *mutableStatus = [status mutableCopy];
        [mutableStatus removeObjectAtIndex:0];
        status = [mutableStatus copy];
    } else {
        self.inputButton.hidden = YES;
    }
    
    NSMutableArray *lists = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.buttonLists.count; i++) {
        ChorusRoomItemButton *button = self.buttonLists[i];
        if (i < status.count) {
            NSNumber *number = status[i];
            ChorusRoomBottomStatus bottomStatus = number.integerValue;
            
            button.tagNum = bottomStatus;
            NSString *imageName = [self getImageWithStatus:bottomStatus];
            UIImage *image = [UIImage imageNamed:imageName bundleName:HomeBundleName];
            [button bingImage:image status:ButtonStatusNone];
            [button bingImage:[self getSelectImageWithStatus:bottomStatus] status:ButtonStatusActive];
            button.hidden = NO;
            button.status = ButtonStatusNone;
            [lists addObject:button];
            
            // 主唱 副唱 不允许关闭麦克风
            if (bottomStatus == ChorusRoomBottomStatusLocalMic &&
                ([ChorusDataManager shared].isLeadSinger ||
                 [ChorusDataManager shared].isSuccentor)) {
                button.enabled = NO;
                button.alpha = 0.5;
            }
            else {
                button.enabled = YES;
                button.alpha = 1.0;
            }
            
            if (bottomStatus == ChorusRoomBottomStatusLocalCamera) {
                if ([ChorusRTCManager shareRtc].isCameraOpen) {
                    button.status = ButtonStatusNone;
                }
                else {
                    button.status = ButtonStatusActive;
                }
            }
            
        } else {
            button.hidden = YES;
        }
    }
    
    if (lists.count > 1) {
        [lists mas_remakeConstraints:^(MASConstraintMaker *make) {
                
        }];
        [lists mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:itemWidth leadSpacing:0 tailSpacing:0];
        [lists mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(36);
        }];
    } else {
        ChorusRoomItemButton *button = lists.firstObject;
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(36);
            make.right.equalTo(self.contentView);
            make.width.mas_equalTo(itemWidth);
        }];
    }
    
    if (status.count == 0) {
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.right.equalTo(self).offset(-94);
        }];
    } else {
        CGFloat counentWidth = (itemWidth * status.count) + ((status.count - 1) * 12);
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(counentWidth);
            make.right.equalTo(self).offset(-94);
        }];
    }
}

- (void)updateBottomStatus:(ChorusRoomBottomStatus)status isActive:(BOOL)isActive {
    ChorusRoomItemButton *currentButton = nil;
    for (int i = 0; i < self.buttonLists.count; i++) {
        ChorusRoomItemButton *button = self.buttonLists[i];
        if (button.tagNum == status) {
            currentButton = button;
            break;
        }
    }
    if (currentButton) {
        currentButton.status = isActive ? ButtonStatusActive : ButtonStatusNone;
    }
}

- (void)updatePickedSongCount:(NSInteger)count {
    self.songCountLabel.hidden = (count == 0);
    if (count < 10) {
        _songCountLabel.font = [UIFont systemFontOfSize:12];
        _songCountLabel.text = @(count).stringValue;
    }
    else if (count < 100) {
        _songCountLabel.font = [UIFont systemFontOfSize:10];
        _songCountLabel.text = @(count).stringValue;
    }
    else {
        _songCountLabel.font = [UIFont systemFontOfSize:8];
        _songCountLabel.text = @"99+";
    }
}

#pragma mark - Private Action

- (NSArray *)getBottomLists {
    NSArray *bottomLists = nil;
    
    if ([ChorusDataManager shared].isLeadSinger || [ChorusDataManager shared].isSuccentor) {
        bottomLists = @[
            @(ChorusRoomBottomStatusInput),
            @(ChorusRoomBottomStatusLocalMic),
            @(ChorusRoomBottomStatusLocalCamera),
        ];
    }
    else if ([ChorusDataManager shared].isHost) {
        bottomLists = @[
            @(ChorusRoomBottomStatusInput),
            @(ChorusRoomBottomStatusLocalMic)
        ];
    }
    else {
        bottomLists = @[
            @(ChorusRoomBottomStatusInput)
        ];
    }
    return bottomLists;
}

- (NSString *)getImageWithStatus:(ChorusRoomBottomStatus)status {
    NSString *name = @"";
    switch (status) {
        case ChorusRoomBottomStatusLocalMic:
            name = @"Chorus_bottom_mic";
            break;
        case ChorusRoomBottomStatusLocalCamera:
            name = @"chorus_local_camera_on";
            break;
        default:
            break;
    }
    return name;
}

- (UIImage *)getSelectImageWithStatus:(ChorusRoomBottomStatus)status {
    NSString *name = @"";
    switch (status) {
        case ChorusRoomBottomStatusLocalMic:
            name = @"Chorus_localmic_s";
            break;
        case ChorusRoomBottomStatusLocalCamera:
            name = @"chorus_local_camera_off";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:name bundleName:HomeBundleName];
}

- (void)pickSongButtonClick {
    if ([self.delegate respondsToSelector:@selector(chorusRoomBottomView:itemButton:didSelectStatus:)]) {
        [self.delegate chorusRoomBottomView:self itemButton:self.pickSongButton didSelectStatus:ChorusRoomBottomStatusPickSong];
    }
}

#pragma mark - getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (NSMutableArray *)buttonLists {
    if (!_buttonLists) {
        _buttonLists = [[NSMutableArray alloc] init];
    }
    return _buttonLists;
}

- (ChorusRoomItemButton *)inputButton {
    if (!_inputButton) {
        _inputButton = [[ChorusRoomItemButton alloc] init];
        [_inputButton setBackgroundImage:[UIImage imageNamed:@"Chorus_input" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_inputButton addTarget:self action:@selector(inputButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _inputButton.hidden = YES;
    }
    return _inputButton;
}

- (ChorusRoomItemButton *)pickSongButton {
    if (!_pickSongButton) {
        _pickSongButton = [[ChorusRoomItemButton alloc] initWithFrame:CGRectMake(0, 0, 82, 36)];
        [_pickSongButton addTarget:self action:@selector(pickSongButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_pickSongButton setBackgroundImage:[UIImage imageNamed:@"chorus_pick_song_pick_button" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_pickSongButton setBackgroundImage:[UIImage imageNamed:@"chorus_pick_song_pick_button" bundleName:HomeBundleName] forState:UIControlStateHighlighted];
        
        [_pickSongButton addSubview:self.songCountLabel];
        [self.songCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_pickSongButton);
            make.centerY.equalTo(_pickSongButton.mas_top);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    return _pickSongButton;
}

- (UILabel *)songCountLabel {
    if (!_songCountLabel) {
        _songCountLabel = [[UILabel alloc] init];
        _songCountLabel.layer.cornerRadius = 10;
        _songCountLabel.layer.masksToBounds = YES;
        _songCountLabel.layer.borderWidth = 2;
        _songCountLabel.layer.borderColor = UIColor.whiteColor.CGColor;
        _songCountLabel.textAlignment = NSTextAlignmentCenter;
        _songCountLabel.font = [UIFont systemFontOfSize:12];
        _songCountLabel.textColor = UIColor.whiteColor;
        _songCountLabel.backgroundColor = [UIColor colorFromHexString:@"#EE77C6"];
        _songCountLabel.hidden = YES;
    }
    return _songCountLabel;
}

@end
