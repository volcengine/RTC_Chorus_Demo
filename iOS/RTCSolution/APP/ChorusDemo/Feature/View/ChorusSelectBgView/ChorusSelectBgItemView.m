// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusSelectBgItemView.h"

@interface ChorusSelectBgItemView ()

@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, assign) NSInteger index;

@end

@implementation ChorusSelectBgItemView

- (instancetype)initWithIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        _index = index;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2;
        
        [self addSubview:self.bgImageView];
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.selectImageView];
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.bgImageView.image = [UIImage imageNamed:[self getBackgroundSmallImageName] bundleName:HomeBundleName];
        self.isSelected = NO;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    if (isSelected) {
        self.selectImageView.hidden = NO;
        
    } else {
        self.selectImageView.hidden = YES;
    }
}

#pragma mark - Publish Action

- (NSString *)getBackgroundImageName {
    return [self getBackgroundImageNames][_index];
}

- (NSString *)getBackgroundSmallImageName {
    return [self getSmallBackgroundImageNames][_index];
}

#pragma mark - Private Action

- (NSArray *)getBackgroundImageNames {
    return @[@"chorus_background_0.jpg",
             @"chorus_background_1.jpg",
             @"chorus_background_2.jpg"];
}

- (NSArray *)getSmallBackgroundImageNames {
    return @[@"Chorus_background_small_0",
             @"Chorus_background_small_1",
             @"Chorus_background_small_2"];
}

#pragma mark - Getter

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
    }
    return _bgImageView;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.image = [UIImage imageNamed:@"Chorus_bg_icon" bundleName:HomeBundleName];
        _selectImageView.hidden = YES;
    }
    return _selectImageView;
}

@end
