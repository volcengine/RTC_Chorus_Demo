//
//  ChorusPickSongManager.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <Foundation/Foundation.h>
#import "ChorusSongModel.h"
#import "ChorusDownloadSongModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ChorusMusicFileType) {
    ChorusMusicFileTypeMP3 = 1 << 0,
    ChorusMusicFileTypeLRC = 1 << 1,
    ChorusMusicFileBoth = ChorusMusicFileTypeMP3 | ChorusMusicFileTypeLRC,
};

@interface ChorusPickSongManager : NSObject

- (instancetype)initWithRoomID:(NSString *)roomID;

@property (nonatomic, copy) void(^refreshModelBlock)(ChorusSongModel *model);

/// Pick song
/// @param model Song model
- (void)pickSong:(ChorusSongModel *)model;

/// Request download song model
/// @param songModel Song model
/// @param complete Callback
+ (void)requestDownSongModel:(ChorusSongModel *)songModel complete:(void(^)(ChorusDownloadSongModel *downloadSongModel))complete;

/// Get MP3 local file path, if file no exists, download
/// @param downloadSongModel Download song model
/// @param complete Callback
+ (void)getMP3FilePath:(ChorusDownloadSongModel *)downloadSongModel complete:(void(^)(NSString * _Nullable filePath))complete;

/// Get lrc local file path, if file no exists, download
/// @param downloadSongModel Download song model
/// @param complete Callback
+ (void)getLRCFilePath:(ChorusDownloadSongModel *)downloadSongModel complete:(void(^)(NSString * _Nullable filePath))complete;

/// Get MP3 file path
/// @param musicID MusicID
+ (NSString *)getMP3FilePath:(NSString *)musicID;

/// Get LRC file path
/// @param musicID MusicID
+ (NSString *)getLRCFilePath:(NSString *)musicID;

/// Remove MP3 lrc loacl file
+ (void)removeLocalMusicFile;


/// 获取MP3和LRC文件
/// @param type MP3 LRC or both
/// @param songModel 歌曲信息
/// @param complete 结果回调
+ (void)getMusicFileType:(ChorusMusicFileType)type songModel:(ChorusSongModel *)songModel complete:(void(^)(NSString *_Nullable mp3FilePath, NSString *_Nullable lrcFilePath))complete;

@end

NS_ASSUME_NONNULL_END
