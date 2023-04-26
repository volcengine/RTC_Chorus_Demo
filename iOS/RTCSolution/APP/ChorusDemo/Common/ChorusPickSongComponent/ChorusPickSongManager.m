// 
// Copyright (c) 2023 Beijing Volcano Engine Technology Ltd.
// SPDX-License-Identifier: MIT
// 

#import "ChorusPickSongManager.h"
#import "ChorusDownloadSongComponent.h"
#import "ChorusRTSManager.h"
#import "ChorusHiFiveManager.h"


@interface ChorusPickSongManager ()

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray<ChorusSongModel*> *waitingDownloadArray;
@property (nonatomic, strong) ChorusSongModel *downloadingModel;

@end

@implementation ChorusPickSongManager

- (instancetype)initWithRoomID:(NSString *)roomID {
    if (self = [super init]) {
        self.roomID = roomID;
    }
    return self;
}

#pragma mark - queue download
- (void)pickSong:(ChorusSongModel *)model {
    if (self.isRequesting) {
        model.status = ChorusSongModelStatusWaitingDownload;
        [self.waitingDownloadArray addObject:model];
        if (self.refreshModelBlock) {
            self.refreshModelBlock(model);
        }
    }
    else {
        [self getMusicDownloadModel:model];
    }
}

- (void)getMusicDownloadModel:(ChorusSongModel *)model {
    self.isRequesting = YES;
    model.status = ChorusSongModelStatusDownloading;
    self.downloadingModel = model;
    
    if (self.refreshModelBlock) {
        self.refreshModelBlock(self.downloadingModel);
    }
    
    [ChorusHiFiveManager requestDownloadSongModel:model complete:^(ChorusDownloadSongModel * _Nonnull downloadSongModel, NSError * _Nonnull error) {
        
        if (downloadSongModel) {
            [self downloadLRC:downloadSongModel];
        }
        else {
            [[ToastComponent shareToastComponent] showWithMessage:error.localizedDescription];
            model.status = ChorusSongModelStatusNormal;
            
            if (self.refreshModelBlock) {
                self.refreshModelBlock(self.downloadingModel);
            }
            [self executeQueue];
        }
    }];
}

- (void)downloadLRC:(ChorusDownloadSongModel *)downloadModel {
    NSString *filePath = [ChorusPickSongManager getLRCFilePath:downloadModel.musicId];
    
    [ChorusDownloadSongComponent downloadWithURL:downloadModel.dynamicLyricUrl filePath:filePath progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } complete:^(NSError * _Nonnull error) {
        if (!error) {
            [self downloadMP3:downloadModel];
        }
        else {
            [[ToastComponent shareToastComponent] showWithMessage:error.localizedDescription];
            self.downloadingModel.status = ChorusSongModelStatusNormal;
            
            if (self.refreshModelBlock) {
                self.refreshModelBlock(self.downloadingModel);
            }
            [self executeQueue];
        }
    }];
}

- (void)downloadMP3:(ChorusDownloadSongModel *)downloadModel {
    
    NSString *filePath = [ChorusPickSongManager getMP3FilePath:downloadModel.musicId];
    
    [ChorusDownloadSongComponent downloadWithURL:downloadModel.mp3URLString filePath:filePath progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } complete:^(NSError * _Nonnull error) {
        if (!error) {
            self.downloadingModel.status = ChorusSongModelStatusDownloaded;
            self.downloadingModel.isPicked = YES;
            [ChorusRTSManager pickSong:self.downloadingModel
                                    roomID:self.roomID
                                     block:^(RTSACKModel * _Nonnull model) {
                if (!model.result) {
                    if (model.code == 540) {
                        [[ToastComponent shareToastComponent] showWithMessage:@"重复点歌"];
                    }
                    else {
                        [[ToastComponent shareToastComponent] showWithMessage:model.message];
                    }
                }
            }];
        }
        else {
            [[ToastComponent shareToastComponent] showWithMessage:error.localizedDescription];
            self.downloadingModel.status = ChorusSongModelStatusNormal;
        }
        
        if (self.refreshModelBlock) {
            self.refreshModelBlock(self.downloadingModel);
        }
        [self executeQueue];
    }];
}

- (void)executeQueue {
    if (self.waitingDownloadArray.count > 0) {
        ChorusSongModel *songModel = [self.waitingDownloadArray firstObject];
        [self.waitingDownloadArray removeObjectAtIndex:0];
        [self getMusicDownloadModel:songModel];
    }
    else {
        self.isRequesting = NO;
    }
}

#pragma mark - download

+ (void)requestDownSongModel:(ChorusSongModel *)songModel complete:(void(^)(ChorusDownloadSongModel *downloadSongModel))complete {
    [ChorusHiFiveManager requestDownloadSongModel:songModel complete:^(ChorusDownloadSongModel * _Nonnull downloadSongModel, NSError * _Nonnull error) {
        if (error) {
            [[ToastComponent shareToastComponent] showWithMessage:error.localizedDescription];
        }
        if (complete) {
            complete(downloadSongModel);
        }
    }];
}

