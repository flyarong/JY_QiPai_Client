
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using ByteDance.Union;

public class RewardADMgr {
	private static RewardADMgr m_instance;
	public static RewardADMgr Instance {
		get {
			if (m_instance == null)
				m_instance = new RewardADMgr ();
			return m_instance;
		}
	}

	private AdNative AdNative
    {
        get
        {
            if (this.adNative == null)
            {
                this.adNative = SDK.CreateAdNative();
            }
#if UNITY_ANDROID
            SDK.RequestPermissionIfNecessary();
#endif
            return this.adNative;
        }
    }
	private sealed class RewardADType{
		public static string Noramal = "normal";
		public static string Banner = "banner";
		public static string Interstitial = "interstitial";
	}

	private AndroidJavaObject activity;

	public static LuaFunction rewardVideoAdListenerCallback;
	public static LuaFunction onErrorCallback;
	public static LuaFunction onRewardVideoAdLoadCallback;
	public static LuaFunction onRewardVideoCachedCallback;
	public static LuaFunction rewardAdInteractionListenerCallback;
	public static LuaFunction onAdShowCallback;
	public static LuaFunction onAdVideoBarClickCallback;
	public static LuaFunction onAdCloseCallback;
	public static LuaFunction onVideoCompleteCallback;
	public static LuaFunction onVideoErrorCallback;
	public static LuaFunction onRewardVerifyCallback;
	public static LuaFunction expressAdListenerCallback;
	public static LuaFunction onExpressAdLoadCallBack;

#if UNITY_IOS
	public static LuaFunction onExpressBannerAdLoadCallBack;
	public static LuaFunction onExpressInterstitialAdLoadCallBack;
#endif
	public static LuaFunction onExpressAdInteractionListenerCallback;
	public static LuaFunction onExpressAdClickedCallback;
	public static LuaFunction onExpressAdShowCallback;
	public static LuaFunction onExpressAdRenderErrorCallback;
	public static LuaFunction onExpressAdRenderSuccCallback;
	public static LuaFunction onExpressAdCloseCallback;

	internal class Unit
	{
		public string codeID;

		public string mType;
		#if UNITY_IOS
		public ExpressRewardVideoAd rewardVideoAd;
		#else
		public RewardVideoAd rewardVideoAd;
		#endif
		public ExpressAd mExpressBannerAd;
		public ExpressAd mExpressInterstitialAd;

		public Unit(string codeID) {
			this.codeID = codeID;
		}

		public void Prepare(string rewardName, int rewardAmount, string userID, string extraData, int width, int height, string adType ,int viewWidth,int viewHeight ,LuaFunction callback) {

			mType = adType;
			if(adType == RewardADType.Noramal)
			{
				var adSlot = new AdSlot.Builder ()
					.SetCodeId (codeID)
					.SetSupportDeepLink (true)
					.SetImageAcceptedSize (width, height)
					.SetExpressViewAcceptedSize(viewWidth,viewHeight)
					.SetRewardName (rewardName)
					.SetRewardAmount (rewardAmount)
					.SetUserID (userID)
					.SetMediaExtra (extraData)
					.SetOrientation (AdOrientation.Horizontal)
					.Build ();

				#if UNITY_IOS
					RewardADMgr.Instance.AdNative.LoadExpressRewardAd (adSlot, new RewardVideoAdListener (this));
				#else
					RewardADMgr.Instance.AdNative.LoadRewardVideoAd (adSlot, new RewardVideoAdListener (this));
				#endif
			}
			else if(adType == RewardADType.Banner||adType == RewardADType.Interstitial)
			{
				var adSlot = new AdSlot.Builder ()
					.SetCodeId (codeID)
					.SetSupportDeepLink (true)
					.SetImageAcceptedSize (width, height)
					.SetExpressViewAcceptedSize(viewWidth,viewHeight)
					//.SetRewardName (rewardName)
					//.SetRewardAmount (rewardAmount)
					.SetUserID (userID)
					.SetMediaExtra (extraData)
					.SetOrientation (AdOrientation.Horizontal)
					.Build ();

				Debug.Log("<color=white>Load Banner or Interstitial</color>");
				if(adType == RewardADType.Banner)
				{
					RewardADMgr.Instance.AdNative.LoadExpressBannerAd(adSlot, new ExpressAdListener (this));
				}
				else if(adType == RewardADType.Interstitial)
				{
					RewardADMgr.Instance.AdNative.LoadExpressInterstitialAd(adSlot, new ExpressAdListener (this));
				}
			}
		}

