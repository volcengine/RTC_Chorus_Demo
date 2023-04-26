// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusHiFiveManager.h"
#import <HFOpenApi/HFOpenApi.h>
#import "ChorusDownloadSongModel.h"

@implementation ChorusHiFiveManager

#pragma mark - HiFive
+ (void)registerHiFive {
    
    NSString *userID = [LocalUserComponent userModel].uid;
    NSString *appID = HiFiveAppID;
    NSString *serverCode = HiFiveServerCode;
    [[HFOpenApiManager shared] registerAppWithAppId:appID serverCode:serverCode clientId:userID version:@"V4.1.2" success:^(id  _Nullable response) {
        
    } fail:^(NSError * _Nullable error) {
        
    }];
}

+ (void)requestHiFiveSongListComplete:(void (^)(NSArray<ChorusSongModel *> * _Nullable, NSString * _Nullable))complete {

    [[HFOpenApiManager shared] channelSheetWithGroupId:HiFiveGroupID language:@"0" recoNum:@"5" page:@"1" pageSize:@"100" success:^(id  _Nullable response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSArray *list = response[@"record"];
            NSDictionary *dict = list.firstObject;
            NSString *sheetID = [dict[@"sheetId"] description];
            [self requestHiFiveSongList:sheetID complete:complete];
        } else {
            if (complete) {
                complete(nil, @"data formate error");
            }
        }
        
    } fail:^(NSError * _Nullable error) {
        if (complete) {
            complete(nil, error.description);
        }
    }];
}

+ (void)requestHiFiveSongList:(NSString *)sheetID complete:(void (^)(NSArray<ChorusSongModel *> * _Nullable, NSString * _Nullable))complete {
    //sheetID 歌单Id,
    //language 标签、歌单名、歌名语言版本 0-中文,1-英文
    //pageSize 每页显示条数，默认10 1～100
    //page 当前页 大于0的整数
    //success 请求成功回调函数
    //fail 请求失败回调函数
    [[HFOpenApiManager shared] sheetMusicWithSheetId:sheetID language:@"0" page:@"1" pageSize:@"100" success:^(id  _Nullable response) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSArray *list = response[@"record"];
            NSArray *listModel = [NSArray yy_modelArrayWithClass:[ChorusSongModel class] json:list];
            if (complete) {
                complete(listModel, nil);
            }
        } else {
            if (complete) {
                complete(nil, @"data formate error");
            }
        }
        
    } fail:^(NSError * _Nullable error) {
        if (complete) {
            complete(nil, error.description);
        }
    }];
}

+ (void)requestDownloadSongModel:(ChorusSongModel *)songModel complete:(void(^)(ChorusDownloadSongModel *downloadSongModel, NSError *error))complete {
    
    [[HFOpenApiManager shared] kHQListenWithMusicId:songModel.musicId audioFormat:@"mp3" audioRate:@"320" success:^(id  _Nullable response) {
        
        ChorusDownloadSongModel *downloadModel = [ChorusDownloadSongModel yy_modelWithJSON:response];
        !complete? :complete(downloadModel, nil);
        
    } fail:^(NSError * _Nullable error) {
        !complete? :complete(nil, error);
    }];
}

@end
