//
//  ChorusPickSongComponent.m
//  veRTC_Demo
//
//  Created by on 2022/1/18.
//  
//

#import "ChorusPickSongComponent.h"
#import "ChorusPickSongTopView.h"
#import "ChorusPickSongListView.h"
#import "ChorusPickSongManager.h"
#import "ChorusHiFiveManager.h"
#import "ChorusRTSManager.h"

@interface ChorusPickSongComponent ()

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, strong) UIView *pickSongView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ChorusPickSongTopView *topView;
@property (nonatomic, strong) ChorusPickSongListView *onlineListView;
@property (nonatomic, strong) ChorusPickSongListView *pickedListView;
@property (nonatomic, strong) ChorusPickSongManager *pickSongManager;

@end

@implementation ChorusPickSongComponent

- (instancetype)initWithSuperView:(UIView *)superView roomID:(nonnull NSString *)roomID {
    if (self = [super init]) {
        self.superView = superView;
        self.roomID = roomID;
        
        [self setupView];
        
        [self requestHiFiveSongList];
        [self requestPickedSongList];
    }
    return self;
}

- (void)setupView {
    [self.pickSongView addSubview:self.backView];
    [self.pickSongView addSubview:self.contentView];
    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.onlineListView];
    [self.contentView addSubview:self.pickedListView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
    }];
    [self.onlineListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.top.equalTo(self.topView.mas_bottom);
    }];
    [self.pickedListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.onlineListView);
    }];
}

#pragma mark - HTTP
- (void)requestHiFiveSongList {
    __weak typeof(self) weakSelf = self;
    [ChorusHiFiveManager requestHiFiveSongListComplete:^(NSArray<ChorusSongModel *> * _Nullable list, NSString * _Nullable errorMessage) {

        if (errorMessage) {
            [[ToastComponent shareToastComponent] showWithMessage:errorMessage];
        } else {
            weakSelf.onlineListView.dataArray = list;
            [weakSelf updateUI];
        }
        
    }];
}

- (void)requestPickedSongList {
    __weak typeof(self) weakSelf = self;
    [ChorusRTSManager requestPickedSongList:self.roomID block:^(RTMACKModel * _Nonnull model, NSArray<ChorusSongModel *> * _Nonnull list) {
        
        weakSelf.pickedListView.dataArray = list;
        [weakSelf syncSongListStstus];
        
        if ([weakSelf.delegate respondsToSelector:@selector(ChorusPickSongComponent:pickedSongCountChanged:)]) {
            [weakSelf.delegate ChorusPickSongComponent:weakSelf pickedSongCountChanged:list.count];
        }
        [weakSelf updateUI];
    }];
}

#pragma mark - methods
- (void)show {
    [self.superView addSubview:self.pickSongView];
    [self updateUI];
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.bottom = SCREEN_HEIGHT;
    }];
}

- (void)dismissView {
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.top = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        [self.pickSongView removeFromSuperview];
    }];
}

- (void)changedSongListView:(NSInteger)index {
    if (index == 0) {
        self.onlineListView.hidden = NO;
        self.pickedListView.hidden = YES;
    }
    else {
        self.onlineListView.hidden = YES;
        self.pickedListView.hidden = NO;
    }
    
    [self updateUI];
}

- (void)updateUI {
    if (self.pickSongView.superview) {
        
        [self.topView updatePickedSongCount:self.pickedListView.dataArray.count];
        
        if (self.onlineListView.isHidden) {
            [self.pickedListView refreshView];
        }
        else {
            [self.onlineListView refreshView];
        }
    }
}

- (void)refreshDownloadStstus:(ChorusSongModel *)model {

    [self updateUI];
}

- (void)syncSongListStstus {
    for (ChorusSongModel *model in self.onlineListView.dataArray) {
        model.isPicked = NO;
        for (ChorusSongModel *pickedModel in self.pickedListView.dataArray) {
            if ([pickedModel.pickedUserID isEqualToString:[LocalUserComponent userModel].uid] &&
                [pickedModel.musicId isEqualToString:model.musicId]) {
                model.isPicked = YES;
            }
        }
    }
}

- (void)updatePickedSongList {
    [self requestPickedSongList];
}

#pragma mark - getter

- (UIView *)pickSongView {
    if (!_pickSongView) {
        _pickSongView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    return _pickSongView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)]];
    }
    return _backView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 360 + 48)];
        _contentView.backgroundColor = [[UIColor colorFromHexString:@"#0E0825F2"] colorWithAlphaComponent:0.95];
    }
    return _contentView;
}

- (ChorusPickSongTopView *)topView {
    if (!_topView) {
        _topView = [[ChorusPickSongTopView alloc] init];
        __weak typeof(self) weakSelf = self;
        _topView.selectedChangedBlock = ^(NSInteger index) {
            [weakSelf changedSongListView:index];
        };
    }
    return _topView;
}

- (ChorusPickSongListView *)onlineListView {
    if (!_onlineListView) {
        _onlineListView = [[ChorusPickSongListView alloc] initWithType:ChorusSongListViewTypeOnline];
        __weak typeof(self) weakSelf = self;
        _onlineListView.pickSongBlock = ^(ChorusSongModel * _Nonnull songModel) {
            [weakSelf.pickSongManager pickSong:songModel];
        };
    }
    return _onlineListView;
}

- (ChorusPickSongListView *)pickedListView {
    if (!_pickedListView) {
        _pickedListView = [[ChorusPickSongListView alloc] initWithType:ChorusSongListViewTypePicked];
        _pickedListView.hidden = YES;
    }
    return _pickedListView;
}

- (ChorusPickSongManager *)pickSongManager {
    if (!_pickSongManager) {
        _pickSongManager = [[ChorusPickSongManager alloc] initWithRoomID:self.roomID];
        __weak typeof(self) weakSelf = self;
        _pickSongManager.refreshModelBlock = ^(ChorusSongModel * _Nonnull model) {
            [weakSelf refreshDownloadStstus:model];
        };
    }
    return _pickSongManager;
}

@end