		public void Play(LuaFunction callback) {

			if (mType == RewardADType.Noramal)
			{
				if (rewardVideoAd == null) {
					callback.Call (codeID, -1);
					Debug.LogError(string.Format("[AD] play({0}) rewardVideoAd invalid", codeID));
					return;
				}
				Debug.Log("<color=white>Play Ad</color>");
				rewardVideoAd.ShowRewardVideoAd ();
			}else if(mType == RewardADType.Banner)
			{
#if UNITY_ANDROID			
				if (mExpressBannerAd == null) {
					callback.Call (codeID, -1);
					Debug.LogError(string.Format("[AD] play({0}) mExpressBannerAd invalid", codeID));
					return;
				}
				ExpressAdInteractionListener expressAdInteractionListener = new ExpressAdInteractionListener(this, mType);
        		ExpressAdDislikeCallback dislikeCallback = new ExpressAdDislikeCallback(this,mType);
				this.mExpressBannerAd.SetDownloadListener(
            		new AppDownloadListener(this));
				NativeAdManager.Instance.ShowExpressBannerAd(RewardADMgr.Instance.GetActivity(), mExpressBannerAd.handle, expressAdInteractionListener, dislikeCallback);
#endif				
			}else if(mType == RewardADType.Interstitial)
			{
#if UNITY_ANDROID	
				if (mExpressInterstitialAd == null) {
					callback.Call (codeID, -1);
					Debug.LogError(string.Format("[AD] play({0}) mExpressInterstitialAd invalid", codeID));
					return;
				}
				ExpressAdInteractionListener expressAdInteractionListener = new ExpressAdInteractionListener(this, mType);
				this.mExpressInterstitialAd.SetDownloadListener(
            		new AppDownloadListener(this));
        		NativeAdManager.Instance.ShowExpressInterstitialAd(RewardADMgr.Instance.GetActivity(), mExpressInterstitialAd.handle, expressAdInteractionListener);
#endif
			}
		}

		public void Dispose() {
			if (rewardVideoAd != null) {
				rewardVideoAd.Dispose ();
				rewardVideoAd = null;
			}
#if UNITY_ANDROID			
			if (mExpressBannerAd != null)
        	{
				NativeAdManager.Instance.ClearAdDialog();
				NativeAdManager.Instance.DestoryExpressAd(mExpressBannerAd.handle);
				mExpressBannerAd = null;
        	}
			if (mExpressInterstitialAd != null)
        	{
				Debug.Log("<---------Dispose Start InterstitialAd------->");
				NativeAdManager.Instance.ClearAdDialog();
				NativeAdManager.Instance.DestoryExpressAd(mExpressInterstitialAd.handle);
				mExpressInterstitialAd = null;
				Debug.Log("<---------Dispose End InterstitialAd------->");
        	}
#endif
			codeID = string.Empty;
		}
	}
	public AndroidJavaObject GetActivity()
    {
        if (activity == null)
        {
            var unityPlayer = new AndroidJavaClass(
            "com.unity3d.player.UnityPlayer");
            activity = unityPlayer.GetStatic<AndroidJavaObject>(
           "currentActivity");
        }
        return activity;
    }


	public static void RewardVideoAdListenerCallback (string codeID,int result) {
		if (rewardVideoAdListenerCallback != null)
			rewardVideoAdListenerCallback.Call (codeID, result);
	}

	public static void OnErrorCallback (string codeID,int code, string message) {
		if (onErrorCallback != null)
			onErrorCallback.Call (codeID, code,message);
	}

	public static void OnRewardVideoAdLoadCallback (string codeID,int result) {
		if (onRewardVideoAdLoadCallback != null)
			onRewardVideoAdLoadCallback.Call (codeID, result);
	}

	public static void OnRewardVideoCachedCallback (string codeID,int result) {
		if (onRewardVideoCachedCallback != null)
			onRewardVideoCachedCallback.Call (codeID, result);
	}

	public static void RewardAdInteractionListenerCallback (string codeID,int result) {
		if (rewardAdInteractionListenerCallback != null)
			rewardAdInteractionListenerCallback.Call (codeID, result);
	}

