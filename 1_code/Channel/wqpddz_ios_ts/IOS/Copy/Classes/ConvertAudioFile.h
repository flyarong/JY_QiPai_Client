//
//  ConvertAudioFile.h
//  Expert
//
//  Created by xuxiwen on 2017/3/21.
//  Copyright © 2017年 xuxiwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvertAudioFile : NSObject


/**
 get instance obj

 @return ConvertAudioFile instance
 */
+ (instancetype)sharedInstance;

/**
 send end record signal
 */
- (void)sendEndRecord;



// Use this FUNC convent to mp3 after record
+ (void)conventToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback;

@end
