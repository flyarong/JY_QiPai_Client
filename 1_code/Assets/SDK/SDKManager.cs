/*
 
 */
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using LuaInterface;


namespace LuaFramework {
    public class SDKManager : Manager {
		
		private LuaFunction onInitCallback = null;
		private LuaFunction onLoginCallback = null;
		private LuaFunction onLoginOutCallback = null;
		private LuaFunction onReloginCallback = null;
		private LuaFunction onPayCallback = null;
		private LuaFunction onPostPayCallback = null;
		private LuaFunction onShareCallback = null;
		private LuaFunction onShowAccountCenterCallback = null;
		private LuaFunction onHandleSetupADCallback = null;
		private LuaFunction onHandleScanFileCallback = null;
		private LuaFunction onHandleOpenAppResultCallback = null;

		private LuaFunction recordCallback = null;
		private LuaFunction playRecordFinishCallback = null;

        void Awake() {
            SDKCallback.InitCallback();
#if UNITY_ANDROID
            new SDKInterfaceAndroid();
#elif UNITY_IPHONE
			new SDKInterfaceIOS();
			    
#endif
	
			SDKInterface.Instance.OnInitResult = delegate(string json_data) {
				if(onInitCallback != null)
					onInitCallback.Call(json_data);
			};

			SDKInterface.Instance.OnLoginResult = delegate(string json_data) {
				if(onLoginCallback != null)
					onLoginCallback.Call(json_data);
			};

			SDKInterface.Instance.OnLoginOutResult = delegate(string json_data) {
				if(onLoginOutCallback != null)
					onLoginOutCallback.Call(json_data);
			};

			SDKInterface.Instance.OnReloginResult = delegate(string json_data) {
				if (onReloginCallback != null)
					onReloginCallback.Call (json_data);
			};

			SDKInterface.Instance.OnPayResult = delegate(string json_data) {
				if(onPayCallback != null)
					onPayCallback.Call(json_data);
			};
			SDKInterface.Instance.OnPostPayResult = delegate(string json_data) {
				if(onPostPayCallback != null)
					onPostPayCallback.Call(json_data);
			};

			SDKInterface.Instance.OnPaySuccess = delegate(string json_data) {
				if(onPayCallback != null)
					onPayCallback.Call(json_data);
			};

			SDKInterface.Instance.OnPayFail = delegate(string json_data) {
				if(onPayCallback != null)
					onPayCallback.Call(json_data);
			};

			SDKInterface.Instance.OnShareResult = delegate(string json_data) {
				if(onShareCallback != null)
					onShareCallback.Call(json_data);
			};

			SDKInterface.Instance.OnShowAccountCenterResult = delegate(string json_data) {
				if(onShowAccountCenterCallback != null)
					onShowAccountCenterCallback.Call(json_data);
			};
				
			SDKInterface.Instance.OnHandleSetupADResult = delegate(string json_data) {
				if(onHandleSetupADCallback != null)
					onHandleSetupADCallback.Call(json_data);
			};

			SDKInterface.Instance.OnHandleScanFileResult = delegate(string json_data) {
				Debug.Log("OnHandleScanFileResult" + json_data);
				if(onHandleScanFileCallback != null)
					onHandleScanFileCallback.Call(json_data);
			};

			SDKInterface.Instance.OnHandleOpenAppResult = delegate(string json_data) {
				Debug.Log("OnHandleOpenAppResult" + json_data);
				if(onHandleOpenAppResultCallback != null)
					onHandleOpenAppResultCallback.Call(json_data);
			};
			
			/*public LuaFunction handleWeChatError = null;
			public LuaFunction shareWeChat = null;
			public LuaFunction loginCallback = null;
            SDKInterface.Instance.OnLoginSuc = delegate (string result) {
                OnLoginSuc(result);
            };
			SDKInterface.Instance.OnWeChatError = delegate(string result) {
				OnWeChatError(result);
			};
			SDKInterface.Instance.OnWeChatShare = delegate(string result) {
				OnWeChatShare(result);
			};

			public void Login(LuaFunction func, LuaFunction errorCallback) {
				SDKInterface.Instance.Login(AppID);
				if (func != null) {
					loginCallback = func;
				}
				if (errorCallback != null)
					handleWeChatError = errorCallback;
			}
			public void WeChat(string json, LuaFunction callback) {
				SDKInterface.Instance.WeChat(json);
				if (callback != null)
					shareWeChat = callback;
			}
			public void WeChatShareImage(string fileName, bool isCircleOfFriends) {
				Texture2D texture = ResManager.LoadAsset<Texture2D>(fileName, null, null);
				if (texture == null) {
					Debug.LogError ("[WX Share] WeChatShareImage load texture failed: " + fileName);
					return;
				}
				string saveFile = ResManager.DataPath + fileName;
				byte[] datas = texture.EncodeToPNG ();
				if (datas == null || datas.Length <= 0) {
					Debug.LogError ("[WX Share] WeChatShareImage encode texture failed: " + fileName);
					return;
				}
				ResManager.WriteFile (saveFile, datas, 0, datas.Length);

				string json = string.Empty;
				if (isCircleOfFriends)
					json = "{\"type\": 7, \"imgFile\": \"" + saveFile + "\", \"isCircleOfFriends\": true}";
				else
					json = "{\"type\": 7, \"imgFile\": \"" + saveFile + "\", \"isCircleOfFriends\": false}";

				SDKInterface.Instance.WeChat(json); 
			}

			internal class JsonFormat {
				public string token = string.Empty;
				public JsonFormat(string code) {
					token = code;
				}
			}
			public void OnLoginSuc(string result) {
				if (loginCallback != null) {
					//format json
					JsonFormat jf = new JsonFormat(result);
					loginCallback.Call(JsonUtility.ToJson(jf));
				}
			}

			public void OnWeChatError(string result) {
				Debug.Log("OnWeChatError: " + result);
				if (handleWeChatError != null)
					handleWeChatError.Call (result);
			}

			public void OnWeChatShare(string result) {
				Debug.Log("微信分享返回 " + result);
				if (shareWeChat != null)
				{
					shareWeChat.Call(result);
				}
			}*/

			SDKInterface.Instance.OnUpdCityName = delegate(string cityName) {
				OnUpdCityName(cityName);
			};
			SDKInterface.Instance.OnGPS = delegate(string detail) {
				OnGPS(detail);
			};
			SDKInterface.Instance.OnRecord = delegate(string fileName) {
				OnRecord(fileName);
			};
			SDKInterface.Instance.OnPlayRecordFinish = delegate(string fileName) {
				OnPlayRecordFinish(fileName);
			};
        }

