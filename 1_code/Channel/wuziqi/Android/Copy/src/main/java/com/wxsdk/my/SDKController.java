package com.wxsdk.my;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.util.Base64;
import android.widget.Toast;

import com.wuziqi.wzq.UnityPlayerActivity;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.unity3d.player.UnityPlayer;

import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.SoftReference;

import com.bytedance.sdk.openadsdk.TTAdConfig;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdSdk;

/**
 * Created by Administrator on 2016/9/6 0006.
 */
public class SDKController {
    private static SDKController _instance;
    private  SDKController(){};

    private boolean m_isLogining = false;
    public boolean isLogining() { return m_isLogining; }
    public void markLogining(boolean value) { m_isLogining = value; }

	private boolean m_isRelogin = false;
    public boolean isRelogin() { return m_isRelogin; }
    public void markRelogin(boolean value) { m_isRelogin = value; }

    private UnityPlayerActivity mainActivity;
    public static SDKController GetInstance(){
        if(_instance == null)
        {
            _instance = new SDKController();
        }
        return _instance;
    }

    private MiitHelper miitHelper;

    private final String WXID = "wxfbbdf6d20dc91113";
    public String getWXID() { return WXID; }
    private IWXAPI api;
    public void RegisterWeChat(Context context) {
        api = WXAPIFactory.createWXAPI(context, WXID);
        boolean issuccess =  api.registerApp(WXID);
        if (issuccess)
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] RegisterWeChat OK:" + WXID);
        else
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] RegisterWeChat Fail:" + WXID);
    }

    public void HandleInit(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleInit exception:" + e.getMessage());
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "InitResult", String.format("{result:%d}", result));
    }
    public void HandleLogin(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);
            do {
                if(!api.isWXAppInstalled()) {
                    result = -2;
                    break;
                }

                final SendAuth.Req req = new SendAuth.Req();
                req.transaction = Transaction.RequestLogin;
                req.scope = "snsapi_userinfo";
                req.state = "wechat_sdk_demo_test";
                if(!api.sendReq(req)) {
                    result = -3;
                    break;
                }

                markLogining(true);
				markRelogin(false);

                UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleLogin send req");
            }while(false);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleLogin exception:" + e.getMessage());
        }

        if(result != 0)
            UnityPlayer.UnitySendMessage("SDK_callback", "LoginResult", String.format("{result:%d}", result));
    }
    public void HandleLoginOut(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleLoginOut exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "LoginOutResult", String.format("{result:%d}", result));
    }
	public void HandleRelogin(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);
            do {
                if(!api.isWXAppInstalled()) {
                    result = -2;
                    break;
                }

                final SendAuth.Req req = new SendAuth.Req();
                req.transaction = Transaction.RequestLogin;
                req.scope = "snsapi_userinfo";   // 应用授权作用域，如获取用户个人信息则填写snsapi_userinfo
                req.state = "wechat_sdk_demo_test";
                if(!api.sendReq(req)) {
                    result = -3;
                    break;
                }

                markLogining(true);
				markRelogin(true);

                UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleRelogin send req");
            }while(false);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleRelogin exception:" + e.getMessage());
        }

        if(result != 0)
            UnityPlayer.UnitySendMessage("SDK_callback", "ReloginResult", String.format("{result:%d}", result));
    }
    public void HandlePay(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandlePay exception:" + e.getMessage());
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "PayResult", String.format("{result:%d}", result));
    }
    public void HandleShare(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            int shareType = jsonObject.getInt("type");
            switch (shareType) {
                case SDKController.Type.WeiChatInterfaceType_ShareUrl:
                    result = ShareLinkUrl(jsonObject);
                    break;
                case SDKController.Type.WeiChatInterfaceType_ShareImage:
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

            TTAdConfig config = new TTAdConfig.Builder()
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
            TTAdSdk.init(mainActivity, config);

            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleSetupAD setup ok:" + appId);
        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleSetupAD exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "HandleSetupADResult", String.format("{result:%d}", result));
    }

    public void HandleScanFile(String filePath) {
        int result = 0;
        try{
            Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            scanIntent.setData(Uri.fromFile(new File(filePath)));
        }catch (Exception e){
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleScanFile exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "HandleScanFileResult", String.format("{result:%d}", result));
    }

    public void onAppCreate(Application application) {
    }
    public void onAppDestroy() {
    }
    public void onActivityCreate(UnityPlayerActivity activity) {
        mainActivity = activity;
        RegisterWeChat(activity);
    }
    public void onActivityDestroy() {
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
    }

    public void onResume() {
        if(isLogining()) {
            markLogining(false);
            UnityPlayer.UnitySendMessage("SDK_callback", "LoginResult", String.format("{result:%d}", -4));
        }
    }

    public void onPause() {
    }

    public void onStart() {
    }
    public void onStop() {
    }

    public void onResp(BaseResp resp) {
        try {
            JSONObject jsonResult = null;
            switch (resp.transaction) {
                case SDKController.Transaction.RequestLogin:
                    markLogining(false);

                    jsonResult = new JSONObject();
                    if(resp.errCode == 0) {
                        SendAuth.Resp auth = (SendAuth.Resp) resp;
                        jsonResult.put("result", 0);
                        jsonResult.put("token", auth.code);
						jsonResult.put("appid", WXID);
                    } else {
                        jsonResult.put("result", -5);
                        jsonResult.put("errno", resp.errCode);
                    }
					if(isRelogin())
						UnityPlayer.UnitySendMessage("SDK_callback", "ReloginResult", jsonResult.toString());
					else
	                    UnityPlayer.UnitySendMessage("SDK_callback", "LoginResult", jsonResult.toString());

                    break;
                case SDKController.Transaction.ShareImage:
                case SDKController.Transaction.ShareUrl:
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

    /*//分享文字
    public void ShareText(JSONObject jsonObject) {
        //String description = "";
        String text = "";
        boolean isCircleOfFriends = false;
        try {
            //description = jsonObject.getString("description");
            text = jsonObject.getString("text");
            isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");
        }catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","ShareText failure: " + e.toString());
            //Toast.makeText(mainActivity, e.toString(), Toast.LENGTH_SHORT).show();
            //Toast.makeText(MainActivity.Instance, e.toString(), Toast.LENGTH_SHORT).show();
        }
        WXTextObject textObj = new WXTextObject();
        textObj.text = text;
        // 用WXTextObject对象初始化一个WXMediaMessage对象
        WXMediaMessage msg = new WXMediaMessage();
        msg.mediaObject = textObj;
        // 发�?�文本类型的消息时，title字段不起作用
//         msg.title = "Will be ignored";
        //msg.description = description;
        // 构�?�一个Req
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = Transaction.ShareText; // transaction字段用于唯一标识�?个请�?
        req.message = msg;
        req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
        // 调用api接口发�?�数据到微信
        SendReq(req);
    }

    public void ShareVideo (JSONObject jsonObject) {
        String url = "";
        String title = "";
        String description = "";
        boolean isCircleOfFriends = false;
        try {
            url = jsonObject.getString("url");
            title = jsonObject.getString("title");
            description = jsonObject.getString("description");
            isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");
        }catch (Exception e) {
            //Toast.makeText(mainActivity, e.toString(), Toast.LENGTH_SHORT).show();
            //Toast.makeText(MainActivity.Instance, e.toString(), Toast.LENGTH_SHORT).show();
        }

        WXVideoObject video = new WXVideoObject();
        video.videoUrl = url;

        Resources re = mainActivity.getResources();
        Bitmap bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", mainActivity.getPackageName()));
        //Resources re = MainActivity.Instance.getResources();
        //Bitmap bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", MainActivity.Instance.getPackageName()));

        WXMediaMessage msg = new WXMediaMessage();
        msg.title = title;
        msg.description = description;
        msg.mediaObject = video;

        // 设置消息的缩略图
        Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 100, 100, true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
        req.transaction = Transaction.ShareVideo;
        req.message = msg;
        SendReq(req);
    }

    public void ShareMusic (JSONObject jsonObject) {
        @SuppressWarnings("unused")
		String url = "";
        String title = "";
        String description = "";
        boolean isCircleOfFriends = false;
        try {
            url = jsonObject.getString("url");
            title = jsonObject.getString("title");
            description = jsonObject.getString("description");
            isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");
        }catch (Exception e) {
            //Toast.makeText(MainActivity.Instance, e.toString(), Toast.LENGTH_SHORT).show();
            Toast.makeText(mainActivity, e.toString(), Toast.LENGTH_SHORT).show();
        }
        WXMusicObject music = new WXMusicObject();
        music.musicUrl = "url";

        Resources re = mainActivity.getResources();
        Bitmap bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", mainActivity.getPackageName()));
        //Resources re = MainActivity.Instance.getResources();
        //Bitmap bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", MainActivity.Instance.getPackageName()));

        WXMediaMessage msg = new WXMediaMessage();
        msg.title = title;
        msg.description = description;

        msg.mediaObject = music;

        // 设置消息的缩略图
        Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 100, 100, true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
        req.transaction = Transaction.ShareMusic;
        req.message = msg;
        SendReq(req);
    }

    */
    /*public void WeChatLogin()
    {
        SendAuth.Req req = new SendAuth.Req();
        req.transaction = Transaction.RequestLogin;
        req.scope = "snsapi_userinfo";   // 应用授权作用域，如获取用户个人信息则填写snsapi_userinfo
        req.state = "wechat_sdk_demo_test";
        SendReq(req);
        UnityPlayer.UnitySendMessage("SDK_callback", "Log","SendReq ~~~~~~~~~");
        //UnityPlayer.UnitySendMessage("Android", "CallBack", "SendReq ~~~~~~~~~");
    }
    public void SendReq(BaseReq req, String callbackName)
    {
        boolean issuccess = api.sendReq(req);
        if (!issuccess)
        {
            UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "SendReqFail" + ":" + req.transaction);

            UnityPlayer.UnitySendMessage("SDK_callback", "Log","SendReq ~~~~~~~~~ fail");
            //UnityPlayer.UnitySendMessage("Android", "CallBack", "SendReq ~~~~~~~~~ fail");
        }else{
            UnityPlayer.UnitySendMessage("SDK_callback", "Log","SendReq ~~~~~~~~~ succes");
            //UnityPlayer.UnitySendMessage("Android", "CallBack", "SendReq ~~~~~~~~~ succes");
        }
    }*/


    private String m_pushDeviceToken = "";
    public void SavePushDeviceToken(String s) {
        m_pushDeviceToken = s;
    }
    public String GetPushDeviceToken() {
        return m_pushDeviceToken;
    }

    private String m_oaid = "";
    public void SaveOAID(String value) { m_oaid = value; }
    public String GetOAID() { return m_oaid; }

    public interface Type {
        int WeiChatInterfaceType_IsWeiChatInstalled = 1; //判断是否安装微信
        int WeiChatInterfaceType_RequestLogin = 2; //请求登录
        int WeiChatInterfaceType_ShareUrl = 3; //分享链接
        int WeiChatInterfaceType_ShareText = 4; //分享文本
        int WeiChatInterfaceType_ShareMusic = 5;//分享音乐
        int WeiChatInterfaceType_ShareVideo = 6;//分享视频
        int WeiChatInterfaceType_ShareImage = 7;//分享图片
    }

    public interface Transaction {
        String IsWeiChatInstalled = "isInstalled"; //判断是否安装微信
        String RequestLogin = "login"; //请求登录
        String ShareUrl = "shareUrl"; //分享链接
        String ShareText = "shareText"; //分享文本
        String ShareMusic = "shareMusic";//分享音乐
        String ShareVideo = "shareVideo";//分享视频
        String ShareImage = "shareImage";//分享图片
    }
}

