package com.huawei.my;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.huawei.hmf.tasks.OnCompleteListener;
import com.huawei.hmf.tasks.OnFailureListener;
import com.huawei.hmf.tasks.OnSuccessListener;
import com.huawei.hmf.tasks.Task;
import com.huawei.hms.api.HuaweiApiClient;
import com.huawei.hms.api.HuaweiMobileServicesUtil;
import com.huawei.hms.common.ApiException;
import com.huawei.hms.iap.Iap;
import com.huawei.hms.iap.IapApiException;
import com.huawei.hms.iap.IapClient;
import com.huawei.hms.iap.entity.ConsumeOwnedPurchaseReq;
import com.huawei.hms.iap.entity.ConsumeOwnedPurchaseResult;
import com.huawei.hms.iap.entity.InAppPurchaseData;
import com.huawei.hms.iap.entity.IsEnvReadyResult;
import com.huawei.hms.iap.entity.OrderStatusCode;
import com.huawei.hms.iap.entity.OwnedPurchasesReq;
import com.huawei.hms.iap.entity.OwnedPurchasesResult;
import com.huawei.hms.iap.entity.PurchaseIntentResult;
import com.huawei.hms.iap.entity.PurchaseResultInfo;
import com.huawei.hms.jos.AppUpdateClient;
import com.huawei.hms.jos.JosApps;
import com.huawei.hms.jos.JosAppsClient;
import com.huawei.hms.jos.games.AppPlayerInfo;
import com.huawei.hms.jos.games.Games;
import com.huawei.hms.jos.games.GamesStatusCodes;
import com.huawei.hms.jos.games.PlayersClient;
import com.huawei.hms.jos.games.player.Player;
import com.huawei.hms.jos.games.player.PlayerExtraInfo;
import com.huawei.hms.jos.games.player.PlayersClientImpl;
import com.huawei.hms.jos.product.ProductClient;
import com.huawei.hms.jos.product.ProductOrderInfo;
import com.huawei.hms.support.api.client.PendingResult;
import com.huawei.hms.support.api.client.ResultCallback;
import com.huawei.hms.support.api.client.Status;
import com.huawei.hms.support.api.entity.core.CommonCode;
import com.huawei.hms.support.api.entity.game.GameStatusCodes;
import com.huawei.hms.support.api.entity.game.GameUserData;
import com.huawei.hms.support.api.game.CertificateIntentResult;
import com.huawei.hms.support.api.game.GameLoginHandler;
import com.huawei.hms.support.api.game.GameLoginResult;
import com.huawei.hms.support.api.game.HardwareCapabilityResult;
import com.huawei.hms.support.api.game.HuaweiGame;
import com.huawei.hms.support.api.game.PlayerCertificationInfo;
import com.huawei.hms.support.api.game.TemperatureResult;
import com.huawei.hms.support.hwid.HuaweiIdAuthManager;
import com.huawei.hms.support.hwid.request.HuaweiIdAuthParams;
import com.huawei.hms.support.hwid.request.HuaweiIdAuthParamsHelper;
import com.huawei.hms.support.hwid.result.AuthHuaweiId;
import com.huawei.hms.support.hwid.result.HuaweiIdAuthResult;
import com.huawei.hms.support.hwid.service.HuaweiIdAuthService;
import com.huawei.updatesdk.service.appmgr.bean.ApkUpgradeInfo;
import com.huawei.updatesdk.service.otaupdate.CheckUpdateCallBack;
import com.huawei.my.*;

import com.huawei.updatesdk.service.otaupdate.UpdateKey;
import com.wqpddz.huawei.UnityPlayerActivity;
import com.wqpddz.huawei.Util;

import java.io.Serializable;
import java.security.SecureRandom;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.view.WindowManager;
import android.widget.Spinner;

import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.unity3d.player.UnityPlayer;

import org.json.JSONException;
import org.json.JSONObject;

//import com.bytedance.sdk.openadsdk.TTAdConfig;
//import com.bytedance.sdk.openadsdk.TTAdConstant;
//import com.bytedance.sdk.openadsdk.TTAdSdk;

import androidx.annotation.Nullable;