	public static void OnAdShowCallback (string codeID,int result) {
		if (onAdShowCallback != null)
			onAdShowCallback.Call (codeID, result);
	}

	public static void OnAdVideoBarClickCallback (string codeID,int result) {
		if (onAdVideoBarClickCallback != null)
			onAdVideoBarClickCallback.Call (codeID, result);
	}

	public static void OnAdCloseCallback (string codeID,int result) {
		if (onAdCloseCallback != null)
			onAdCloseCallback.Call (codeID, result);
	}

	public static void OnVideoCompleteCallback (string codeID,int result) {
		if (onVideoCompleteCallback != null)
			onVideoCompleteCallback.Call (codeID, result);
	}

	public static void OnVideoErrorCallback (string codeID,int result) {
		if (onVideoErrorCallback != null)
			onVideoErrorCallback.Call (codeID, result);
	}

	public static void OnRewardVerifyCallback (string codeID,int result,bool rewardVerify, int rewardAmount, string rewardName) {
		if (onRewardVerifyCallback != null)
			onRewardVerifyCallback.Call (codeID, result, rewardVerify, rewardAmount, rewardName);
	}
	
	/// <summary>
	/// Express:Bnanner and Interstitial
	/// </summary>
	/// <param name="codeID"></param>
	/// <param name="result"></param>
	public static void ExpressAdListenerCallback(string codeID ,int result)
	{
		if (expressAdListenerCallback != null)
			expressAdListenerCallback.Call (codeID, result);
	}

	public static void OnExpressAdLoadCallBack(string codeID ,int result)
	{
		if (onExpressAdLoadCallBack != null)
			onExpressAdLoadCallBack.Call (codeID, result);
	}

#if UNITY_IOS
	public static void OnExpressBannerAdLoadCallBack(string codeID ,int result)
	{
		if (onExpressBannerAdLoadCallBack != null)
			onExpressBannerAdLoadCallBack.Call (codeID, result);
	}

	public static void OnExpressInterstitialAdLoadCallBack(string codeID ,int result)
	{
		if (onExpressInterstitialAdLoadCallBack != null)
			onExpressInterstitialAdLoadCallBack.Call (codeID, result);
	}
#endif

	public static void ExpressAdInteractionListenerCallback(string codeID ,int result)
	{
		if (onExpressAdInteractionListenerCallback != null)
			onExpressAdInteractionListenerCallback.Call (codeID, result);
	}
	public static void OnExpressAdClickedCallback(string codeID ,int result)
	{
		if (onExpressAdClickedCallback != null)
			onExpressAdClickedCallback.Call (codeID, result);
	}

	public static void OnExpressAdShowCallback(string codeID ,int result)
	{
		if (onExpressAdShowCallback != null)
			onExpressAdShowCallback.Call (codeID, result);
	}

	public static void OnExpressAdRenderErrorCallback(string codeID,int code, string message)
	{
		if (onExpressAdRenderErrorCallback != null)
			onExpressAdRenderErrorCallback.Call (codeID, code , message);
	}
	public static void OnExpressAdRenderSuccCallback(string codeID ,int result)
	{
		if (onExpressAdRenderSuccCallback != null)
			onExpressAdRenderSuccCallback.Call (codeID, result);
	}
	public static void OnExpressAdCloseCallback(string codeID ,int result)
	{
		if (onExpressAdCloseCallback != null)
			onExpressAdCloseCallback.Call (codeID, result);
	}

	private sealed class RewardVideoAdListener : IRewardVideoAdListener {
		private Unit unit;
		public RewardVideoAdListener(Unit unit) {
			this.unit = unit;
			RewardVideoAdListenerCallback(unit.codeID,0);
		}

		public void OnError(int code, string message)
		{
			OnErrorCallback(unit.codeID, code,message);
			Debug.LogError(string.Format("[AD] prepare({0}) error {1},{2}: ", unit.codeID, code, message));
		}

		public void OnRewardVideoAdLoad(RewardVideoAd ad)
		{
			#if !(UNITY_IOS)
			ad.SetRewardAdInteractionListener(
				new RewardAdInteractionListener(unit));
			ad.SetShowDownLoadBar (false);
			unit.rewardVideoAd = ad;
			OnRewardVideoAdLoadCallback(unit.codeID, 0);
			Debug.Log (string.Format ("[AD] prepare({0}) loaded", unit.codeID));
			#endif
		}

