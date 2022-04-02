/****************************************************************************
 Copyright (c)  高手互娱网络科技
 
 文件名：AudioUtil.h
 
 作者：李中强
 
 修改时间：2018-06-25 11:00
 
 文件说明：1、录音及播放相关接口，支持大厅语音聊天和游戏中的语音聊天。
 
 ****************************************************************************/
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AmrFileCodec.h"

@interface AudioUtil : NSObject <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
	AVAudioRecorder * m_recorder;
    AVAudioPlayer * m_avPlayer;
}

//开始录音
+(int) startAudioRecord;

//结束录音
+(BOOL) stopAudioRecord;

//播放录音
+(int) playRecord:(NSString *)fileName;

//停止播放
+(void) stopPlayRecord;

//编码AMR
+(BOOL) encodeAMR:(NSString *)fileName;

@end