+ (void)getMP3FilePath:(ChorusDownloadSongModel *)downloadSongModel complete:(void(^)(NSString * _Nullable filePath))complete {
    NSString *filePath = [ChorusPickSongManager getMP3FilePath:downloadSongModel.musicId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        !complete? :complete(filePath);
        return;
    }
    [ChorusDownloadSongComponent downloadWithURL:downloadSongModel.mp3URLString filePath:filePath progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } complete:^(NSError * _Nonnull error) {
        if (error) {
            !complete? :complete(nil);
        }
        else {
            !complete? :complete(filePath);
        }
    }];
    
}

+ (void)getLRCFilePath:(ChorusDownloadSongModel *)downloadSongModel complete:(void(^)(NSString * _Nullable filePath))complete; {
    NSString *filePath = [ChorusPickSongManager getLRCFilePath:downloadSongModel.musicId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        !complete? :complete(filePath);
        return;
    }
    [ChorusDownloadSongComponent downloadWithURL:downloadSongModel.dynamicLyricUrl filePath:filePath progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } complete:^(NSError * _Nonnull error) {
        if (error) {
            !complete? :complete(nil);
        }
        else {
            !complete? :complete(filePath);
        }
    }];
}

+ (void)getMusicFileType:(ChorusMusicFileType)type songModel:(ChorusSongModel *)songModel complete:(void(^)(NSString *_Nullable mp3FilePath, NSString *_Nullable lrcFilePath))complete {
    
    BOOL hasMP3File = NO;
    __block NSString *mp3FilePath = [ChorusPickSongManager getMP3FilePath:songModel.musicId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mp3FilePath]) {
        hasMP3File = YES;
    }
    
    BOOL hasLRCFile = NO;
    __block NSString *lrcFilePath = [ChorusPickSongManager getLRCFilePath:songModel.musicId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:lrcFilePath]) {
        hasLRCFile = YES;
    }
    if (((type & ChorusMusicFileTypeMP3) && hasMP3File) || ((type & ChorusMusicFileTypeLRC) && hasLRCFile)) {
        if (complete) {
            complete(mp3FilePath, lrcFilePath);
        }
        return;
    }
    [ChorusHiFiveManager requestDownloadSongModel:songModel complete:^(ChorusDownloadSongModel * _Nonnull downloadSongModel, NSError * _Nonnull error) {
        
        if ((type & ChorusMusicFileTypeMP3) && (type & ChorusMusicFileTypeLRC)) {
            [ChorusPickSongManager getMP3FilePath:downloadSongModel complete:^(NSString * _Nullable filePath) {
                mp3FilePath = filePath;
                [ChorusPickSongManager getLRCFilePath:downloadSongModel complete:^(NSString * _Nullable filePath) {
                    lrcFilePath = filePath;
                    if (complete) {
                        complete(mp3FilePath, lrcFilePath);
                    }
                }];
            }];
        }
        else if (type & ChorusMusicFileTypeMP3) {
            [ChorusPickSongManager getMP3FilePath:downloadSongModel complete:^(NSString * _Nullable filePath) {
                if (complete) {
                    complete(filePath, nil);
                }
            }];
        }
        else if (type & ChorusMusicFileTypeLRC) {
            [ChorusPickSongManager getLRCFilePath:downloadSongModel complete:^(NSString * _Nullable filePath) {
                if (complete) {
                    complete(nil, filePath);
                }
            }];
        }
    }];
}

+ (void)removeLocalMusicFile {
    NSString *baseFilePath = [self basePathString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator * enumerator = [fileManager enumeratorAtPath:baseFilePath];
    for (NSString *fileName in enumerator) {
        [fileManager removeItemAtPath:[baseFilePath stringByAppendingPathComponent:fileName] error:nil];
    }
}

#pragma mark - methods
+ (NSString *)getMP3FilePath:(NSString *)musicID {
    NSString *filePath = [[self basePathString] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", musicID, @"mp3"]];
    return filePath;
}

+ (NSString *)getLRCFilePath:(NSString *)musicID {
    NSString *filePath = [[self basePathString] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", musicID, @"lrc"]];
    return filePath;
}

+ (NSString *)basePathString {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *basePath = [cachePath stringByAppendingPathComponent:@"music"];
    
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:basePath isDirectory:&isDir];
    if (!(isDir && exists)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return basePath;
}

- (NSMutableArray<ChorusSongModel *> *)waitingDownloadArray {
    if (!_waitingDownloadArray) {
        _waitingDownloadArray = [NSMutableArray array];
    }
    return _waitingDownloadArray;
}

@end
