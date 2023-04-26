// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusIMComponent.h"
#import "ChorusIMView.h"

@interface ChorusIMComponent ()

@property (nonatomic, strong) ChorusIMView *ChorusIMView;

@end

@implementation ChorusIMComponent

- (instancetype)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        [superView addSubview:self.ChorusIMView];
        [self.ChorusIMView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(-101 - ([DeviceInforTool getVirtualHomeHeight]));
            make.top.mas_equalTo(435 + [DeviceInforTool getStatusBarHight]);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)addIM:(ChorusIMModel *)model {
    NSMutableArray *datas = [[NSMutableArray alloc] initWithArray:self.ChorusIMView.dataLists];
    [datas addObject:model];
    self.ChorusIMView.dataLists = [datas copy];
}

#pragma mark - getter

- (ChorusIMView *)ChorusIMView {
    if (!_ChorusIMView) {
        _ChorusIMView = [[ChorusIMView alloc] init];
    }
    return _ChorusIMView;
}

@end
