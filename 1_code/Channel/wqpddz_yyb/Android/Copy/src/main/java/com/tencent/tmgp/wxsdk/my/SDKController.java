package com.tencent.tmgp.wxsdk.my;

import android.app.AlertDialog;
import android.app.Application;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.os.Environment;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.PopupWindow;
import android.widget.Toast;

import com.tencent.tmgp.wanqpddz.UnityPlayerActivity;
import com.tencent.tmgp.wanqpddz.R;
import com.tencent.ysdk.api.YSDKApi;
import com.tencent.ysdk.framework.common.BaseRet;
import com.tencent.ysdk.framework.common.eFlag;
import com.tencent.ysdk.framework.common.ePlatform;
import com.tencent.ysdk.module.AntiAddiction.model.AntiAddictRet;
import com.tencent.ysdk.module.pay.PayRet;
import com.tencent.ysdk.module.share.ShareApi;
import com.tencent.ysdk.module.share.ShareCallBack;
import com.tencent.ysdk.module.share.impl.ShareRet;
import com.tencent.ysdk.module.user.UserLoginRet;
import com.tencent.ysdk.module.user.WakeupRet;
import com.unity3d.player.UnityPlayer;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;

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

        UnityPlayer.UnitySendMessage("SDK_callback", "InitResult", String.format("{result:%d}", result));
    }
    public void HandleLogin(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            String platform = jsonObject.getString("platform");

            if(platform.equals("yyb_qq")) {
                YSDKApi.login(ePlatform.QQ);
            } else if(platform.equals("yyb_wechat")) {
                YSDKApi.login(ePlatform.WX);
            } else {
                YSDKApi.login(ePlatform.Guest);
            }

            markLogining(true);
            markRelogin(false);

            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleLogin send req. platform:" + platform);
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

            YSDKApi.logout();
        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleLoginOut exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "LoginOutResult", String.format("{result:%d}", result));
    }
	public void HandleRelogin(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            String platform = jsonObject.getString("platform");

            if(platform.equals("yyb_qq")) {
                YSDKApi.login(ePlatform.QQ);
            } else if(platform.equals("yyb_wechat")) {
                YSDKApi.login(ePlatform.WX);
            } else {
                YSDKApi.login(ePlatform.Guest);
            }

            markLogining(true);
            markRelogin(true);

            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleRelogin send req. platform:" + platform);
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
            JSONObject jsonObject = new JSONObject(json_data);
            String ident = jsonObject.getString("ident");
            String url = jsonObject.getString("url");
            String ext = jsonObject.getString("ext");
            String imgFile = jsonObject.getString("img");

            result = Recharge(ident, url, ext, imgFile);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandlePay exception:" + e.getMessage());
        }

        if(result != 0)
            UnityPlayer.UnitySendMessage("SDK_callback", "PayResult", String.format("{result:%d}", result));
    }
    public void HandleShare(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            String title = jsonObject.getString("title");
            String desc = jsonObject.getString("desc");
            String ext = jsonObject.getString("ext");
            String imgFile = jsonObject.getString("img");
            String platform = jsonObject.getString("platform");
            int width = 256;
            int height = 256;
            if(jsonObject.has("width"))
                width = jsonObject.getInt("width");
            if(jsonObject.has("height"))
                height = jsonObject.getInt("height");

            if(platform.equals("yyb_qq")) {
                result = ShareQQ(title, desc, ext, imgFile, jsonObject.getBoolean("group"), width, height);
            } else if(platform.equals("yyb_wechat")) {
                result = ShareWX(title, desc, ext, imgFile, jsonObject.getBoolean("group"), width, height);
            } else {
                result = Share(title, desc, ext, imgFile, width, height);
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

            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleSetupAD setup failed. yyb not support:" + appId);
        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleSetupAD exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "HandleSetupADResult", String.format("{result:%d}", result));
    }

    public void onAppCreate(Application application) {
    }
    public void onAppDestroy() {
    }
    public void onCreate(UnityPlayerActivity activity) {
        mainActivity = activity;
        YSDKApi.onCreate(mainActivity);
        YSDKApi.handleIntent(activity.getIntent());
        YSDKCallback callback = new YSDKCallback();
        YSDKApi.setUserListener(callback);
        YSDKApi.setBuglyListener(callback);

        //注册分享监听器接受分享状态信息
        ShareApi.getInstance().regShareCallBack(new ShareCallBack() {
            @Override
            public void onSuccess(ShareRet ret) {
                Log.d("Share","分享成功！  分享路径："+ret.shareType.name()+" 透传信息："+ret.extInfo);
                SimpleFeedback("ShareResult", 0, 0);
            }

            @Override
            public void onError(ShareRet ret) {
                Log.d("Share","分享失败  分享路径："+ret.shareType.name()+" 错误码："+ret.retCode+" 错误信息："+ret.retMsg+" 透传信息："+ret.extInfo);
                SimpleFeedback("ShareResult", -5, ret.retCode);
            }

            @Override
            public void onCancel(ShareRet ret) {
                Log.d("Share","分享用户取消！  分享路径："+ret.shareType.name()+" 透传信息："+ret.extInfo);
                SimpleFeedback("ShareResult", -8, 0);
            }
        });
    }
    public void onDestroy() {
        Log.d("[YSDK]","onDestroy");
        YSDKApi.onDestroy(mainActivity);
    }
    public void onNewIntent(Intent intent) {
        Log.d("[YSDK]","onNewIntent");
        YSDKApi.handleIntent(intent);
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d("[YSDK]","onActivityResult resultCode:" + resultCode);
        YSDKApi.onActivityResult(requestCode, resultCode, data);
    }

    public void onResume() {
        Log.d("[YSDK]","onResume");
        YSDKApi.onResume(mainActivity);
    }

    public void onPause() {
        Log.d("[YSDK]","onPause");
        YSDKApi.onPause(mainActivity);
    }

    public void onStart() {
    }

    public void onRestart() {
        Log.d("[YSDK]","onRestart");
        YSDKApi.onRestart(mainActivity);
    }
    public void onStop() {
        Log.d("[YSDK]","onStop");
        YSDKApi.onStop(mainActivity);
    }

    public void OnLoginNotify(UserLoginRet ret) {
        markLogining(false);

        if(ret.flag ==  eFlag.Succ) {
            if (ret.ret != BaseRet.RET_SUCC)
                letUserLogout(-5, ret.ret);
            else
                letUserLogin(ret);
        } else
            letUserLogout(-5, ret.flag);
    }

    public void OnWakeupNotify(WakeupRet ret) {
        // TODO GAME 游戏需要在这里增加处理异账号的逻辑
        if (eFlag.Wakeup_YSDKLogining == ret.flag) {
            // 用拉起的账号登录，登录结果在OnLoginNotify()中回调
        } else if (ret.flag == eFlag.Wakeup_NeedUserSelectAccount) {
            // 异账号时，游戏需要弹出提示框让用户选择需要登录的账号
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] OnWakeupNotify Diff Account");
            //mainActivity.showDiffLogin();
            mainActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    AlertDialog.Builder builder = new AlertDialog.Builder(mainActivity);
                    builder.setTitle("异账号提示");
                    builder.setMessage("你当前拉起的账号与你本地的账号不一致，请选择使用哪个账号登陆：");
                    builder.setPositiveButton("本地账号",
                            new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog,
                                                    int whichButton) {
                                    if (!YSDKApi.switchUser(false)) {
                                        letUserLogout(-5, ret.flag);
                                    }
                                }
                            });
                    builder.setNeutralButton("拉起账号",
                            new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog,
                                                    int whichButton) {
                                    if (!YSDKApi.switchUser(true)) {
                                        UserLoginRet userret = new UserLoginRet();
                                        YSDKApi.getLoginRecord(userret);
                                        letUserLogin(userret);
                                    }
                                }
                            });
                    builder.show();
                }
            });
        } else if (ret.flag == eFlag.Wakeup_NeedUserLogin) {
            // 没有有效的票据，登出游戏让用户重新登录
            letUserLogout(-5, ret.flag);
        } else {
            Log.d("[YSDK] OnWakeupNotify","logout");
            //mainActivity.letUserLogout();
        }
    }

    public void OnPayNotify(PayRet ret) {
        if(ret.ret == PayRet.RET_SUCC)
            SimpleFeedback("PayResult", 0, ret.payState);
        else
            SimpleFeedback("PayResult", -5, ret.flag);
    }

    public void letUserLogin(UserLoginRet ret) {
        try {
            ePlatform platform = ePlatform.getEnum(ret.platform);

            JSONObject jsonResult = new JSONObject();
            jsonResult.put("result", 0);
            jsonResult.put("openid", ret.open_id);
            jsonResult.put("token", ret.getAccessToken());
            jsonResult.put("refresh_token", ret.getRefreshToken());
            jsonResult.put("pf", ret.pf);
            jsonResult.put("pfkey", ret.pf_key);
            jsonResult.put("paytoken", ret.getPayToken());

            if(platform == ePlatform.QQ)
                jsonResult.put("appid", "1109655980");
            else if(platform == ePlatform.WX)
                jsonResult.put("appid", "wx40ae5dfaaa09975d");
            else
                jsonResult.put("appid", "");

            if(isRelogin())
                UnityPlayer.UnitySendMessage("SDK_callback", "ReloginResult", jsonResult.toString());
            else
                UnityPlayer.UnitySendMessage("SDK_callback", "LoginResult", jsonResult.toString());
        } catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] letUserLogin exception:" + e.getMessage());
        }
    }

    public void letUserLogout(int result, int errno) {
        YSDKApi.logout();
        if(isRelogin())
            SimpleFeedback("ReloginResult", result, errno);
        else
            SimpleFeedback("LoginResult", result, errno);
    }

    //share
    public int Share(String title, String desc, String ext, String imgFile, int width, int height) {
        //Bitmap bmp = BitmapFactory.decodeFile(imgFile);
        Bitmap bmp = Util.decodeBitmap(imgFile, width, height);
        if(bmp == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] Share Load imgFile failed:" + imgFile);
            return -7;
        }

        ShareApi.getInstance().share(bmp, title, desc, ext);

        return 0;
    }

    public int ShareWX(String title, String desc, String ext, String imgFile, boolean timeline, int width, int height) {
        //Bitmap bmp = BitmapFactory.decodeFile(imgFile);
        Bitmap bmp = Util.decodeBitmap(imgFile, width, height);
        if(bmp == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] ShareWX Load imgFile failed:" + imgFile);
            return -7;
        }

        if(timeline)
            ShareApi.getInstance().shareToWXTimeline(bmp, title, desc, ext);
        else
            ShareApi.getInstance().shareToWXFriend(bmp, title, desc, ext);

        return 0;
    }

    public int ShareQQ(String title, String desc, String ext, String imgFile, boolean qzone, int width, int height) {
        //Bitmap bmp = BitmapFactory.decodeFile(imgFile);
        Bitmap bmp = Util.decodeBitmap(imgFile, width, height);
        if (bmp == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[SDK] ShareQQ Load imgFile failed:" + imgFile);
            return -7;
        }

        if (qzone)
            ShareApi.getInstance().shareToQZone(bmp, title, desc, ext);
        else
            ShareApi.getInstance().shareToQQFriend(bmp, title, desc, ext);

        return 0;
    }

    public int Recharge(String ident, String url, String ext, String imgFile) {
        Bitmap bmp = BitmapFactory.decodeFile(imgFile);
        if(bmp == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] Recharge Load imgFile failed:" + imgFile);
            if(bmp == null)
                bmp = Util.capForBitmap(mainActivity);
        }

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bmp.compress(Bitmap.CompressFormat.PNG, 100, stream);
        byte[] imgData = stream.toByteArray();

        YSDKApi.buyGoods(ident, url, imgData, ext, new YSDKCallback());

        return 0;
    }

    public boolean mAntiAddictExecuteState = false;
    public void executeInstruction(AntiAddictRet ret) {
        final int modal = ret.modal;
        switch (ret.type) {
            case AntiAddictRet.TYPE_TIPS:
            case AntiAddictRet.TYPE_LOGOUT:
                if (!mAntiAddictExecuteState) {
                    mAntiAddictExecuteState = true;
                    AlertDialog.Builder builder = new AlertDialog.Builder(mainActivity);
                    builder.setTitle(ret.title);
                    builder.setMessage(ret.content);
                    builder.setPositiveButton("知道了",
                            new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog,
                                                    int whichButton) {
                                    if (modal == 1) {
                                        // 强制用户下线
                                        letUserLogout(-5, 9001);
                                    }
                                    changeExecuteState(false);
                                }
                            });
                    builder.setCancelable(false);
                    builder.show();
                    // 已执行指令
                    YSDKApi.reportAntiAddictExecute(ret, System.currentTimeMillis());
                }

                break;

            case AntiAddictRet.TYPE_OPEN_URL:
                if (!mAntiAddictExecuteState) {
                    mAntiAddictExecuteState = true;
                    View popwindowView = View.inflate(mainActivity, R.layout.pop_window_web_layout, null);
                    WebView webView = popwindowView.findViewById(R.id.pop_window_webview);
                    Button closeButton = popwindowView.findViewById(R.id.pop_window_close);

                    WebSettings settings= webView.getSettings();
                    settings.setJavaScriptEnabled(true);
                    webView.setWebViewClient(new WebViewClient());
                    webView.loadUrl(ret.url);

                    final PopupWindow popupWindow = new PopupWindow(popwindowView, 1000, 1000);
                    popupWindow.setTouchable(true);
                    popupWindow.setOutsideTouchable(false);
                    popupWindow.setBackgroundDrawable(new BitmapDrawable());

                    closeButton.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if (modal == 1) {
                                letUserLogout(-5, 9002);
                            }
                            popupWindow.dismiss();
                            changeExecuteState(false);
                        }
                    });

                    popupWindow.showAtLocation(popwindowView, Gravity.CENTER, 0, 0);
                    // 已执行指令
                    YSDKApi.reportAntiAddictExecute(ret, System.currentTimeMillis());
                }

                break;

        }
    }

    private void changeExecuteState(boolean state) {
        mAntiAddictExecuteState = state;
    }

    public void showToastTips(String content) {
        Toast.makeText(mainActivity, content, Toast.LENGTH_SHORT).show();
    }


    /*public void onResp(BaseResp resp) {
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
    }*/

    public int ShareLinkUrl(JSONObject jsonObject) {
        try {
            String url = jsonObject.getString("url");
            String title = jsonObject.getString("title");
            String description = jsonObject.getString("description");
            String icon = jsonObject.getString("icon");
            boolean isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");

            /*WXWebpageObject webpage = new WXWebpageObject();
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
                return -3;*/
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

            /*WXImageObject imgObj = new WXImageObject(bmp);
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
                return -3;*/

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

