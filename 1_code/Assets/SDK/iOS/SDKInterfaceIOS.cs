using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using System.Runtime.InteropServices;

namespace LuaFramework {
    public class SDKInterfaceIOS : SDKInterface {

		#if UNITY_IPHONE

		//[DllImport("__Internal")]
		//private static extern void WXLogin(string appID);
		//[DllImport("__Internal")]
		//private static extern void WXShare(string json);

		[DllImport("__Internal")]
		private static extern void HandleInit(string json_data);
		[DllImport("__Internal")]
		private static extern void HandleLogin(string json_data);
		[DllImport("__Internal")]
		private static extern void HandleLoginOut(string json_data);
		[DllImport("__Internal")]
		private static extern void HandleRelogin(string json_data);
		[DllImport("__Internal")]
		private static extern void HandlePay(string json_data);
		//[DllImport("__Internal")]
		//private static extern void HandlePostPay(string json_data);
		[DllImport("__Internal")]
		private static extern void HandleShare(string json_data);
		[DllImport("__Internal")]
		private static extern void HandleShowAccountCenter(string json_data);
		//[DllImport("__Internal")]
		//private static extern void HandleSendToSDKMessage(string json_data);

		[DllImport("__Internal")]
		private static extern void HandleSetupAD(string json_data);

		[DllImport("__Internal")]
		private static extern string DeviceID();
		[DllImport("__Internal")]
		private static extern string Deeplink();
		[DllImport("__Internal")]
		private static extern string PushDeviceToken();
		[DllImport("__Internal")]
		private static extern void PhoneCallUp(string number);
		[DllImport("__Internal")]
		private static extern void QueryingCityName(float latitude, float longitude);
		[DllImport("__Internal")]
		private static extern void QueryingGPS();
		
		[DllImport("__Internal")]
		private static extern void ShowProductRating();

		[DllImport("__Internal")]
		private static extern int CanLocation();
		[DllImport("__Internal")]
		private static extern int CanVoice();
		[DllImport("__Internal")]
		private static extern int CanCamera(bool deep);
		[DllImport("__Internal")]
		private static extern int CanPushNotification();
		[DllImport("__Internal")]
		private static extern void OpeningLocation ();
		[DllImport("__Internal")]
		private static extern void OpeningVoice ();
		[DllImport("__Internal")]
		private static extern void OpeningCamera ();
		[DllImport("__Internal")]
		private static extern void GoingSetScene (string mode);
		[DllImport("__Internal")]
		private static extern void ForceQuiting ();

		[DllImport ("__Internal")]
		private static extern void _OpenPhotoAlbums();
		[DllImport ("__Internal")]
		private static extern void _SaveImageToPhotosAlbum(string readAddr);
		[DllImport("__Internal")]
		private static extern void _SaveVideoToPhotosAlbum(string readAddr);
		// [DllImport("__Internal")]
		// private static extern void ScanFile(string destination);

		/*[DllImport("__Internal")]
		private static extern void CallingScheme(string scheme);
		[DllImport("__Internal")]
		private static extern int CallingPhoto();*/

#else

		//private static void WXLogin(string appID) {}
		//private static void WXShare(string json) {}

		private static void HandleInit(string json_data) {}
		private static void HandleLogin(string json_data) {}
		private static void HandleLoginOut(string json_data) {}
		private static void HandleRelogin(string json_data) {}
		private static void HandlePay(string json_data) {}
		//private static void HandlePostPay(string json_data) {}
		private static void HandleShare(string json_data) {}
		private static void HandleShowAccountCenter(string json_data) {}
		//private static void HandleSendToSDKMessage(string json_data) {}

		private static void HandleSetupAD(string json_data) {}

		private static string DeviceID(){ return string.Empty; }
		private static string Deeplink(){ return string.Empty; }
		private static string PushDeviceToken() { return string.Empty; }
		private static void PhoneCallUp(string number) {}
		private static void QueryingCityName(float latitude, float longitude) {}
		private static void QueryingGPS() {}

		private static void ShowProductRating () {}

		private static int CanLocation() { return 2; }
		private static int CanVoice() { return 2; }
		private static int CanCamera(bool deep) { return 2; }
		private static int CanPushNotification() { return 2; }
		private static void OpeningLocation() {}
		private static void OpeningVoice() {}
		private static void OpeningCamera() {}
		private static void GoingSetScene(string mode) {}
		private static void ForceQuiting() {}
		//private static void CallingScheme(string scheme) {}
		//private static int CallingPhoto() { return 0; }
		private static void _OpenPhotoAlbums(){}
		private static void _SaveImageToPhotosAlbum(string readAddr){}
		private static void _SaveVideoToPhotosAlbum(string readAddr){}

#endif