		public void OnRewardVideoCached()
		{
			OnRewardVideoCachedCallback(unit.codeID, 0);
			Debug.Log (string.Format ("[AD] prepare({0}) ok", unit.codeID));
		}
		public void OnExpressRewardVideoAdLoad(ExpressRewardVideoAd ad)
		{
			#if UNITY_IOS
			ad.SetRewardAdInteractionListener(
				new RewardAdInteractionListener(unit));
			unit.rewardVideoAd = ad;
			OnRewardVideoAdLoadCallback(unit.codeID, 0);
			Debug.Log (string.Format ("[AD] prepare({0}) loaded", unit.codeID));
			#endif
		}
	}

	private sealed class RewardAdInteractionListener : IRewardAdInteractionListener
	{
		private Unit unit;
		public RewardAdInteractionListener(Unit unit) {
			this.unit = unit;
			RewardAdInteractionListenerCallback(unit.codeID,0);
		}

		public void OnAdShow()
		{
			OnAdShowCallback(unit.codeID,0);
			Debug.Log("[AD] play ad show:" + unit.codeID);
		}

		public void OnAdVideoBarClick()
		{
			OnAdVideoBarClickCallback(unit.codeID,0);
			Debug.Log("[AD] play ad click:" + unit.codeID);
		}

		public void OnAdClose()
		{
			OnAdCloseCallback(unit.codeID,0);
			Debug.Log("[AD] play ad close:" + unit.codeID);
		}

		public void OnVideoComplete()
		{
			OnVideoCompleteCallback(unit.codeID,0);
			Debug.Log("[AD] play ad complete:" + unit.codeID);
		}

		public void OnVideoError()
		{
			OnVideoErrorCallback(unit.codeID,0);
			Debug.LogError("[AD] play ad error:" + unit.codeID);
		}

		public void OnRewardVerify(bool rewardVerify, int rewardAmount, string rewardName)
		{
			OnRewardVerifyCallback(unit.codeID,0,rewardVerify,rewardAmount,rewardName);
			Debug.Log("[AD] codeID:" + unit.codeID + " verify:" + rewardVerify + " name:" + rewardName + " amount:" + rewardAmount);
		}
	}

	private sealed class ExpressAdListener :IExpressAdListener  {

		private Unit unit;
		public ExpressAdListener(Unit unit) {
			this.unit = unit;
			ExpressAdListenerCallback(unit.codeID,0);
		}
		public void OnError(int code, string message) {
			OnErrorCallback(unit.codeID, code,message);
			Debug.LogError(string.Format("[AD] prepare({0}) error {1},{2}: ", unit.codeID, code, message));
		}

		public void OnExpressAdLoad(List<ExpressAd> ads) {
			IEnumerator<ExpressAd> enumerator = ads.GetEnumerator();
            if(enumerator.MoveNext())
            {
				if(this.unit.mType == RewardADType.Banner)
				{
					this.unit.mExpressBannerAd = enumerator.Current;
				}
				else if(this.unit.mType == RewardADType.Interstitial)
				{
                	this.unit.mExpressInterstitialAd = enumerator.Current;
				}
			}
			Debug.LogError("OnExpressAdLoad");
			OnExpressAdLoadCallBack(unit.codeID,0);
		}
#if UNITY_IOS
		public void OnExpressBannerAdLoad(ExpressBannerAd ad) {
			Debug.LogError("OnExpressBannerAdLoad");
			OnExpressBannerAdLoadCallBack(unit.codeID,0);
		}

		public void OnExpressInterstitialAdLoad(ExpressInterstitialAd ad) {
			Debug.LogError("OnExpressInterstitialAdLoad");
			OnExpressInterstitialAdLoadCallBack(unit.codeID,0);
		}
#endif
	}
	
	private sealed class ExpressAdInteractionListener : IExpressAdInteractionListener
    {
        private Unit unit;
        string type;//0:feed   1:banner  2:interstitial

        public ExpressAdInteractionListener(Unit unit, string type)
        {
            this.unit = unit;
            this.type = type;
			ExpressAdInteractionListenerCallback(unit.codeID,0);
        }
        public void OnAdClicked(ExpressAd ad)
        {
            Debug.LogError("express OnAdClicked,type:" + type);
			OnExpressAdClickedCallback(unit.codeID,0);
        }

