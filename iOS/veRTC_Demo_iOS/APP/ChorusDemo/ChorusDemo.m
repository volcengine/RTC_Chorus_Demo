//
//  ChorusDemo.m
//  ChorusDemo
//
//  Created by on 2022/5/9.
//

#import "ChorusDemo.h"
#import "JoinRTSParams.h"
#import "ChorusRTCManager.h"
#import <Core/NetworkReachabilityManager.h>
#import "ChorusRoomListsViewController.h"

@implementation ChorusDemo

- (void)pushDemoViewControllerBlock:(void (^)(BOOL result))block {
    [super pushDemoViewControllerBlock:block];
    
    JoinRTSInputModel *inputModel = [[JoinRTSInputModel alloc] init];
    inputModel.scenesName = @"owc";
    inputModel.loginToken = [LocalUserComponent userModel].loginToken;
    __weak __typeof(self) wself = self;
    [JoinRTSParams getJoinRTSParams:inputModel
                             block:^(JoinRTSParamsModel * _Nonnull model) {
        [wself joinRTS:model block:block];
    }];    
}

- (void)joinRTS:(JoinRTSParamsModel * _Nonnull)model
          block:(void (^)(BOOL result))block{
    if (!model) {
        [[ToastComponent shareToastComponent] showWithMessage:@"连接失败"];
        if (block) {
            block(NO);
        }
        return;
    }
    // Connect RTS
    [[ChorusRTCManager shareRtc] connect:model.appId
                                RTSToken:model.RTSToken
                               serverUrl:model.serverUrl
                               serverSig:model.serverSignature
                                     bid:model.bid
                                   block:^(BOOL result) {
        if (result) {
            ChorusRoomListsViewController *next = [[ChorusRoomListsViewController alloc] init];
            UIViewController *topVC = [DeviceInforTool topViewController];
            [topVC.navigationController pushViewController:next animated:YES];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:@"连接失败"];
        }
        if (block) {
            block(result);
        }
    }];
}

@end