		void MixCode(string v) {
			byte[] data = null;
			if (string.IsNullOrEmpty (v))
				data = new byte[Random.Range (16, 64)];
			else
				data = System.Text.Encoding.Default.GetBytes (v);

			if (data == null || data.Length <= 0)
				return;

			if (data.Length % 4 < 2)
				Debug.Log ("v:" + data.Length);
		}

		public override void Init (string json_data) {
			MixCode (json_data);
			HandleInit (json_data);
		}
		public override void Login (string json_data) {
			MixCode (json_data);
			HandleLogin (json_data);
		}
		public override void LoginOut (string json_data) {
			HandleLoginOut (json_data);
		}
		public override void Relogin (string json_data) {
			MixCode (json_data);
			HandleRelogin (json_data);
		}
		public override void Pay (string json_data) {
			MixCode (json_data);
			HandlePay (json_data);
		}
		public override void PostPay(string json_data) {
			MixCode (json_data);
			//HandlePostPay (json_data);
		}
		public override void Share (string json_data) {
			MixCode (json_data);
			HandleShare (json_data);
		}
		public override void ShowAccountCenter (string json_data) {
			MixCode (json_data);
			HandleShowAccountCenter (json_data);
		}
		public override void SendToSDKMessage(string json_data)
		{
			MixCode(json_data);
			//todo
			//HandleSendToSDKMessage(json_data);
		}

		//广告接入
		public override void SetupAD(string json_data) {
			MixCode (json_data);
		}

        /*public override void Login(string appID) {
			WXLogin (appID);
        }
		public override void WeChat(string json) {
			if (string.IsNullOrEmpty (json)) {
				Debug.LogError ("[WeChat] json is empty");
				return;
			}
			WXShare (json);
		}*/



		public override string GetDeviceID() {
			return DeviceID ();
		}

        // nmg todo
		public override string GetDeeplink()
        {
			return Deeplink();
        }

		public override string GetPushDeviceToken ()
		{
			return string.Empty;
		}
        // nmg todo
        public override void RunVibrator(long tt)
        {
        }
        // 打电话
        public override void CallUp(string val)
        {
			PhoneCallUp (val);
        }
		public override void QueryCityName(float latitude, float longitude)
		{
			QueryingCityName(latitude, longitude);
		}

		public override void QueryGPS() {
			QueryingGPS ();
		}

		//录音接口
		public override int StartRecord (string fileName)
		{
			return 0;
		}
		public override void StopRecord(bool callback)
		{
		}
		public override int PlayRecord (string fileName) {
			return 0;
		}
		public override void StopPlayRecord () {
		}
		public override void ShowProductRate(bool forceWeb)
		{
			ShowProductRating ();
		}

		//权限相关
		public override int GetCanLocation() {
			return CanLocation ();
		}
		public override int GetCanVoice() {
			return CanVoice();
		}
		public override int GetCanCamera(bool deep) {
			return CanCamera(deep);
		}
		public override int GetCanPushNotification () {
			return CanPushNotification ();
		}

		public override void OpenLocation() {
			OpeningLocation ();
		}
		public override void OpenVoice() {
			OpeningVoice ();
		}
		public override void OpenCamera() {
			OpeningCamera ();
		}

		public override void GotoSetScene(string mode) {
			GoingSetScene (mode);
		}

		public override byte[] LoadFile (string fileName) {
			return File.ReadAllBytes (LuaFramework.ResourceManager.StreamingDataPath() + fileName);
		}

		public override void ForceQuit() {
			ForceQuiting ();
		}

		/*public override void CallScheme(string scheme) {
			CallingScheme (scheme);
		}
		public override int CallPhoto() {
			return CallingPhoto();
		}*/

		public override void ScanFile(string destination) {
			
		}
		/// <summary>
		/// 保存图片到相册
		/// </summary>
		/// <param name="readAddr"></param>
		public override void SaveImageToPhotosAlbum(string readAddr)
		{
			_SaveImageToPhotosAlbum (readAddr);
		}

		public override void SaveVideoToPhotosAlbum(string readAddr)
		{
			_SaveVideoToPhotosAlbum(readAddr);
		}
		public override void OpenPhotoAlbums()
		{
			_OpenPhotoAlbums();
		}

		public override void OpenApp(string packageName,string downLink) {
		}
    }
}