        public void OnAdShow(ExpressAd ad)
        {
            Debug.LogError("express OnAdShow,type:" + type);
			OnExpressAdShowCallback(unit.codeID,0);
        }

        public void OnAdViewRenderError(ExpressAd ad, int code, string message)
        {
            Debug.LogError("express OnAdViewRenderError,type:" + type);
			OnExpressAdRenderErrorCallback(unit.codeID, code,message);
        }

        public void OnAdViewRenderSucc(ExpressAd ad, float width, float height)
        {
            Debug.LogError("express OnAdViewRenderSucc,type:"+type);
			OnExpressAdRenderSuccCallback(unit.codeID,0);
        }
        public void OnAdClose(ExpressAd ad)
        {
            Debug.LogError("express OnAdClose,type:" + type);
			OnExpressAdCloseCallback(unit.codeID,0);
        }
    }
	
	private sealed class ExpressAdDislikeCallback : IDislikeInteractionListener
    {
        private Unit unit;
        string type;
        public ExpressAdDislikeCallback(Unit unit, string type)
        {
            this.unit = unit;
            this.type = type;
        }
        public void OnCancel()
        {
            Debug.LogError("express dislike OnCancel");
        }

        public void OnRefuse()
        {
            Debug.LogError("express dislike onRefuse");
        }

        public void OnSelected(int var1, string var2)
        {
            Debug.LogError("express dislike OnSelected:" + var2);
#if UNITY_IOS
        
#else
            //释放广告资源
			if (this.unit.mExpressBannerAd != null)
			{
				NativeAdManager.Instance.DestoryExpressAd(this.unit.mExpressBannerAd.handle);
				this.unit.mExpressBannerAd = null;
			}
#endif
        }
    }
	private sealed class AppDownloadListener : IAppDownloadListener
    {
        private Unit unit;

        public AppDownloadListener(Unit unit)
        {
            this.unit = unit;
        }

        public void OnIdle()
        {
        }

        public void OnDownloadActive(
            long totalBytes, long currBytes, string fileName, string appName)
        {
            Debug.Log("下载中，点击下载区域暂停");
        }

        public void OnDownloadPaused(
            long totalBytes, long currBytes, string fileName, string appName)
        {
            Debug.Log("下载暂停，点击下载区域继续");
        }

        public void OnDownloadFailed(
            long totalBytes, long currBytes, string fileName, string appName)
        {
            Debug.LogError("下载失败，点击下载区域重新下载");
        }

        public void OnDownloadFinished(
            long totalBytes, string fileName, string appName)
        {
            Debug.Log("下载完成，点击下载区域重新下载");
        }

        public void OnInstalled(string fileName, string appName)
        {
            Debug.Log("安装完成，点击下载区域打开");
        }
	}
	
	public AdNative adNative;
	private List<Unit> adList;

	private Unit Find(string codeID, bool clear) {
		Unit unit;
		for (int idx = 0; idx < adList.Count; ++idx) {
			unit = adList [idx];
			if (unit.codeID == codeID) {
				if (clear)
					adList.RemoveAt (idx);
				return unit;
			}
		}
		return null;
	}

	public void SetupAD() {
		//adNative = SDK.CreateAdNative ();
		adList = new List<Unit> ();
	}

	public void PrepareAD(string codeID, string rewardName, int rewardAmount, string userID, string extraData, int width, int height,string adType ,int viewWidth,int viewHeight, LuaFunction callback) {
		
		Unit unit = Find (codeID, true);
		if (unit != null)
			unit.Dispose ();

		// if (adNative == null) {
		// 	callback.Call (codeID, -1);
		// 	return;
		// }

		unit = new Unit (codeID);
		adList.Add (unit);
		unit.Prepare (rewardName, rewardAmount, userID, extraData, width, height, adType ,viewWidth,viewHeight,callback);
	}

	public void PlayAD(string codeID, LuaFunction callback) {
		// if (adNative == null) {
		// 	callback.Call (codeID, -1);
		// 	return;
		// }
		Unit unit = Find (codeID, false);
		if (unit == null){
			callback.Call (codeID, -1);
			Debug.LogError ("[AD] It's not find ad:" + codeID);
		}
		else
		{
			unit.Play (callback);
		}
	}

	public void ClearAD(string codeID) {
		// if (adNative == null)
		// 	return;
		
		Unit unit = Find (codeID, true);
		if (unit != null)
			unit.Dispose ();
	}