		public void Init(string json_data, LuaFunction callback) {
			onInitCallback = callback;
			SDKInterface.Instance.Init(json_data);
		}

		public void Login(string json_data, LuaFunction callback) {
			onLoginCallback = callback;
			SDKInterface.Instance.Login(json_data);
		}

		public void LoginOut(string json_data, LuaFunction callback) {
			onLoginOutCallback = callback;
			SDKInterface.Instance.LoginOut(json_data);
		}

		public void Relogin(string json_data, LuaFunction callback) {
			onReloginCallback = callback;
			SDKInterface.Instance.Relogin (json_data);
		}

		public void Pay(string json_data, LuaFunction callback) {
			if(callback != null)
				onPayCallback = callback;
			SDKInterface.Instance.Pay(json_data);
		}
		public void PostPay(string json_data, LuaFunction callback) {
			if(callback != null)
				onPostPayCallback = callback;
			SDKInterface.Instance.PostPay(json_data);
		}
		public void SetPayCallback(LuaFunction callback) {
			onPayCallback = callback;
		}
		public void SetPostPayCallback(LuaFunction callback) {
			onPostPayCallback = callback;
		}
		public void Share(string json_data, LuaFunction callback) {
			onShareCallback = callback;
			SDKInterface.Instance.Share(json_data);
		}

		public void ShowAccountCenter(string json_data, LuaFunction callback) {
			onShowAccountCenterCallback = callback;
			SDKInterface.Instance.ShowAccountCenter(json_data);
		}
		public void SendToSDKMessage(string json_data) {
			SDKInterface.Instance.SendToSDKMessage(json_data);
		}

		public void SetupAD(string json_data, LuaFunction callback) {
			onHandleSetupADCallback = callback;
			SDKInterface.Instance.SetupAD(json_data);
			RewardADMgr.Instance.SetupAD ();
		}

		public void PrepareAD(string codeID, string rewardName, int rewardAmount, string userID, string extraData, int width, int height,string adType ,int viewWidth,int viewHeight,LuaFunction callback) {
			RewardADMgr.Instance.PrepareAD(codeID, rewardName, rewardAmount, userID, extraData, width, height,adType ,viewWidth,viewHeight,callback);
		}

		public void PlayAD(string codeID, LuaFunction callback) {
			RewardADMgr.Instance.PlayAD(codeID, callback);
		}

		public void AddRewardVideoAdListener(LuaFunction RewardVideoAdListener,
											LuaFunction OnError,
											LuaFunction OnRewardVideoAdLoad,
											LuaFunction OnRewardVideoCached)
		{
			RewardADMgr.Instance.AddRewardVideoAdListener(RewardVideoAdListener, OnError,OnRewardVideoAdLoad,OnRewardVideoCached);
		}