public class SDKController {
    private final  String APPID = "101752773";
    private final String CPID = "70086000192742361";
    private final String PayPrivateKey= "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC9WZCAuapoNdLfxWw+acBneJgV/b/wDaab369SoXoV0nONcs30H249BquoSMhig8EdMZY3gD/OUj19UouHLXtNLyJxdqpQiOlZfl7Df9j9YDagpB1TRTp7JLLbvhqDXStNeBHjNaC8C2Xaw+jDx3pkmgcpB3SOEJMwRbbhlywSu4bHYSbnO5yhOkp6huQ8AkSQp7tZdSjuUVENM5wuUc4pTNzd8h7AINyIzPa/iHWM63ZdZlD4eIUrh4h4nfq+BSQt76kgJBWw9Cco2QtWeP6xr+YbhDYBmubLmpy+JFb9zDxNQHgSdbHUoIcPglurdpfYZzncV8tyrUsX0FSnVlGLAgMBAAECggEAHPW/X6jF8uVUiMwRp6QV/N1ZaXejbQwxcMKv9nPjD8ZdzQMDk/RgsG2+QGFNYJ/lH9lvL7LqT1yNsga3d2fR5XaxjmgHWYTvJ7Rnuv/pSKt3/27KW2uJq77rqiczt+a+kj0sgzM3D7uwitqO1a7DPfK+6JwOzBGl6WqoM22jHIQVW5a+1BrMDsw53woQ8Em0in0DKDRygYyjaTT4Xt6EfYg5OiQW6m5CJE2ASg8hI2SLKWjbF0zvSYFM3DJzM7m1CqRk/1yhPrNbC78oJ4QGEB3SKeNyjnmtJJw34CuJjdagRlSSWBXyihU8/3yaLE5yUeGLPs7cZdqZfS+sXCj2yQKBgQDv0Eo/8948A8D5pubox8vbloOKaCE1uMzDqp72our9jIEupqV0EDyeoBUNzpRxwFF8J4dC1XyMJJiD9GX8r1k2bvSDfnbUh91zU2m/zIS0XzE//gG3B4lUGUtdxWU2APKsBHoZ9wy/7J3lsr+Uw+TCFSlnT8UE8zRNKHQSAQCOOQKBgQDKIVEzAzWH5+2vMKsunUBp0KM155gzQ27yTCjaapku7ixeR4JgOYjr+akYKcGUw3qjcIX/ToQ58EB+Xif+gzZ9MfazEL8013+nGXSPD+twTzP5wNxSTzNB2uvyZ9kFSvJPGDbq+ARQcRbKxQm8WJtIFYJeWJI72UIso+yFkZnd4wKBgQCFai+knJuKb9wwB7Z20pCLPZU4ru2q4YCpaoa9V628GSrVNUje5RmUdiLAZ6kWD5RFqggKGpMLtGBVKOaESVkse1X0waqCWoPM4R734WQCpOLVYw65MKwp6ViQdnz0KlrXcDYts8+YBp9hZqxGqyTdBMDgBPTq6BK0ykioq34PoQKBgFXLKHT3krwZ1Ef851vEwTdoqC3UHET+BVRwwRJcFqLV0x09Svhe02AduwkXiCQFiMNgmm+QOw2AjU9V1bHwrascDvNYU2Axa+xYIKIshqlH5O7ITnvdRAtaybU9IN9fPVQXGhBHr0UZiywL0CMSlO5Wutwiygb/I1hhR541+9IzAoGBAOEz8mIBbEevW/Aah9MtkcnJMRXsz6GnrlTrfDkkPCMMJm3BiosTPdicJ/r/Ud8x/YE3Dl8vEkk+qKEY2RvQUOgt7YsvIOJCQjTiiYGeH8ZHhnV7c3h/Mmi3TZ3qCadWaqeFkGbVwPdJUGDRrKsYwb3sPaJSer8XCC239FMLL8xR";
    private final String PayPublicKey= "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvVmQgLmqaDXS38VsPmnAZ3iYFf2/8A2mm9+vUqF6FdJzjXLN9B9uPQarqEjIYoPBHTGWN4A/zlI9fVKLhy17TS8icXaqUIjpWX5ew3/Y/WA2oKQdU0U6eySy274ag10rTXgR4zWgvAtl2sPow8d6ZJoHKQd0jhCTMEW24ZcsEruGx2Em5zucoTpKeobkPAJEkKe7WXUo7lFRDTOcLlHOKUzc3fIewCDciMz2v4h1jOt2XWZQ+HiFK4eIeJ36vgUkLe+pICQVsPQnKNkLVnj+sa/mG4Q2AZrmy5qcviRW/cw8TUB4EnWx1KCHD4Jbq3aX2Gc53FfLcq1LF9BUp1ZRiwIDAQAB";

