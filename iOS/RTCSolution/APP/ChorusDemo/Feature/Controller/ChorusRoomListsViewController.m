// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusRoomListsViewController.h"
#import "ChorusCreateRoomViewController.h"
#import "ChorusRoomViewController.h"
#import "ChorusRoomTableView.h"
#import "ChorusHiFiveManager.h"
#import "ChorusPickSongManager.h"
#import "ChorusRTSManager.h"

@interface ChorusRoomListsViewController () <ChorusRoomTableViewDelegate>

@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) ChorusRoomTableView *roomTableView;
@property (nonatomic, copy) NSString *currentAppid;

@end

@implementation ChorusRoomListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor clearColor];
    
    [ChorusHiFiveManager registerHiFive];
    
    [self.view addSubview:self.roomTableView];
    [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
    }];
    
    [self.view addSubview:self.createButton];
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(171, 50));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(- 48 - [DeviceInforTool getVirtualHomeHeight]);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navTitle = veString(@"双人合唱");
    self.navRightImage = [UIImage imageNamed:@"edu_refresh" bundleName:HomeBundleName];
    
    [self loadDataWithGetLists];
}

- (void)rightButtonAction:(BaseButton *)sender {
    [super rightButtonAction:sender];
    
    [self loadDataWithGetLists];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - load data

- (void)loadDataWithGetLists {
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [ChorusRTSManager clearUser:^(RTSACKModel * _Nonnull model) {
        [ChorusRTSManager getActiveLiveRoomListWithBlock:^(NSArray<ChorusRoomModel *> * _Nonnull roomList, RTSACKModel * _Nonnull model) {
            [[ToastComponent shareToastComponent] dismiss];
            if (model.result) {
                wself.roomTableView.dataLists = roomList;
            } else {
                wself.roomTableView.dataLists = @[];
                [[ToastComponent shareToastComponent] showWithMessage:model.message];
            }
        }];
    }];
}

#pragma mark - ChorusRoomTableViewDelegate

- (void)ChorusRoomTableView:(ChorusRoomTableView *)ChorusRoomTableView didSelectRowAtIndexPath:(ChorusRoomModel *)model {
    ChorusRoomViewController *next = [[ChorusRoomViewController alloc]
                                         initWithRoomModel:model];
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - Touch Action

- (void)createButtonAction {
    ChorusCreateRoomViewController *next = [[ChorusCreateRoomViewController alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - getter

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [[UIButton alloc] init];
        _createButton.backgroundColor = [UIColor colorFromHexString:@"#4080FF"];
        [_createButton addTarget:self action:@selector(createButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _createButton.layer.cornerRadius = 25;
        _createButton.layer.masksToBounds = YES;
        
        UIImageView *iconImageView = [[UIImageView alloc] init];
        iconImageView.image = [UIImage imageNamed:@"voice_add" bundleName:HomeBundleName];
        [_createButton addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.equalTo(_createButton);
            make.left.mas_equalTo(40);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = veString(@"创建房间");
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [_createButton addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_createButton);
            make.left.equalTo(iconImageView.mas_right).offset(8);
        }];
    }
    return _createButton;
}

- (ChorusRoomTableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[ChorusRoomTableView alloc] init];
        _roomTableView.delegate = self;
    }
    return _roomTableView;
}

- (void)dealloc {
    [ChorusPickSongManager removeLocalMusicFile];
    
    [[ChorusRTCManager shareRtc] disconnect];
}


@end