		public void AddRewardAdInteractionListener(LuaFunction RewardAdInteractionListener,
												LuaFunction OnAdShowCallback,
												LuaFunction OnAdVideoBarClickCallback, 
												LuaFunction OnAdCloseCallback, 
												LuaFunction OnVideoCompleteCallback,
												LuaFunction OnVideoErrorCallback,
												LuaFunction OnRewardVerifyCallback)
		{
			RewardADMgr.Instance.AddRewardAdInteractionListener(RewardAdInteractionListener, 
																OnAdShowCallback,
																OnAdVideoBarClickCallback,
																OnAdCloseCallback,
																OnVideoCompleteCallback,
																OnVideoErrorCallback,
																OnRewardVerifyCallback);
		}
		public void AddExpressAdListener(LuaFunction ExpressAdistener,
                                        LuaFunction OnError,
                                        LuaFunction OnExpressAdLoad,
                                        LuaFunction OnExpressBannerAdLoad,
                                        LuaFunction OnExpressInterstitialAdLoad)
		{
			RewardADMgr.Instance.AddExpressAdListener( ExpressAdistener,
															OnError,
															OnExpressAdLoad,
															OnExpressBannerAdLoad,
															OnExpressInterstitialAdLoad);
		}

		public void AddExpressAdInteractionListener(LuaFunction ExpressAdInteractionListener,
												LuaFunction OnExpressAdClicked,
												LuaFunction OnExpressAdShow, 
												LuaFunction OnExpressAdRenderError, 
												LuaFunction OnExpressAdRenderSucc,
												LuaFunction OnExpressAdClose)
		{
			RewardADMgr.Instance.AddExpressAdInteractionListener( ExpressAdInteractionListener,
																	OnExpressAdClicked,
																	OnExpressAdShow, 
																	OnExpressAdRenderError, 
																	OnExpressAdRenderSucc,
																	OnExpressAdClose);
		}

		public void RemoveRewardVideoAdListener(){
			RewardADMgr.Instance.RemoveRewardVideoAdListener();
		}

		public void RemoveRewardAdInteractionListener(){
			RewardADMgr.Instance.RemoveRewardAdInteractionListener();
		}
		public void RemoveExpressAdExpressListener(){
			RewardADMgr.Instance.RemoveExpressAdExpressListener();
		}

		public void RemoveExpressAdInteractionListener(){
			RewardADMgr.Instance.RemoveExpressAdInteractionListener();
		}

		public void ClearAD(string codeID) {
			RewardADMgr.Instance.ClearAD(codeID);
		}

		public void ClearAllAD() {
			RewardADMgr.Instance.ClearAllAD();
		}

		public void AddHandleScanFileCallback(LuaFunction callback) {
			onHandleScanFileCallback = callback;
		}

		public void ScanFile(string destination){
			SDKInterface.Instance.ScanFile(destination);
		}

		public void SaveImageToPhotosAlbum(string destination){
			SDKInterface.Instance.SaveImageToPhotosAlbum(destination);
		}

		public void SaveVideoToPhotosAlbum(string destination){
			SDKInterface.Instance.SaveVideoToPhotosAlbum(destination);
		}

		public void OpenPhotoAlbums(){
			SDKInterface.Instance.OpenPhotoAlbums();
		}

		public void OpenApp(string packageName,string downLink){
			SDKInterface.Instance.OpenApp(packageName,downLink);
		}

		public void AddHandleOpenAppResultCallback(LuaFunction callback) {
			onHandleOpenAppResultCallback = callback;
		}

		public void OnUpdCityName(string cityName) {
			Debug.Log("OnUpdCityName " + cityName);
			GameManager mgr = AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
			if (mgr) {
				GPS gps = mgr.gameObject.GetComponent<GPS> ();
				if (gps)
					gps.SetCityName (cityName);
			}
		}

		private float mLatitude = 0.0f;
		private float mLongitude = 0.0f;
		private string mLocation = string.Empty;
		public void OnGPS(string detail) {
			string[] items = detail.Split ('#');
			if (items.Length != 3) {
				Debug.LogError ("[GPS] OnGPS split failed:" + detail);
				return;
			}

			float latitude = 0.0f, longitude = 0.0f;
			if (!float.TryParse (items [0], out latitude)) {
				Debug.LogError ("[GPS] OnGPS parse latitude failed:" + detail);
				return;
			}
			if (!float.TryParse (items [1], out longitude)) {
				Debug.LogError ("[GPS] OnGPS parse longitude failed:" + detail);
				return;
			}
			string location = items [2];

			Debug.Log(string.Format("[GPS] OnGPS({0}, {1}, {2})", latitude, longitude, location));

			mLatitude = latitude;
			mLongitude = longitude;
			mLocation = location;

			if (handleGPSCallback != null) {
				handleGPSCallback.Call ();
			}
		}
		public float GetLatitude() { return mLatitude; }
		public float GetLongitude() { return mLongitude; }
		public string GetLocation() { return mLocation; }

