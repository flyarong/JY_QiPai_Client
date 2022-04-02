package com.jingyu.rrddz;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.util.Log;

import com.jingyu.rrddz.record.RecordUtil;
import com.unity3d.player.UnityPlayer;

public class Mic {

	private static RecordUtil s_RecordUtil;

	private static final int RECORD_ING = 1; // 正在录音
	private static final int RECORD_ED = 2; // 完成录音

	private static final int PLAY_START =0;	//开始播放
	private static final int PLAY_END =1;	//播放完成
	private static final int PLAY_ERR =2;	//播放错误
	private static final int PLAY_TIME_COMPILE =3;	//播放时间获取完成

	private static int s_Record_State = 0; // 录音的状态
	private static long s_Record_Time = 0;// 录音的时间
	private static boolean s_PlayState = false; // 播放状态

	private static String s_RecordPath = "";// 本地录音的存储名称
	private static String s_ReceivePath = "";// 播放服务器录音的存储名称

	private static MediaPlayer s_mediaPlayer = null;

	/**
	 *  开始录音
	 */
	public static boolean startAudioRecord(String fileName) {
		if (s_Record_State == RECORD_ING)
			return false;

		s_RecordPath =fileName;

		// 实例化录音工具类
		s_RecordUtil = new RecordUtil(s_RecordPath);
		try {
			// 开始录音
			s_RecordUtil.start();
		} catch (IOException e) {
			e.printStackTrace();
			s_RecordUtil.reset();
			return false;
		}

		// 修改录音状态
		s_Record_State = RECORD_ING;
		s_Record_Time = System.currentTimeMillis();
		return true;
	}

	/**
	 * 结束录音（返回值是否录音成功）
	 */
	public static boolean stopAudioRecord() {
		if (s_Record_State != RECORD_ING)
			return false;

		s_Record_Time = System.currentTimeMillis() - s_Record_Time;
		// 修改录音状态
		s_Record_State = RECORD_ED;
		try {
			// 停止录音
			s_RecordUtil.stop();
		} catch (IOException e) {
			e.printStackTrace();
			s_RecordUtil.reset();
			return false;
		}

		return true;
	}

	//播放指定文件
	public static boolean playAudio(String fileName)
	{
		try
		{
			String strFileName = fileName;
			final File tempMp3 = new File(strFileName);

			stopPlayAudio();

			FileInputStream fis = new FileInputStream(tempMp3);
			if(s_mediaPlayer == null)
				s_mediaPlayer = new MediaPlayer();
			s_mediaPlayer.setDataSource(fis.getFD());
			s_mediaPlayer.prepare();
			s_mediaPlayer.start();

			s_mediaPlayer.setOnCompletionListener(new OnCompletionListener() {
				// 播放结束后调用
				public void onCompletion(MediaPlayer mp) {
					// 播放完毕
					s_mediaPlayer.release();
					s_mediaPlayer = null;
					UnityPlayer.UnitySendMessage("SDK_callback", "OnPlayRecordFinish", strFileName);
				}
			});
		} catch (IOException e) {
			e.printStackTrace();

			return false;
		}

		return true;
	}

	public static void stopPlayAudio() {
		if(s_mediaPlayer == null)
			return;

		try {
			if (s_mediaPlayer.isPlaying()) {
				s_mediaPlayer.stop();
				s_mediaPlayer.release();
				s_mediaPlayer = null;
			}
		} catch (IllegalStateException e) {
			s_mediaPlayer = null;
		}
	}

	public static String getRecordFile() { return s_RecordPath; }
	/**
	 * 播放是否完成
	 */
	public static boolean getPlayState() {
		return s_PlayState;
	}

}
