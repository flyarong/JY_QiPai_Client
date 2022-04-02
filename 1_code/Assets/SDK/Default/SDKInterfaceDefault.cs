using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace LuaFramework {
    public class SDKInterfaceDefault : SDKInterface {
		public override void Init (string json_data) {
		}
		public override void Login (string json_data) {
		}
		public override void LoginOut (string json_data) {
		}
		public override void Relogin (string json_data) {
		}
		public override void Pay (string json_data) {
		}
		public override void PostPay(string json_data) {
		}
		public override void Share (string json_data) {
		}
		public override void ShowAccountCenter (string json_data) {
		}
		public override void SendToSDKMessage(string json_data) {
		}

		//广告接入
		public override void SetupAD(string json_data) {
		}

		/*public override void Login(string appID) {
		}
		public override void WeChat (string json) {
		}*/


		public override string GetDeviceID() {
			return "";
		}

		public override string GetDeeplink()
        {
            return "";
        }
		public override string GetPushDeviceToken () {
			return "";
		}
        public override void RunVibrator(long tt)
        {
        }
        // 打电话
        public override void CallUp(string val)
        {

        }
		public override void QueryCityName(float latitude, float longitude) {
		}

		public override void QueryGPS() {
			OnGPS ("0.10001#0.10001#empty");
		}

		//录音接口
		const int FREQUENCY = 11025;
		//录音最大时长,单位:秒
		const int RECORD_TIME = 10;

		private string m_wavFileName = AppDefine.LOCAL_DATA_PATH + "/" + "record.wav";
		private string m_mp3FileName = AppDefine.LOCAL_DATA_PATH + "/" + "record.mp3";
		private string m_recordFileName = string.Empty;

		public override int StartRecord (string fileName)
		{
			SDKManager sdkMgr = AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK);
			if (sdkMgr == null)
				return 0;

			if (File.Exists (m_wavFileName))
				File.Delete (m_wavFileName);
			if (File.Exists (m_mp3FileName))
				File.Delete (m_mp3FileName);
			m_recordFileName = fileName;

			AudioSource audioSource = sdkMgr.gameObject.GetComponent<AudioSource> ();
			if (audioSource == null)
				audioSource = sdkMgr.gameObject.AddComponent<AudioSource> ();
			audioSource.loop = false;
			audioSource.mute = true;
			audioSource.Stop ();

			audioSource.clip = Microphone.Start (null, false, RECORD_TIME, FREQUENCY);
			while (Microphone.GetPosition (null) <= 0)
				;
			audioSource.Play ();

			return 1;
		}
		public override void StopRecord(bool callback)
		{
			/*SDKManager sdkMgr = AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK);
			if (sdkMgr == null)
				return;

			AudioSource audioSource = sdkMgr.gameObject.GetComponent<AudioSource> ();
			if (audioSource == null)
				return;

			Microphone.End (null);
			audioSource.Stop ();
			audioSource.mute = false;

			if (callback) {
				if (!SaveWav (m_wavFileName, audioSource.clip)) {
					sdkMgr.OnRecord ("");
					Debug.LogError ("[Android Record] save wav failed");
					return;
				}

				using (WaveFileReader reader = new WaveFileReader(m_wavFileName))
				using (LameMP3FileWriter writer = new LameMP3FileWriter(m_mp3FileName, reader.WaveFormat, LAMEPreset.ABR_128))
					reader.CopyTo(writer);

				File.Copy (m_mp3FileName, m_recordFileName, true);
				sdkMgr.OnRecord (m_recordFileName);
			}*/
		}

		public override void ShowProductRate(bool forceWeb)
		{
			Debug.Log ("Only run on iOS platform");
		}

		public override int PlayRecord (string fileName) {
			return 1;
		}
		public override void StopPlayRecord () {
		}

		private bool SaveWav(string fileName, AudioClip clip) {
			SDKManager sdkMgr = AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK);
			if (sdkMgr == null) {
				Debug.LogError ("[Android Record] get sdkMgr is null");
				return false;
			}

			int recordTime = sdkMgr.GetRecordTime ();
			if (recordTime <= 0) {
				Debug.LogError ("[Android Record] get record time <= 0");
				return false;
			}
			recordTime = Mathf.Clamp (recordTime + 1, 1, RECORD_TIME);

			using (FileStream fileStream = HoldFile (fileName)) {
				SaveData (fileStream, clip, recordTime);
				SaveHeader (fileStream, clip);
			}

			return true;
		}

		private FileStream HoldFile(string fileName) {
			FileStream fileStream = new FileStream (fileName, FileMode.Create);

			byte pad = new byte ();
			for (int idx = 0; idx < 44; ++idx)
				fileStream.WriteByte (pad);

			return fileStream;
		}

		private void SaveHeader(FileStream fileStream, AudioClip clip) {
			int frequency = clip.frequency;
			int channels = clip.channels;
			int samples = clip.samples;

			fileStream.Seek(0, SeekOrigin.Begin);

			Byte[] riff = System.Text.Encoding.UTF8.GetBytes("RIFF");
			fileStream.Write(riff, 0, 4);

			Byte[] chunkSize = BitConverter.GetBytes(fileStream.Length - 8);
			fileStream.Write(chunkSize, 0, 4);

			Byte[] wave = System.Text.Encoding.UTF8.GetBytes("WAVE");
			fileStream.Write(wave, 0, 4);

			Byte[] fmt = System.Text.Encoding.UTF8.GetBytes("fmt ");
			fileStream.Write(fmt, 0, 4);

			Byte[] subChunk1 = BitConverter.GetBytes(16);
			fileStream.Write(subChunk1, 0, 4);

			UInt16 one = 1;
			Byte[] audioFormat = BitConverter.GetBytes(one);
			fileStream.Write(audioFormat, 0, 2);

			Byte[] numChannels = BitConverter.GetBytes(channels);
			fileStream.Write(numChannels, 0, 2);

			Byte[] sampleRate = BitConverter.GetBytes(frequency);
			fileStream.Write(sampleRate, 0, 4);

			Byte[] byteRate = BitConverter.GetBytes(frequency * channels * 2);
			fileStream.Write(byteRate, 0, 4);

			UInt16 blockAlign = (ushort) (channels * 2);
			fileStream.Write(BitConverter.GetBytes(blockAlign), 0, 2);

			UInt16 bps = 16;
			Byte[] bitsPerSample = BitConverter.GetBytes(bps);
			fileStream.Write(bitsPerSample, 0, 2);

			Byte[] datastring = System.Text.Encoding.UTF8.GetBytes("data");
			fileStream.Write(datastring, 0, 4);

			Byte[] subChunk2 = BitConverter.GetBytes(samples * channels * 2);
			fileStream.Write(subChunk2, 0, 4);
		}

		private void SaveData(FileStream fileStream, AudioClip clip, int recordTime) {
			int frequency = clip.frequency;
			int channels = clip.channels;
			int samples = clip.samples;

			float[] samplesBuffer = new float[samples];
			clip.GetData (samplesBuffer, 0);

			int realSamples = recordTime * frequency * channels;

			Int16[] intData = new Int16[realSamples];
			Byte[] byteData = new Byte[realSamples * 2];

			Byte[] byteSwap = new byte[2];
			for (int idx = 0; idx < realSamples; ++idx) {
				intData [idx] = (short)(samplesBuffer [idx] * 32767);
				byteSwap = BitConverter.GetBytes (intData [idx]);
				byteSwap.CopyTo (byteData, idx * 2);
			}

			fileStream.Write (byteData, 0, byteData.Length);
		}

		//权限相关
		public override int GetCanLocation() {
			return 0;
		}
		public override int GetCanVoice() {
			return 0;
		}
		public override int GetCanCamera(bool deep) {
			return 0;
		}
		public override int GetCanPushNotification () {
			return 0;
		}

		public override void OpenLocation() {}
		public override void OpenVoice() {}
		public override void OpenCamera() {}

		public override void GotoSetScene(string mode) {}

		public override byte[] LoadFile (string fileName) {
			string fullName = LuaFramework.ResourceManager.StreamingDataPath () + fileName;
			if (!File.Exists (fullName))
				return null;
			return File.ReadAllBytes (fullName);
		}

		public override void ForceQuit() {
		}

		//public override void CallScheme(string scheme) {}
		//public override int CallPhoto() { return 0; }
		public override void ScanFile (string destination){
		}
		public override void SaveImageToPhotosAlbum (string readAddr){
		}
		public override void SaveVideoToPhotosAlbum (string readAddr){
		}
		public override void OpenPhotoAlbums (){
		}
		public override void OpenApp(string packageName,string downLink) {
		}
    }
}