	public void ClearAllAD() {
		// if (adNative == null)
		// 	return;

		for (int idx = 0; idx < adList.Count; idx++)
		{
			adList [idx].Dispose ();
		}
		adList.Clear ();
	}

	public void AddRewardVideoAdListener (LuaFunction RewardVideoAdListener,
											LuaFunction OnError,
											LuaFunction OnRewardVideoAdLoad,
											LuaFunction OnRewardVideoCached)
	{
		rewardVideoAdListenerCallback = RewardVideoAdListener;
		onErrorCallback = OnError;
		onRewardVideoAdLoadCallback = OnRewardVideoAdLoad;
		onRewardVideoCachedCallback = OnRewardVideoCached;
	}

	public void RemoveRewardVideoAdListener(){
		rewardVideoAdListenerCallback = null;
		onErrorCallback = null;
		onRewardVideoAdLoadCallback = null;
		onRewardVideoCachedCallback = null;
	}

	public void AddRewardAdInteractionListener(LuaFunction RewardAdInteractionListener,
												LuaFunction OnAdShowCallback,
												LuaFunction OnAdVideoBarClickCallback, 
												LuaFunction OnAdCloseCallback, 
												LuaFunction OnVideoCompleteCallback,
												LuaFunction OnVideoErrorCallback,
												LuaFunction OnRewardVerifyCallback)
	{
		rewardAdInteractionListenerCallback = RewardAdInteractionListener;
		onAdShowCallback = OnAdShowCallback;
		onAdVideoBarClickCallback = OnAdVideoBarClickCallback;
		onAdCloseCallback = OnAdCloseCallback;
		onVideoCompleteCallback = OnVideoCompleteCallback;
		onVideoErrorCallback = OnVideoErrorCallback;
		onRewardVerifyCallback = OnRewardVerifyCallback;
	}
	
	public void RemoveRewardAdInteractionListener(){
		rewardAdInteractionListenerCallback = null;
		onAdShowCallback = null;
		onAdVideoBarClickCallback = null;
		onAdCloseCallback = null;
		onVideoCompleteCallback = null;
		onVideoErrorCallback = null;
		onRewardVerifyCallback = null;
	}

    public void AddExpressAdListener(LuaFunction ExpressAdListener,
                                        LuaFunction OnError,
                                        LuaFunction OnExpressAdLoad,
                                        LuaFunction OnExpressBannerAdLoad,
                                        LuaFunction OnExpressInterstitialAdLoad)
    {
        expressAdListenerCallback = ExpressAdListener;
        onErrorCallback = OnError;
        onExpressAdLoadCallBack = OnExpressAdLoad;
#if UNITY_IOS
		onExpressBannerAdLoadCallBack = OnExpressBannerAdLoad;
		onExpressInterstitialAdLoadCallBack = OnExpressInterstitialAdLoad;
#endif
    }

    public void RemoveExpressAdExpressListener()
    {
        expressAdListenerCallback = null;
        onErrorCallback = null;
        onExpressAdLoadCallBack = null;
#if UNITY_IOS
		onExpressBannerAdLoadCallBack = null;
		onExpressInterstitialAdLoadCallBack = null;
#endif
    }

	public void AddExpressAdInteractionListener(LuaFunction ExpressAdInteractionListener,
												LuaFunction OnExpressAdClicked,
												LuaFunction OnExpressAdShow, 
												LuaFunction OnExpressAdRenderError, 
												LuaFunction OnExpressAdRenderSucc,
												LuaFunction OnExpressAdClose)
	{
		onExpressAdInteractionListenerCallback = ExpressAdInteractionListener;
		onExpressAdClickedCallback = OnExpressAdClicked;
		onExpressAdShowCallback = OnExpressAdShow;
		onExpressAdRenderErrorCallback = OnExpressAdRenderError;
		onExpressAdRenderSuccCallback = OnExpressAdRenderSucc;
		onExpressAdCloseCallback = OnExpressAdClose;
	}
	 public void RemoveExpressAdInteractionListener()
    {
      	onExpressAdInteractionListenerCallback = null;
		onExpressAdClickedCallback = null;
		onExpressAdShowCallback = null;
		onExpressAdRenderErrorCallback = null;
		onExpressAdRenderSuccCallback = null;
		onExpressAdCloseCallback = null;
    }
}
