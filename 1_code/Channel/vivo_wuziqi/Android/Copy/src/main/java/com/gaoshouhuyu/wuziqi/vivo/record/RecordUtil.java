/****************************************************************************
Copyright (c)   高手互娱网络科技 

文件名：RecordUtil.java

作者：李中强

修改时间：2017-12-07 17:40

文件说明：录音工具类。

 ****************************************************************************/
package com.gaoshouhuyu.wuziqi.vivo.record;


import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;


import android.annotation.SuppressLint;
import android.media.MediaRecorder;
import android.util.Log;


public class RecordUtil {
	private final String TAG = "RecorderUtil";
	private static final int SAMPLE_RATE_IN_HZ = 8000;
	private MediaRecorder recorder = new MediaRecorder();
	private String mPath;
	private File directory;

	public RecordUtil(String path) {
		mPath = path;
	}

	@SuppressLint("InlinedApi") 
	public void start() throws IOException 
	{
		//if(RecordPermission.getRecordState() != RecordPermission.STATE_SUCCESS )
		//{
		//	throw new IOException("RecordPermission is not STATE_SUCCESS");
		//}
		
		String state = android.os.Environment.getExternalStorageState();
		if (!state.equals(android.os.Environment.MEDIA_MOUNTED)) {
			throw new IOException("SD Card is not mounted,It is  " + state
					+ ".");
		}
		File tmpFile = new File(mPath);
		if(tmpFile != null)
			tmpFile.delete();
		directory = new File(mPath).getParentFile();
		Log.v(TAG, directory.getPath());
		if (!directory.exists() && !directory.mkdirs()) {
			throw new IOException("Path to file could not be created");
		}
	
		recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
		recorder.setOutputFormat(MediaRecorder.OutputFormat.AMR_NB);
		recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
		recorder.setAudioSamplingRate(SAMPLE_RATE_IN_HZ);
		recorder.setOutputFile(mPath);
		recorder.prepare();
		recorder.start();
	}

	
	public byte[] upload(String str) {
		File file = new File(str);
		byte[] ret = null;
		try {
			if (!file.exists()) {
				Log.v(TAG, "file null");
				return null;
			}
			FileInputStream in = new FileInputStream(file);
			ByteArrayOutputStream out = new ByteArrayOutputStream(15360);
			byte[] b = new byte[15360];
			int n;
			while ((n = in.read(b)) != -1) {
				out.write(b, 0, n);
			}
			in.close();
			out.close();
			ret = out.toByteArray();
		} catch (IOException e) {
			// log.error("helper:get bytes from file process error!");
			Log.v(TAG, "upload IOException");
			e.printStackTrace();
		}
		return ret;
	}

	
	public void stop() throws IOException {
		recorder.stop();
		recorder.release();
	}

	public void reset() {
		recorder.release();
	}

	
	public double getAmplitude() {
		if (recorder != null) {
			return (recorder.getMaxAmplitude());
		}
		return 0;
	}
}
