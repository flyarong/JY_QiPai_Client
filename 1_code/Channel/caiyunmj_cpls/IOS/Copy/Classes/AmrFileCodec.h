/****************************************************************************
 Copyright (c)  高手互娱网络科技
 
 文件名：AmrFileCodec.h
 
 作者：李中强
 
 修改时间：2017-12-06 11:00
 
 文件说明：1、arm 文件编、解码
 
 ****************************************************************************/

#ifndef amrFileCodec_h
#define amrFileCodec_h
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "Amr/opencore-amrnb/interf_dec.h"
#include "Amr/opencore-amrnb/interf_enc.h"

#define AMR_MAGIC_NUMBER "#!AMR\n"

#define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160
#define MAX_AMR_FRAME_SIZE 32
#define AMR_FRAME_COUNT_PER_SECOND 50

typedef struct
{
	char chChunkID[4];
	int nChunkSize;
}XCHUNKHEADER;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
}WAVEFORMAT;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
	short nExSize;
}WAVEFORMATX;

typedef struct
{
	char chRiffID[4];
	int nRiffSize;
	char chRiffFormat[4];
}RIFFHEADER;

typedef struct
{
	char chFmtID[4];
	int nFmtSize;
	WAVEFORMAT wf;
}FMTBLOCK;


// WAVE音频采样频率是8khz 
// 音频样本单元数 = 8000*0.02 = 160 (由采样频率决定)
// 声道数 1 : 160
//        2 : 160*2 = 320
// bps决定样本(sample)大小
// bps = 8 --> 8位 unsigned char
//       16 --> 16位 unsigned short
BOOL EncodeWAVEToAMR(NSString *outputFile, NSData* input, int nChannels, int nBitsPerSample);
BOOL DecodeAmrDataToWAVE(NSMutableData* output, NSData* input);

#endif
