using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using LitJson;

namespace  LuaFramework {
    /// <summary>
    /// SDK 回调 Android和IOS走同样的回调接口，保证接口的统一性
    /// </summary>
    public class SDKCallback : MonoBehaviour {

        private static SDKCallback _instance;

        private static object _lock = new object();

        //初始化回调对象
        public static SDKCallback InitCallback() {
            lock (_lock) {
                if (_instance == null) {
                    GameObject callback = GameObject.Find("SDK_callback");
                    if (callback == null) {
                        callback = new GameObject("SDK_callback");
                        _instance = callback.AddComponent<SDKCallback>();
                        UnityEngine.Object.DontDestroyOnLoad(callback);
                    }
                    else {
                        _instance = callback.GetComponent<SDKCallback>();
                    }
                }

                return _instance;
            }
        }

		public void InitResult(string json_data) {
			if(SDKInterface.Instance.OnInitResult != null)
				SDKInterface.Instance.OnInitResult.Invoke (json_data);
		}

		public void LoginResult(string json_data) {
			if(SDKInterface.Instance.OnLoginResult != null)
				SDKInterface.Instance.OnLoginResult.Invoke (json_data);
		}

		public void LoginOutResult(string json_data) {
			if(SDKInterface.Instance.OnLoginOutResult != null)
				SDKInterface.Instance.OnLoginOutResult.Invoke (json_data);
		}

		public void ReloginResult(string json_data) {
			if (SDKInterface.Instance.OnReloginResult != null)
				SDKInterface.Instance.OnReloginResult.Invoke (json_data);
		}

		public void PayResult(string json_data) {
			if(SDKInterface.Instance.OnPayResult != null)
				SDKInterface.Instance.OnPayResult.Invoke (json_data);
		}
		public void PostPayResult(string json_data) {
			if(SDKInterface.Instance.OnPostPayResult != null)
				SDKInterface.Instance.OnPostPayResult.Invoke (json_data);
		}
		public void PaySuccess(string json_data) {
			if(SDKInterface.Instance.OnPaySuccess != null)
				SDKInterface.Instance.OnPaySuccess.Invoke (json_data);
		}

		public void PayFail(string json_data) {
			if(SDKInterface.Instance.OnPayFail != null)
				SDKInterface.Instance.OnPayFail.Invoke (json_data);
		}

		public void ShareResult(string json_data) {
			if(SDKInterface.Instance.OnShareResult != null)
				SDKInterface.Instance.OnShareResult.Invoke (json_data);
		}

		public void ShowAccountCenterResult(string json_data) {
			if(SDKInterface.Instance.OnShowAccountCenterResult != null)
				SDKInterface.Instance.OnShowAccountCenterResult.Invoke (json_data);
		}

		public void HandleSetupADResult(string json_data) {
			if(SDKInterface.Instance.OnHandleSetupADResult != null)
				SDKInterface.Instance.OnHandleSetupADResult.Invoke (json_data);
		}

		public void HandleScanFileResult(string json_data) {
			Debug.Log("HandleScanFileResult" + json_data);
			if(SDKInterface.Instance.OnHandleScanFileResult != null)
				SDKInterface.Instance.OnHandleScanFileResult.Invoke (json_data);
		}

		public void HandleOpenAppResult(string json_data) {
			Debug.Log("HandleOpenAppResult" + json_data);
			if(SDKInterface.Instance.OnHandleOpenAppResult != null)
				SDKInterface.Instance.OnHandleOpenAppResult.Invoke (json_data);
		}

        /*//微信登录回调,获取token
        public void OnLoginSuc(string jsonData) {
            if (jsonData == null) {
                UnityEngine.Debug.LogError("The data parse error." + jsonData);
                return;
            }

            if (SDKInterface.Instance.OnLoginSuc != null) {
                SDKInterface.Instance.OnLoginSuc.Invoke(jsonData);
            }
        }

		public void OnWeChatError(string result) {
			if (SDKInterface.Instance.OnWeChatError != null) {
				SDKInterface.Instance.OnWeChatError.Invoke (result);
			}
		}

		public void OnWeChatShare(string result) {
			if (SDKInterface.Instance.OnWeChatShare != null) {
				SDKInterface.Instance.OnWeChatShare.Invoke (result);
			}
		}*/

		public void OnUpdCityName(string cityName) {
			if (SDKInterface.Instance.OnUpdCityName != null) {
				SDKInterface.Instance.OnUpdCityName.Invoke (cityName);
			}
		}
		public void OnGPS(string detail) {
			if (SDKInterface.Instance.OnGPS != null) {
				SDKInterface.Instance.OnGPS.Invoke (detail);
			}
		}

		public void OnRecord(string fileName) {
			if (SDKInterface.Instance.OnRecord != null) {
				SDKInterface.Instance.OnRecord.Invoke (fileName);
			}
		}

		public void OnPlayRecordFinish(string fileName) {
			if (SDKInterface.Instance.OnPlayRecordFinish != null) {
				SDKInterface.Instance.OnPlayRecordFinish.Invoke (fileName);
			}
		}

        public void Log(string log) {
            Debug.Log(log);
        }
		public void LogError(string log) {
			Debug.LogError (log);
		}

		public void SaveImageToPhotosAlbumCallBack(string log) {
			Debug.LogError (log);
		}
		public void SaveVedioToPhotosAlbumCallBack(string log) {
			Debug.LogError (log);
		}

		public void PicCallFunc(string log) {
			Debug.LogError (log);
		}
    }
}