		public void OnRecord(string fileName) {
			Debug.Log("OnRecord " + fileName);

			if (recordCallback != null) {
				if(m_recordTime > 0)
					recordCallback.Call (fileName);
				else
					recordCallback.Call ("");
			}
		}
		public void OnPlayRecordFinish(string fileName) {
			Debug.Log("OnPlayRecordFinish " + fileName);

			if (playRecordFinishCallback != null)
				playRecordFinishCallback.Call (fileName);
		}

		public string GetDeviceID() {
			return SDKInterface.Instance.GetDeviceID();
		}

		public string GetDeeplink()
        {
            return SDKInterface.Instance.GetDeeplink();
        }

		public string GetPushDeviceToken() {
			return SDKInterface.Instance.GetPushDeviceToken();
		}

        public void RunVibrator(long tt)
        {
            SDKInterface.Instance.RunVibrator(tt);
        }
        public void CallUp(string val)
        {
            Debug.Log("电话=" + val);
            SDKInterface.Instance.CallUp(val);
        }

		public void StartGPS(LuaFunction callback) {
			GameManager mgr = AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
			if (mgr) {
				GPS gps = mgr.gameObject.GetComponent<GPS> ();
				if (gps)
					gps.StartGPS ((int resultCode) => {
						if(callback != null)
							callback.Call(resultCode);
					});
				else
					Debug.LogError ("[GPS] StartGPS failed. gps is null");
			} else
				Debug.LogError ("[GPS] StartGPS failed. gameMgr is null");
		}

		public void QueryCityName(float latitude, float longitude) {
			SDKInterface.Instance.QueryCityName(latitude, longitude);
		}

		private LuaFunction handleGPSCallback;
		public void QueryGPS(LuaFunction callback) {
			handleGPSCallback = callback;
			SDKInterface.Instance.QueryGPS();
		}

		//录音最大时长,单位:秒
		const int RECORD_TIME = 10;
		private int m_recordTime = 0;
		private Coroutine m_recordCoroutine;
		private IEnumerator RecordTimeDown() {
			m_recordTime = 0;

			while (m_recordTime < RECORD_TIME) {
				yield return new WaitForSeconds (1);
				++m_recordTime;
				//Debug.Log ("record: " + m_recordTime);
			}

			if (m_recordTime >= RECORD_TIME)
				stopRecord (true);
			
			yield return 0;
		}
		private void stopRecord(bool callback) {
			SDKInterface.Instance.StopRecord(callback);
			Debug.Log ("stopRecord......");
		}
		public int GetRecordTime() { return m_recordTime; }

		public int StartRecord(string fileName, LuaFunction callback) {
			Debug.Log("StartRecord fileName: " + fileName);
            if (Microphone.devices.Length <= 0)
            {
                return -1;
            }

            recordCallback = callback;

			m_recordTime = 0;
			int result = SDKInterface.Instance.StartRecord (fileName);
			if(result > 0)
				m_recordCoroutine = StartCoroutine (RecordTimeDown ());

			return result;
		}
		public void StopRecord(bool callback) {
			StopCoroutine (m_recordCoroutine);
			stopRecord(callback);
		}

		public int PlayRecord(string fileName, LuaFunction callback) {
			playRecordFinishCallback = callback;
			return SDKInterface.Instance.PlayRecord(fileName);
		}
		public void StopPlayRecord() {
			SDKInterface.Instance.StopPlayRecord();
		}
		public void ShowProductRate(bool forceWeb) {
			SDKInterface.Instance.ShowProductRate(forceWeb);
		}

		public int GetCanLocation() {
			return SDKInterface.Instance.GetCanLocation();
		}
		public int GetCanVoice() {
			return SDKInterface.Instance.GetCanVoice();
		}
		public int GetCanCamera(bool deep) {
			return SDKInterface.Instance.GetCanCamera(deep);
		}
		public int GetCanPushNotification () {
			return SDKInterface.Instance.GetCanPushNotification();
		}

		public void OpenLocation() {
			SDKInterface.Instance.OpenLocation();
		}

		public void OpenVoice() {
			SDKInterface.Instance.OpenVoice();
		}
		public void OpenCamera() {
			SDKInterface.Instance.OpenCamera();
		}

		public void GotoSetScene(string mode) {
			SDKInterface.Instance.GotoSetScene(mode);
		}

		public byte[] LoadFile(string fileName) {
			return SDKInterface.Instance.LoadFile(fileName);
		}

		public void ForceQuit() {
			SDKInterface.Instance.ForceQuit();
		}

		/*public void CallScheme(string scheme) {
			SDKInterface.Instance.CallScheme(scheme);
		}
		public int CallPhoto() {
			return SDKInterface.Instance.CallPhoto();
		}*/
    }
}
