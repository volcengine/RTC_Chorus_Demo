//
//  KTVMusicReverberationView.m
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import "ChorusMusicReverberationView.h"
#import "ChorusMusicReverberationItemView.h"
#import "ChorusRTCManager.h"

@interface ChorusMusicReverberationView ()

@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, copy) NSArray *itemList;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation ChorusMusicReverberationView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.top.bottom.equalTo(self);
        }];
        
        CGFloat width = (50 * self.dataList.count) + ((self.dataList.count - 1) * 20);
        [self.scrollView addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(50);
        }];
        
        ChorusMusicReverberationItemView *defaultItemView = nil;
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.dataList.count; i++) {
            ChorusMusicReverberationItemView *itemView = [[ChorusMusicReverberationItemView alloc] init];
            [itemView addTarget:self action:@selector(itemViewAction:) forControlEvents:UIControlEventTouchUpInside];
            itemView.message = self.dataList[i];;
            [self.contentView addSubview:itemView];
            [list addObject:itemView];
            
            if ([itemView.message isEqualToString:veString(@"KTV")]) {
                defaultItemView = itemView;
            }
        }
        self.itemList = [list copy];
        
        if (defaultItemView) {
            [self itemViewAction:defaultItemView];
        }
        
        [list mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                       withFixedItemLength:50
                               leadSpacing:16
                               tailSpacing:16];
        [list mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(50);
        }];
    }
    return self;
}

- (void)itemViewAction:(ChorusMusicReverberationItemView *)itemView {
    ChorusMusicReverberationItemView *tempItemView = nil;
    for (ChorusMusicReverberationItemView *select in self.itemList) {
        select.isSelect = NO;
        if ([select.message isEqualToString:itemView.message]) {
            tempItemView = select;
        }
    }
    if (tempItemView) {
        tempItemView.isSelect = YES;
    }
    
    if ([itemView.message isEqualToString:veString(@"原声")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbOriginal];
    } else if ([itemView.message isEqualToString:veString(@"回声")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbEcho];
    } else if ([itemView.message isEqualToString:veString(@"演唱会")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbConcert];
    } else if ([itemView.message isEqualToString:veString(@"空灵")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbEthereal];
    } else if ([itemView.message isEqualToString:veString(@"KTV")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbKTV];
    } else if ([itemView.message isEqualToString:veString(@"录音棚")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbStudio];
    } else {
        
    }
}

#pragma mark - Publish Action

- (void)resetItemState {
    ChorusMusicReverberationItemView *defaultItemView = nil;
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        ChorusMusicReverberationItemView *itemView = self.contentView.subviews[i];
        if (itemView &&
            [itemView isKindOfClass:[ChorusMusicReverberationItemView class]]) {
            if ([itemView.message isEqualToString:veString(@"KTV")]) {
                defaultItemView = itemView;
                break;
            }
        }
    }
    if (defaultItemView) {
        [self itemViewAction:defaultItemView];
    }
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (NSArray *)dataList {
    if (!_dataList) {
        _dataList = @[veString(@"原声"),
                      veString(@"回声"),
                      veString(@"演唱会"),
                      veString(@"空灵"),
                      veString(@"KTV"),
                      veString(@"录音棚")];
    }
    return _dataList;
}

@end
