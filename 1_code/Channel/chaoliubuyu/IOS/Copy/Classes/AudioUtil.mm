/****************************************************************************
 Copyright (c)  高手互娱网络科技
 
 文件名：AudioUtil.m
 
 作者：李中强
 
 修改时间：2018-06-25 11:00
 
 文件说明：1、录音及播放相关接口
 
 ****************************************************************************/
#import "AudioUtil.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AmrFileCodec.h"

NSString *gPlayAmrRecord = @"";

static AudioUtil* s_RecordAudio =nil;


@interface AudioUtil ()

@property (nonatomic,strong) NSURL * m_recordedTmpFile;

- (int) startAudioRecord;
- (BOOL) stopAudioRecord;
- (int) playRecord:(NSString *)fileName;
- (void) stopPlayRecord;

- (BOOL) encodeAMR:(NSString *)fileName;
- (BOOL)decodeAmrData:(NSMutableData*)output input:(NSData*)input;

+(AudioUtil*) getInstance;

@end

@implementation AudioUtil

+ (AudioUtil*) getInstance
{
    if (!s_RecordAudio)
    {
        s_RecordAudio = [[AudioUtil alloc]init];
    }
    
    return s_RecordAudio;
}

//开始
+(int) startAudioRecord
{
    return [[AudioUtil getInstance] startAudioRecord];
}

//结束录音
+(BOOL) stopAudioRecord
{
    return [[AudioUtil getInstance] stopAudioRecord];
}

+(int) playRecord:(NSString *)fileName
{
	return [[AudioUtil getInstance] playRecord:fileName];
}

//停止播放
+(void) stopPlayRecord
{
    [[AudioUtil getInstance] stopPlayRecord];
}

+(BOOL) encodeAMR:(NSString *)fileName
{
    NSLog(@"It's encode: %@", fileName);
    return [[AudioUtil getInstance] encodeAMR:fileName];
}

//传递回调接口
-(int) startAudioRecord
{
    if(m_recorder != nil && [m_recorder isRecording]) {
        NSLog(@"It's recording now ...");
        return 0;
    }
    
    NSError *error;
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                   [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                   [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                   nil];
    
    if(self.m_recordedTmpFile == nil) {
        NSString *fileName = @"record";
        NSString *cafFile = [NSString stringWithFormat:@"%@.caf", fileName];
        self.m_recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:cafFile]];
    }
    
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error: &error];
    if(audioSession == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return -1;
    } else
        [audioSession setActive:YES error:nil];
    
    if(m_recorder == nil) {
        //Setup the recorder to use this file and record to it.
        m_recorder = [[ AVAudioRecorder alloc] initWithURL:self.m_recordedTmpFile settings:recordSetting error:&error];
    
        [m_recorder setDelegate:self];
        //We call this to start the recording process and initialize
        //the subsstems so that when we actually say "record" it starts right away.
        [m_recorder prepareToRecord];
    }
    
    [m_recorder record];
    
    return 1;
}

- (BOOL) stopAudioRecord {
    if(m_recorder == nil)
        return false;
    if(![m_recorder isRecording])
        return false;
    
    [m_recorder stop];

    NSError *error;
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error: &error];
    [audioSession setActive:YES error:nil];
    
    return true;
}

- (int) playRecord:(NSString *)fileName
{
	NSURL *fileURL = [NSURL fileURLWithPath:fileName];
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    if(data == nil) {
		NSLog(@"playRecord failed: load data failed: %@", fileName);
		return -1;
	}

    [self stopPlayRecord];
 
    NSMutableData *output = [[NSMutableData alloc]init];
    if(![self decodeAmrData:output input:data]) {
		NSLog(@"playRecord failed: decodeAmrData failed: %@", fileName);
        return -1;
	}
    
    NSError *error;
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error: &error];
    [audioSession setActive:YES error:nil];

    gPlayAmrRecord = fileName;
    
    if(m_avPlayer == nil)
        m_avPlayer = [AVAudioPlayer alloc];
    m_avPlayer = [m_avPlayer initWithData:output error:&error];
    m_avPlayer.delegate = self;
    [m_avPlayer prepareToPlay];
    [m_avPlayer setVolume:1.0];
    [m_avPlayer play];
    
    return 1;
}

//停止播放
- (void) stopPlayRecord
{
    if(m_avPlayer == nil)
        return;
	
	if([m_avPlayer isPlaying])
		[m_avPlayer stop];
    
    //m_avPlayer = nil;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    //[self updateStatus:1 withChairID:m_nChairID];
    UnitySendMessage("SDK_callback", "OnPlayRecordFinish", [gPlayAmrRecord cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    //[self updateStatus:2 withChairID:m_nChairID];
}

- (BOOL) encodeAMR:(NSString *)fileName
{
	NSLog(@"encodeAMR file: %@", self.m_recordedTmpFile);
	
    //获取文件数据
    NSData*data = [NSData dataWithContentsOfURL:self.m_recordedTmpFile];
    if (data == nil) {
		NSLog(@"encodeAMR load data failed: %@", self.m_recordedTmpFile);
    	return false;
	}

    return EncodeWAVEToAMR(fileName, data, 1, 16);
}

- (BOOL)decodeAmrData:(NSMutableData*)output input:(NSData*)input
{
    return DecodeAmrDataToWAVE(output, input);
}

@end
