using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace LuaFramework {
    public class SDKInterfaceAndroid : SDKInterface {
        private AndroidJavaObject jo;

        public SDKInterfaceAndroid() {
#if UNITY_ANDROID && !UNITY_EDITOR
            using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer")) {
                jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
            }
#endif
        }

        private T SDKCall<T>(string method, params object[] param) {
            try {
                return jo.Call<T>(method, param);
            }
            catch (Exception e) {
                Debug.LogError(e);
            }
            return default(T);
        }

        private void SDKCall(string method, params object[] param) {
            try {
                jo.Call(method, param);
            }
            catch (Exception e) {
                Debug.LogError(e);
            }
        }

		public override void Init (string json_data) {
			SDKCall("HandleInit", json_data);
		}
		public override void Login (string json_data) {
			SDKCall("HandleLogin", json_data);
		}
		public override void LoginOut (string json_data) {
			SDKCall("HandleLoginOut", json_data);
		}
		public override void Relogin (string json_data) {
			SDKCall("HandleRelogin", json_data);
		}
		public override void Pay (string json_data) {
			SDKCall("HandlePay", json_data);
		}
		public override void PostPay(string json_data) {
			SDKCall ("HandlePostPay", json_data);
		}
		public override void Share (string json_data) {
			SDKCall("HandleShare", json_data);
		}
		public override void ShowAccountCenter (string json_data) {
			SDKCall("HandleShowAccountCenter", json_data);
		}
		public override void SendToSDKMessage(string json_data) {
			SDKCall("HandleSendToSDKMessage", json_data);
		}

		//广告接入
		public override void SetupAD(string json_data) {
			SDKCall("HandleSetupAD", json_data);
		}

        /*public override void Login(string appID) {
            SDKCall("Login", appID);
        }
		public override void WeChat(string json) {
			if (string.IsNullOrEmpty (json)) {
				Debug.LogError ("[WeChat] json is empty");
				return;
			}
			SDKCall("WeChat", json);
		}*/



		public override string GetDeviceID() {
			return SDKCall<string> ("DeviceID");
		}

		public override string GetDeeplink()
        {
			return SDKCall<string>("Deeplink");
        }
		public override string GetPushDeviceToken ()
		{
			return SDKCall<string>("PushDeviceToken");
		}
        public override void RunVibrator(long tt)
        {
            SDKCall("RunVibrator", tt);
        }
        // 打电话
        public override void CallUp(string val)
        {
            SDKCall("CallUp", val);
        }

		public override void QueryCityName(float latitude, float longitude)
		{
			SDKCall("QueryingCityName", new float[]{ latitude, longitude });
		}

		public override void QueryGPS() {
			SDKCall ("QueryingGPS");
		}

		public override int StartRecord (string fileName)
		{
			return SDKCall<int> ("StartRecording", fileName);
		}
		public override void StopRecord(bool callback)
		{
			SDKCall ("StopRecording", callback);
		}

		public override void ShowProductRate(bool forceWeb)
		{
			Debug.Log ("Only run on iOS platform");
		}

		public override int PlayRecord (string fileName) {
			return SDKCall<int> ("PlayingRecord", fileName);
		}
		public override void StopPlayRecord () {
			SDKCall ("StopPlayingRecord");
		}

		//权限相关
		public override int GetCanLocation() {
			return SDKCall<int> ("CanLocation");
		}
		public override int GetCanVoice() {
			return SDKCall<int> ("CanVoice");
		}
		public override int GetCanCamera(bool deep) {
			return SDKCall<int> ("CanCamera", deep);
		}
		public override int GetCanPushNotification () {
			return SDKCall<int> ("CanPushNotification");
		}

		public override void OpenLocation() {
			SDKCall ("OpeningLocation");
		}
		public override void OpenVoice() {
			SDKCall ("OpeningVoice");
		}
		public override void OpenCamera() {
			SDKCall ("OpeningCamera");
		}

		public override void GotoSetScene(string mode) {
			SDKCall ("GoingSetScene", mode);
		}

		public override byte[] LoadFile (string fileName) {
			return SDKCall<byte[]> ("LoadingFile", fileName);
		}

		public override void ForceQuit() {
			SDKCall ("ForceQuiting");
		}

		/*public override void CallScheme(string scheme) {
			SDKCall ("CallingScheme", scheme);
		}

		public override int CallPhoto() {
			return SDKCall<int> ("CallingPhoto");
		}*/

		public override void ScanFile(string destination) {
			Debug.Log("HandleScanFile " + destination);
			SDKCall ("HandleScanFile",destination);
		}
		public override void SaveImageToPhotosAlbum (string readAddr){
		}
		public override void SaveVideoToPhotosAlbum (string readAddr){
		}
		public override void OpenPhotoAlbums (){
		}

		public override void OpenApp(string packageName,string downLink) {
			Debug.Log("HandleOpenApp " + packageName + " " + downLink);
			SDKCall ("HandleOpenApp",packageName,downLink);
		}
    }
}