    private final String WXID = "wxa67208ed9db78f10";
    public String getWXID() { return WXID; }
    private IWXAPI api;
    public void RegisterWeChat(Context context) {
        api = WXAPIFactory.createWXAPI(context,WXID);
        boolean issuccess =  api.registerApp(WXID);
        if (issuccess)
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] RegisterWeChat OK:" + WXID);
        else
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] RegisterWeChat Fail:" + WXID);
    }

    private SDKController(){};

    private boolean m_isLogining = false;
    public boolean isLogining() { return m_isLogining; }
    public void markLogining(boolean value) { m_isLogining = value; }

	private boolean m_isRelogin = false;
    public boolean isRelogin() { return m_isRelogin; }
    public void markRelogin(boolean value) { m_isRelogin = value; }

    private boolean m_hasInit = false;
    private HuaweiIdAuthService m_hwService;
    private Handler handler;
    private int m_isAdault;
    private String playerId;
    private String sessionId = null;
    private final static int HEARTBEAT_TIME = 15 * 60 * 1000;

    private Player m_player;

    private final static int SIGN_IN_INTENT = 3000;
    private final static int CERTIFICATION_IN_INTENT = 3001;
    private final static int PAY_INTENT = 3002;
    private final static int PAY_PROTOCOL_INTENT = 3003;

    private String m_productId;
    private String m_productName;
    private String m_amount;
    private int m_priceType;
    private String m_developerPayload;

    private boolean m_needCertification = true;
    public boolean needCertification() {return m_needCertification;}

    public void SendLoginResult(int isAdault) {
        if(m_player == null)
            SimpleFeedback("LoginResult", -5, -1);
        else {
            try {
                JSONObject jsonResult = new JSONObject();
                jsonResult.put("result", 0);

                jsonResult.put("playerId", m_player.getPlayerId());
                jsonResult.put("playerLevel", m_player.getLevel());
                jsonResult.put("playerSSign", m_player.getPlayerSign());
                jsonResult.put("ts", m_player.getSignTs());
                jsonResult.put("appid", APPID);
                jsonResult.put("isAdault", isAdault);

                UnityPlayer.UnitySendMessage("SDK_callback", "LoginResult", jsonResult.toString());
            } catch (Exception e) {
                SimpleFeedback("LoginResult", -1, 0);
            }
        }
    }

    private UnityPlayerActivity mainActivity;
    private static SDKController _instance;
    public static SDKController GetInstance(){
        if(_instance == null)
        {
            _instance = new SDKController();
        }
        return _instance;
    }

    public void SimpleFeedback(String callback, int result, int errno) {
        try {
            JSONObject jsonResult = new JSONObject();
            jsonResult.put("result", result);
            jsonResult.put("errno", errno);

            UnityPlayer.UnitySendMessage("SDK_callback", callback, jsonResult.toString());
        } catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] SimpleFeedback " + callback + " exception:" + e.getMessage());
        }
    }

    public void HandleInit(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleInit exception:" + e.getMessage());
        }
        SimpleFeedback("InitResult", result, 0);
    }

    public void HandleLogin(String json_data) {
        try {
            m_needCertification = true;
            JSONObject jsonObject = new JSONObject(json_data);
            m_needCertification = jsonObject.getBoolean("needCertification");
        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleLogin No Certification!" + e.getMessage());
        }

        markLogining(true);
		markRelogin(false);
		signIn();
    }
    public void HandleLoginOut(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);
            if(m_hwService != null) {
                Task<Void> signOutTask = m_hwService.signOut();
                signOutTask.addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(Task<Void> task) {
                        //完成登出后的处理
                    }
                });
            }
        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleLoginOut exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "LoginOutResult", String.format("{result:%d}", result));
    }
	public void HandleRelogin(String json_data) {
        markLogining(true);
		markRelogin(true);
        m_needCertification = false;
        signIn();
    }
    public void HandlePay(String json_data)
    {
        try {
            JSONObject jsonObject = new JSONObject(json_data);

            String productId = jsonObject.getString("productId");
            String productName = jsonObject.getString("productName");
            String amount = jsonObject.getString("amount");
            int priceType = jsonObject.getInt("priceType");
            String developerPayload = jsonObject.getString("developerPayload");

            this.m_productId = productId;
            this.m_productName = productName;
            this.m_amount = amount;
            this.m_priceType = priceType;
            this.m_developerPayload = developerPayload;

            paying();
        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandlePay exception:" + e.getMessage());
        }
    }
    public void HandlePostPay(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            String in_app_purchase_data = jsonObject.getString("in_app_purchase_data");
            PostPay(in_app_purchase_data);
        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandlePostPay exception:" + e.getMessage());
        }
        if(result < 0)
            SimpleFeedback("PostPayResult", result, 0);
    }
    public void HandleShare(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            int shareType = jsonObject.getInt("type");
            switch (shareType) {
                case Type.WeiChatInterfaceType_ShareUrl:
                    result = ShareLinkUrl(jsonObject);
                    break;
                case Type.WeiChatInterfaceType_ShareImage:
                    result = ShareImage(jsonObject);
                    break;
                default:
                    result = -6;
                    break;
            }

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleShare exception:" + e.getMessage());
        }

        if(result != 0)
            UnityPlayer.UnitySendMessage("SDK_callback", "ShareResult", String.format("{result:%d}", result));
    }
    public void HandleShowAccountCenter(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleShowAccountCenter exception:" + e.getMessage());
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "ShowAccountCenterResult", String.format("{result:%d}", result));
    }

    public void HandleSetupAD(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);

            String appId = jsonObject.getString("appId");
            String appName = jsonObject.getString("appName");
            boolean isDebug = jsonObject.getBoolean("isDebug");

            /*TTAdConfig config = new TTAdConfig.Builder()
                    .appId(appId)
                    .appName(appName)
                    .debug(isDebug)
                    .useTextureView(false)
                    .allowShowNotify(true)
                    .allowShowPageWhenScreenLock(true)
                    .directDownloadNetworkType(TTAdConstant.NETWORK_STATE_WIFI, TTAdConstant.NETWORK_STATE_3G)
                    .supportMultiProcess(false)
                    .titleBarTheme(TTAdConstant.TITLE_BAR_THEME_DARK)
                    .build();
            TTAdSdk.init(mainActivity, config);*/

            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleSetupAD setup not implement:" + appId);
        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleSetupAD exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "HandleSetupADResult", String.format("{result:%d}", result));
    }

    public void onAppCreate(Application application) {
        HuaweiMobileServicesUtil.setApplication(application);
    }
    public void onAppDestroy() {

    }
    public void onActivityCreate(UnityPlayerActivity activity) {
        mainActivity = activity;

        RegisterWeChat(activity);

        initHW();
    }
    public void onActivityDestroy() {
    }
    
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (SIGN_IN_INTENT == requestCode) {
            handleSignInResult(data);
        } else if(CERTIFICATION_IN_INTENT == requestCode) {
            getCertificateInfo();
        } else if (PAY_INTENT == requestCode) {
            handlePayResult(data);
        } else if(PAY_PROTOCOL_INTENT == requestCode) {
            paying();
        } else {
            //showLog("unknown requestCode in onActivityResult");
        }
    }

    public void onResume() {
        showFloatWindow();
    }

    public void onPause() {
        hideFloatWindow();
    }

    public void onStart() {
        if(m_isAdault == 0)
            gameBegin();
    }
    public void onStop() {
        if(m_isAdault == 0)
            gameOver();
    }

    public void onResp(BaseResp resp) {
        try {
            JSONObject jsonResult = null;
            switch (resp.transaction) {
                case Transaction.ShareImage:
                case Transaction.ShareUrl:
                    jsonResult = new JSONObject();
                    if(resp.errCode == 0) {
                        jsonResult.put("result", 0);
                    } else {
                        jsonResult.put("result", -5);
                        jsonResult.put("errno", resp.errCode);
                    }
                    UnityPlayer.UnitySendMessage("SDK_callback", "ShareResult", jsonResult.toString());

                    break;
            }
        }catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] onResp exception:" + e.getMessage());
        }
    }

    private void initHW() {
        JosAppsClient appsClient = JosApps.getJosAppsClient(mainActivity, null);
        appsClient.init();
        m_hasInit = true;

        checkUpdate();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    private void checkUpdate() {
        UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] check update...");

        AppUpdateClient client = JosApps.getAppUpdateClient(mainActivity);
        client.checkAppUpdate(mainActivity, new UpdateCallBack());
    }
    public void showUpdateDlg(ApkUpgradeInfo info) {
        UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] check update ok:" + info.toString());

        AppUpdateClient client = JosApps.getAppUpdateClient(mainActivity);
        client.showUpdateDialog(mainActivity, info, false);
    }
    private static class UpdateCallBack implements CheckUpdateCallBack {
        private UpdateCallBack() {}
        public void onUpdateInfo(Intent intent) {
            if (intent != null) {
                Serializable info = intent.getSerializableExtra("updatesdk_update_info");
                if (info instanceof ApkUpgradeInfo) {
                    SDKController.GetInstance().showUpdateDlg((ApkUpgradeInfo)info);
                } else {
                    int status = intent.getIntExtra(UpdateKey.STATUS, 0);
                    int retcode = intent.getIntExtra(UpdateKey.FAIL_CODE, 0);
                    String retmsg = intent.getStringExtra(UpdateKey.FAIL_REASON);

                    UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] check update failed(status:" + status + ", retcode:" + retcode + ", retmsg:" + retmsg);
                }
            }
        }

        public void onMarketInstallInfo(Intent intent) {
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] check update failed: not instance of ApkUpgradeInfo");
        }

        public void onMarketStoreError(int responseCode) {
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] check update failed MarketStore error:" + responseCode);
        }

        public void onUpdateStoreError(int responseCode) {
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] check update failed UpdateStore error:" + responseCode);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    public void showFloatWindow() {
        if(!m_hasInit)
            initHW();
        Games.getBuoyClient(mainActivity).showFloatWindow();
    }
    public void hideFloatWindow() {
        Games.getBuoyClient(mainActivity).hideFloatWindow();
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////

    public HuaweiIdAuthParams getHuaweiIdParams() {
        return new HuaweiIdAuthParamsHelper(HuaweiIdAuthParams.DEFAULT_AUTH_REQUEST_PARAM_GAME).createParams();
    }
    private void gameBegin() {
        if (TextUtils.isEmpty(playerId)) {
            return;
        }
        String uid = UUID.randomUUID().toString();
        PlayersClient client = Games.getPlayersClient(mainActivity, SignInCenter.get().getAuthHuaweiId());
        Task<String> task = client.submitPlayerEvent(playerId, uid, "GAMEBEGIN");
        task.addOnSuccessListener(new OnSuccessListener<String>() {
            @Override
            public void onSuccess(String jsonRequest) {
                if (jsonRequest == null) {
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] gameBegin failed: jsonRequest is invalid");
                    return;
                }
                try {
                    JSONObject data = new JSONObject(jsonRequest);
                    sessionId = data.getString("transactionId");
                } catch (JSONException e) {
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] gameBegin failed, json data exception:" + jsonRequest);
                    return;
                }
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof ApiException) {
                    String result = "rtnCode:" + ((ApiException) e).getStatusCode();
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] gameBegin failed: " + result);
                }
            }
        });
    }
    private void gameOver() {
        if (TextUtils.isEmpty(playerId)) {
            return;
        }
        if (TextUtils.isEmpty(sessionId)) {
            return;
        }
        PlayersClient client = Games.getPlayersClient(mainActivity, SignInCenter.get().getAuthHuaweiId());
        Task<String> task = client.submitPlayerEvent(playerId, sessionId, "GAMEEND");
        task.addOnSuccessListener(new OnSuccessListener<String>() {
            @Override
            public void onSuccess(String s) {
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof ApiException) {
                    String result = "rtnCode:" + ((ApiException) e).getStatusCode();
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] gameOver failed: " + result);
                }
            }
        });
    }

    private void signIn() {
        m_hwService = HuaweiIdAuthManager.getService(mainActivity, getHuaweiIdParams());
        Task<AuthHuaweiId> authHuaweiIdTask = m_hwService.silentSignIn();
        authHuaweiIdTask.addOnSuccessListener(new OnSuccessListener<AuthHuaweiId>() {
            @Override
            public void onSuccess(AuthHuaweiId authHuaweiId) {
                markLogining(false);
                SignInCenter.get().updateAuthHuaweiId(authHuaweiId);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof ApiException) {
                    ApiException apiException = (ApiException) e;
                    m_hwService = HuaweiIdAuthManager.getService(mainActivity, getHuaweiIdParams());
                    Intent intent = m_hwService.getSignInIntent();
                    mainActivity.startActivityForResult(intent, SIGN_IN_INTENT);
                }
            }
        });
    }
    private void handleSignInResult(Intent data) {
        markLogining(false);

        if (null == data) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] handleSignInResult failed: data is invalid");
            return;
        }

        String jsonSignInResult = data.getStringExtra("HUAWEIID_SIGNIN_RESULT");
        if (TextUtils.isEmpty(jsonSignInResult)) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] handleSignInResult failed: signin result is empty");
            return;
        }
        try {
            HuaweiIdAuthResult
                    signInResult = new HuaweiIdAuthResult
                    ().fromJson(jsonSignInResult);
            if (0 == signInResult.getStatus().getStatusCode()) {
                SignInCenter.get().updateAuthHuaweiId(signInResult.getHuaweiId());
            } else {
                if(isRelogin())
                    SimpleFeedback("ReloginResult", -5, signInResult.getStatus().getStatusCode());
                else
                    SimpleFeedback("LoginResult", -5, signInResult.getStatus().getStatusCode());
            }
        } catch (JSONException var7) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] handleSignInResult exception: " + var7.getMessage());
        }
    }

    public void getCurrentPlayer(int isAdault) {
        PlayersClientImpl client = (PlayersClientImpl) Games.getPlayersClient(mainActivity, SignInCenter.get().getAuthHuaweiId());

        Task<Player> task = client.getCurrentPlayer();
        task.addOnSuccessListener(new OnSuccessListener<Player>() {
            @Override
            public void onSuccess(Player player) {
                m_player = player;
                String result = "display:" + player.getDisplayName() + "\n" + "playerId:" + player.getPlayerId() + "\n" + "playerLevel:"
                        + player.getLevel() + "\n" + "timestamp:" + player.getSignTs()
                        + "\n" + "playerSign:" + player.getPlayerSign();
                playerId = player.getPlayerId();
                SendLoginResult(isAdault);
                m_isAdault = isAdault;
                if(isAdault == 0) {
                    gameBegin();

                    handler = new Handler() {
                        @Override
                        public void handleMessage(Message msg) {
                            super.handleMessage(msg);
                            gamePlayExtra();
                        }
                    };
                    new Timer().schedule(new TimerTask() {
                        @Override
                        public void run() {
                            Message message = new Message();
                            handler.sendMessage(message);
                        }
                    }, HEARTBEAT_TIME, HEARTBEAT_TIME);
                }

                checkLegacyOrders();
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof ApiException) {
                    String result = "rtnCode:" + ((ApiException) e).getStatusCode();
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] getCurrentPlayer failed: " + result);
                }
            }
        });
    }

    private void gamePlayExtra() {
        if (TextUtils.isEmpty(playerId)) {
            return;
        }
        PlayersClient client = Games.getPlayersClient(mainActivity, SignInCenter.get().getAuthHuaweiId());
        Task<PlayerExtraInfo> task = client.getPlayerExtraInfo(sessionId);
        task.addOnSuccessListener(new OnSuccessListener<PlayerExtraInfo>() {
            @Override
            public void onSuccess(PlayerExtraInfo extra) {
                if (extra != null) {
                    String result ="IsRealName: " + extra.getIsRealName() + ", IsAdult: " + extra.getIsAdult() + ", PlayerId: " + extra.getPlayerId() + ", PlayerDuration: " + extra.getPlayerDuration();
                    UnityPlayer.UnitySendMessage("SDK_callback", "Log", "[SDK] gamePlayExtra ok:" + result);
                    //todo
                } else {
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] gamePlayExtra exception: extra is invalid");
                }
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof ApiException) {
                    String result = "rtnCode:" + ((ApiException) e).getStatusCode();
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] gamePlayExtra failed: " + result);
                }
            }
        });
    }

    public void getCertificateInfo() {
        ConnectClientSupport.get().connect(mainActivity, new ConnectClientSupport.IConnectCallBack() {
            @Override
            public void onResult(HuaweiApiClient apiClient) {
                if (apiClient != null) {
                    PendingResult<PlayerCertificationInfo> pendingRst =
                            HuaweiGame.HuaweiGameApi.getPlayerCertificationInfo(apiClient);
                    pendingRst.setResultCallback(new ResultCallback<PlayerCertificationInfo>() {
                        @Override
                        public void onResult(PlayerCertificationInfo result) {
                            if (result == null || result.getStatus() == null) {
                                Log.i("[SDK]", "[HW] getCertificationInfo result invalid!");
                                return;
                            }
                            Status status = result.getStatus();
                            int rstCode = status.getStatusCode();
                            if (rstCode == GameStatusCodes.GAME_STATE_SUCCESS) {
                                int code = result.hasAdault();
                                if(code == 0 || code == 1)
                                    getCurrentPlayer(code);
                                else
                                    getCertificateIntent();
                            } else {
                                SimpleFeedback("LoginResult", -5, -2);
                                Log.i("[SDK]", "[HW] getCertificationInfo ok, but:" + rstCode);
                            }
                        }
                    });
                }
            }
        });
    }

    public void getCertificateIntent() {
        ConnectClientSupport.get().connect(mainActivity, new ConnectClientSupport.IConnectCallBack() {
            @Override
            public void onResult(HuaweiApiClient apiClient) {
                if (apiClient != null) {
                    PendingResult<CertificateIntentResult> pendingRst = HuaweiGame.HuaweiGameApi.getPlayerCertificationIntent(apiClient);
                    pendingRst.setResultCallback(new ResultCallback<CertificateIntentResult>() {
                        @Override
                        public void onResult(CertificateIntentResult result) {
                            if (result == null || result.getStatus() == null) {
                                //showLog("result is null");
                                return;
                            }
                            int rstCode = result.getStatus().getStatusCode();
                            if (rstCode == CommonCode.OK) {
                                Intent intent = result.getCertificationIntent();
                                if (intent != null) {
                                    mainActivity.startActivityForResult(intent, CERTIFICATION_IN_INTENT);
                                }
                            } else {
                                SimpleFeedback("LoginResult", -5, rstCode);
                                Log.i("[SDK]", "[HW] getCertificateIntent ok, but:" + rstCode);
                            }
                        }
                    });
                }
            }
        });
    }

    private void startActivityForResult(Activity activity, Status status, int reqCode) {
        if (status.hasResolution()) {
            try {
                status.startResolutionForResult(activity, reqCode);
            } catch (IntentSender.SendIntentException exp) {
                UnityPlayer.UnitySendMessage("SDK_callback", "PayResult", String.format("{result:%d}", -1));
            }
        }
    }

    public void dealIAPFailed(int statusCode, Status status) {
        if (statusCode == OrderStatusCode.ORDER_NOT_ACCEPT_AGREEMENT) {
            startActivityForResult(mainActivity, status, PAY_PROTOCOL_INTENT);
        } else {
            if(statusCode == OrderStatusCode.ORDER_PRODUCT_OWNED) {
                checkLegacyOrders();
            } else {
                UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: dealIAPFailed Failed:" + statusCode + " : " + status.getErrorString());
                SendPayResult(String.format("{\"developerPayload\":\"%s\"}", m_developerPayload), "", false, -1, statusCode);
            }
        }
    }
    public void dealSuccess(PurchaseIntentResult result, Activity activity) {
        if (result == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: dealSuccess but result is null");
            return;
        }
        Status status = result.getStatus();
        if (status.getResolution() == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: dealSuccess but resolution is null");
            return;
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "Log", "[PAY] tracepay: dealSuccess paydata:" +result.getPaymentData() +", signature:" + result.getPaymentSignature());

        if (result.getPaymentSignature() != null && result.getPaymentData() != null) {
            // check sign
            boolean success = IAPSupport.doCheck(result.getPaymentData(), result.getPaymentSignature());
            if (success) {
                startActivityForResult(activity, status, PAY_INTENT);
            } else {
                UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: dealSuccess but check sign failed");
                SendPayResult(String.format("{\"developerPayload\":\"%s\"}", m_developerPayload), "", false, -1, -2);
            }
        }
    }

    private void paying() {
        Log.i("[SDK]", "[PAY] tracepay: begin");

        IapClient mClient = Iap.getIapClient(mainActivity);
        Task<PurchaseIntentResult> task = mClient.createPurchaseIntentWithPrice(IAPSupport.createGetBuyIntentWithPriceReq(m_productId, m_productName, m_amount, m_priceType, m_developerPayload));
        task.addOnSuccessListener(new OnSuccessListener<PurchaseIntentResult>() {
            @Override
            public void onSuccess(PurchaseIntentResult result) {
                dealSuccess(result, mainActivity);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof IapApiException) {
                    int statusCode = ((ApiException) e).getStatusCode();
                    dealIAPFailed(statusCode, ((IapApiException) e).getStatus());
                }
            }
        });
    }

    private void SendPayResult(String purchaseData, String iapSignature, boolean isLegacy, int result, int errno) {
        try {
            if(purchaseData == null)
                purchaseData = String.format("{\"developerPayload\":\"%s\"}", m_developerPayload);
            JSONObject jsonResult = new JSONObject();
            jsonResult.put("result", result);
            jsonResult.put("errno", errno);
            jsonResult.put("in_app_purchase_data", purchaseData);
            jsonResult.put("signature", iapSignature);
            jsonResult.put("isLegacy", isLegacy);
            UnityPlayer.UnitySendMessage("SDK_callback", "PayResult", jsonResult.toString());
        } catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] SendPayResult exception:" + e.getMessage());
        }
    }
    private static boolean debugPayFailed = false;
    private void handlePayResult(Intent data) {
        PurchaseResultInfo purchaseResultInfo = Iap.getIapClient(mainActivity).parsePurchaseResultInfoFromIntent(data);
        if (!debugPayFailed && purchaseResultInfo != null) {
            int iapRtnCode = purchaseResultInfo.getReturnCode();
            String purchaseData = purchaseResultInfo.getInAppPurchaseData();
            String iapSignature = purchaseResultInfo.getInAppDataSignature();
            SendPayResult(purchaseData, iapSignature, false, 0, iapRtnCode);
        } else {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: handlePayResult purchaseResultInfo is invalid");
            SendPayResult(String.format("{\"developerPayload\":\"%s\"}", m_developerPayload), "", false, -1, -3);
        }

        Log.i("[SDK]", "[HW] pay: end");
    }

    private void PostPay(String purchaseData) {
        String purchaseToken = "";
        try {
            InAppPurchaseData inAppPurchaseDataBean = new InAppPurchaseData(purchaseData);
            purchaseToken = inAppPurchaseDataBean.getPurchaseToken();
        } catch (JSONException e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: PostPay InAppPurchaseData exception:" +e.getMessage());
            SimpleFeedback("PostPayResult", -1, -5);
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "Log", "[PAY] tracepay: PostPay token:" + purchaseToken);

        ConsumeOwnedPurchaseReq req = new ConsumeOwnedPurchaseReq();
        req.setPurchaseToken(purchaseToken);

        Task<ConsumeOwnedPurchaseResult> task = Iap.getIapClient(mainActivity).consumeOwnedPurchase(req);
        task.addOnSuccessListener(new OnSuccessListener<ConsumeOwnedPurchaseResult>() {
            @Override
            public void onSuccess(ConsumeOwnedPurchaseResult result) {
                // Obtain the result
                SimpleFeedback("PostPayResult", 0, 0);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof IapApiException) {
                    IapApiException apiException = (IapApiException)e;
                    Status status = apiException.getStatus();
                    int returnCode = apiException.getStatusCode();

                    SimpleFeedback("PostPayResult", -1, returnCode);
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: PostPay consumeOwnedPurchase iapAPIexception:" + returnCode + ", " + status.getErrorString());
                } else {
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: PostPay consumeOwnedPurchase exception:" + e.getMessage());
                }
            }
        });
    }

    private void checkLegacyOrders() {
        OwnedPurchasesReq ownedPurchasesReq = new OwnedPurchasesReq();
        ownedPurchasesReq.setPriceType(0);
        Task<OwnedPurchasesResult> task = Iap.getIapClient(mainActivity).obtainOwnedPurchases(ownedPurchasesReq);
        task.addOnSuccessListener(new OnSuccessListener<OwnedPurchasesResult>() {
            @Override
            public void onSuccess(OwnedPurchasesResult result) {
                // Obtain the execution result.
                if (result != null && result.getInAppPurchaseDataList() != null) {
                    for (int i = 0; i < result.getInAppPurchaseDataList().size(); i++) {
                        String inAppPurchaseData = result.getInAppPurchaseDataList().get(i);
                        String InAppSignature = result.getInAppSignature().get(i);

                        SendPayResult(inAppPurchaseData, InAppSignature, true, 0, 0);
                    }
                }
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof IapApiException) {
                    IapApiException apiException = (IapApiException)e;
                    Status status = apiException.getStatus();
                    int returnCode = apiException.getStatusCode();

                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: checkLegacyOrders iapAPIexception:" + returnCode + ", " +status.getErrorString());
                } else {
                    UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[PAY] tracepay: checkLegacyOrders exception:" + e.getMessage());
                }
            }
        });
    }

    /*private void loginGame() {
        ConnectClientSupport.get().connect(mainActivity, new ConnectClientSupport.IConnectCallBack() {
            @Override
            public void onResult(HuaweiApiClient apiClient) {
                if (apiClient != null) {
                    PendingResult<GameLoginResult> pendingRst = HuaweiGame.HuaweiGameApi.login(apiClient, mainActivity, 1, new GameLoginHandler() {
                        @Override
                        public void onResult(int retCode, GameUserData userData) {
                            markLogining(false);

                            if (retCode == GamesStatusCodes.GAME_STATE_SUCCESS && userData != null) {
                                if(userData.getIsAuth() == 1) {
                                    m_gameUserData = userData;
                                    if(m_needCertification)
                                        ;//getCertificationInfo();
                                    else
                                        SendLoginResult(1);
                                }
                            } else {
                                SimpleFeedback("LoginResult", -5, retCode);
                                UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleLogin failed:" + retCode);
                            }
                        }

                        @Override
                        public void onChange() {
                            HandleLogin("");
                        }
                    });
                    pendingRst.setResultCallback(new ResultCallback<GameLoginResult>() {
                        @Override
                        public void onResult(GameLoginResult result) {
                        }
                    });
                }
            }
        });
    }*/

    ////////////////////////////////////////////////////////////////////////////////////////////////

    public interface Type {
        int WeiChatInterfaceType_IsWeiChatInstalled = 1; //判断是否安装微信
        int WeiChatInterfaceType_ShareUrl = 3; //分享链接
        int WeiChatInterfaceType_ShareImage = 7;//分享图片
    }
    public interface Transaction {
        String IsWeiChatInstalled = "isInstalled"; //判断是否安装微信
        String ShareUrl = "shareUrl"; //分享链接
        String ShareImage = "shareImage";//分享图片
    }
    public int ShareLinkUrl(JSONObject jsonObject) {
        try {
            String url = jsonObject.getString("url");
            String title = jsonObject.getString("title");
            String description = jsonObject.getString("description");
            String icon = jsonObject.getString("icon");
            boolean isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");

            WXWebpageObject webpage = new WXWebpageObject();
            webpage.webpageUrl = url;
            WXMediaMessage msg = new WXMediaMessage(webpage);
            msg.title = title;
            msg.description = description;
            Resources re = mainActivity.getResources();
            Bitmap bmp = null;
            if(!icon.isEmpty())
                bmp = BitmapFactory.decodeFile(icon);
            if(bmp == null) {
                bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", mainActivity.getPackageName()));
                UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[SDK] ShareLinkUrl Load icon Failed:" + icon);
            }
            if(bmp != null) {
                Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 100, 100, true);
                bmp.recycle();
                msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
            }

            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.transaction = Transaction.ShareUrl;
            req.message = msg;
            req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
            if(!api.sendReq(req))
                return -3;
        }catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] ShareLinkUrl exception:" + e.getMessage());
        }
        return 0;
    }

    public int ShareImage (JSONObject jsonObject) {
        try {
            String imgFile = jsonObject.getString("imgFile");
            boolean isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");

            Resources re = mainActivity.getResources();
            Bitmap bmp = BitmapFactory.decodeFile(imgFile);
            if(bmp == null) {
                UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] ShareLinkUrl Load imgFile failed:" + imgFile);
                return -7;
            }

            WXImageObject imgObj = new WXImageObject(bmp);
            WXMediaMessage msg = new WXMediaMessage();
            msg.mediaObject = imgObj;

            // 设置消息的缩略图
            Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 100, 100, true);
            bmp.recycle();
            msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
            req.transaction = Transaction.ShareImage;
            req.message = msg;
            if(!api.sendReq(req))
                return -3;

            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] ShareImage Environment path:" + Environment.getExternalStorageDirectory().getAbsolutePath());
        }catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] ShareImage exception:" + e.getMessage());
        }

        return 0;
    }
}
