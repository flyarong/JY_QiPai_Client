//
//  ConvertAudioFile.m
//  Expert
//
//  Created by xuxiwen on 2017/3/21.
//  Copyright © 2017年 xuxiwen. All rights reserved.
//

#import "ConvertAudioFile.h"

@interface ConvertAudioFile ()
@property (nonatomic, assign) BOOL stopRecord;
@end

@implementation ConvertAudioFile

/**
 get instance obj
 
 @return ConvertAudioFile instance
 */
+ (instancetype)sharedInstance {
    static ConvertAudioFile *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConvertAudioFile alloc] init];
    });
    return instance;
}

/**
 send end record signal
 */
- (void)sendEndRecord {
    self.stopRecord = YES;
}



#pragma mark - ----------------------------------

// 这是录完再转码的方法, 如果录音时间比较长的话,会要等待几秒...
// Use this FUNC convent to mp3 after record

+ (void)conventToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback
{
}

@end
