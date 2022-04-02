package com.tencent.ysdk.my;

import android.app.AlertDialog;
import android.app.Application;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.widget.Toast;

import com.tencent.ysdk.module.pay.PayItem;
import com.tencent.ysdk.module.pay.PayRet;
import com.tencent.ysdk.module.user.WakeupRet;
import com.unity3d.player.UnityPlayer;
import com.tencent.tmgp.caiyunmj.UnityPlayerActivity;

import com.tencent.ysdk.api.YSDKApi;
import com.tencent.ysdk.framework.common.BaseRet;
import com.tencent.ysdk.framework.common.eFlag;
import com.tencent.ysdk.framework.common.ePlatform;
import com.tencent.ysdk.module.share.ShareApi;
import com.tencent.ysdk.module.share.ShareCallBack;
import com.tencent.ysdk.module.share.impl.IScreenImageCapturer;
import com.tencent.ysdk.module.share.impl.ShareRet;
import com.tencent.ysdk.module.user.UserLoginRet;

import com.bytedance.sdk.openadsdk.TTAdConfig;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdSdk;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;

public class YSDKController {
    static public String APP_ID;
    private  YSDKController(){};

    private boolean m_isLogining = false;
    public boolean isLogining() { return m_isLogining; }
    public void markLogining(boolean value) { m_isLogining = value; }

    private boolean m_isRelogin = false;
    public boolean isRelogin() { return m_isRelogin; }
    public void markRelogin(boolean value) { m_isRelogin = value; }

    private static YSDKController _instance;
    public static YSDKController GetInstance(){
        if(_instance == null)
        {
            _instance = new YSDKController();
        }
        return _instance;
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

    private UnityPlayerActivity mainActivity;

    public void onCreate(UnityPlayerActivity activity){
        if(mainActivity != null && !mainActivity.equals(activity)) {
            /*YSDKApi.handleIntent(activity.getIntent());
            activity.finish();
            return;*/
            //todo
        }
        mainActivity = activity;
        YSDKApi.onCreate(mainActivity);
        YSDKApi.handleIntent(activity.getIntent());
        YSDKApi.setUserListener(new YSDKCallback(mainActivity));
        YSDKApi.setBuglyListener(new YSDKCallback(mainActivity));

        ShareApi.getInstance().regShareCallBack(new ShareCallBack() {
            @Override
            public void onSuccess(ShareRet ret) {
                //Log.d("Share","分享成功！  分享路径："+ret.shareType.name()+" 透传信息："+ret.extInfo);
                SimpleFeedback("ShareResult", 0, 0);
            }

            @Override
            public void onError(ShareRet ret) {
                //Log.d("Share","分享失败  分享路径："+ret.shareType.name()+" 错误码："+ret.retCode+" 错误信息："+ret.retMsg+" 透传信息："+ret.extInfo);
                SimpleFeedback("ShareResult", -5, ret.retCode);
            }

            @Override
            public void onCancel(ShareRet ret) {
                //Log.d("Share","分享用户取消！  分享路径："+ret.shareType.name()+" 透传信息："+ret.extInfo);
                SimpleFeedback("ShareResult", -8, 0);
            }
        });
    }

    public void onNewIntent(Intent intent) {
        Log.d("[YSDK]","onNewIntent");
        YSDKApi.handleIntent(intent);
    }

    public void onDestroy () {
        Log.d("[YSDK]","onDestroy");
        YSDKApi.onDestroy(mainActivity);
    }

    public void onRestart() {
        Log.d("[YSDK]","onRestart");
        YSDKApi.onRestart(mainActivity);
    }

    public void onResume() {
        Log.d("[YSDK]","onResume");
        YSDKApi.onResume(mainActivity);
    }

    public void onPause() {
        Log.d("[YSDK]","onPause");
        YSDKApi.onPause(mainActivity);
    }

    public void onStop() {
        Log.d("[YSDK]","onStop");
        YSDKApi.onStop(mainActivity);
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d("[YSDK]","onActivityResult resultCode:" + resultCode);
        YSDKApi.onActivityResult(requestCode, resultCode, data);
    }


    private String m_pushDeviceToken = "";
    public void SetPushDeviceToken(String s) {
        m_pushDeviceToken = s;
    }
    public String GetPushDeviceToken() {
        return m_pushDeviceToken;
    }

    public ePlatform getPlatform() {
        UserLoginRet ret = new UserLoginRet();
        YSDKApi.getLoginRecord(ret);
        if (ret.flag == eFlag.Succ) {
            return ePlatform.getEnum(ret.platform);
        }
        return ePlatform.None;
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

    // 平台授权成功,让用户进入游戏. 由游戏自己实现登录的逻辑
    public void letUserLogin(UserLoginRet ret) {
        try {
            ePlatform platform = ePlatform.getEnum(ret.platform);
            YSDKApi.queryUserInfo(platform);

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

    /*public void onLogin(String platform) {
        Log.d("[YSDK]","onLogin platform:" + platform);

        markLogining(true);

        ePlatform current = getPlatform();
        if(platform.equals("yyb_qq")) {
            YSDKApi.login(ePlatform.QQ);
        } else if(platform.equals("yyb_wechat")) {
            YSDKApi.login(ePlatform.WX);
        } else {
            YSDKApi.login(ePlatform.Guest);
        }
    }

    // 平台授权成功,让用户进入游戏. 由游戏自己实现登录的逻辑
    public void letUserLogin() {
        UserLoginRet ret = new UserLoginRet();
        YSDKApi.getLoginRecord(ret);
        Log.d("[YSDK]","letUserLogin flag: " + ret.flag);
        Log.d("[YSDK]","letUserLogin platform: " + ret.platform);
        Log.d("[YSDK]","access token: " + ret.getAccessToken());
        if (ret.ret != BaseRet.RET_SUCC) {
            Log.d("[YSDK]","UserLogin error:" + ret.ret);
            return;
        }

        //String url = "http://ysdktest.qq.com/auth/wx_check_token";
        //String timestamp = "" + (int)(System.currentTimeMillis() * 0.001f);
        //String appid = "wx40ae5dfaaa09975d";
        //String openid = ret.open_id;
        //String sig = strToMD5("f9946ff715c5c8cc5bdee74cceb94d18"+timestamp);
        //String v = url + "?timestamp="+timestamp+"&appid="+appid+"&sig="+sig+"&openid="+openid+"&openkey="+ret.getAccessToken();
        //Log.d("[YSDK]","access url: " + v);

        //String url = "http://ysdktest.qq.com/auth/qq_check_token";
        //String timestamp = "" + (int)(System.currentTimeMillis() * 0.001f);
        //String appid = "1109655980";
        //String openid = ret.open_id;
        //String sig = strToMD5("uAZqcD5Uwg86onHP"+timestamp);
        //String v = url + "?timestamp="+timestamp+"&appid="+appid+"&sig="+sig+"&openid="+openid+"&openkey="+ret.getAccessToken();
        //Log.d("[YSDK]","access url: " + v);

        YSDKApi.queryUserInfo(ePlatform.getEnum(ret.platform));

        String v = ret.open_id + ";" + ret.getAccessToken() + ";" + ret.getRefreshToken() + ";" + ret.pf + ";" + ret.pf_key + ";" + ret.getPayToken();
        UnityPlayer.UnitySendMessage("SDK_callback", "OnLoginSuc", v);
    }

    public void letUserLogout(int errorCode) {
        YSDKApi.logout();
        UnityPlayer.UnitySendMessage("SDK_callback", "OnLoginErr", "" + errorCode);
    }

    public void showDiffLogin() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                builder.setTitle("异账号提示");
                builder.setMessage("你当前拉起的账号与你本地的账号不一致，请选择使用哪个账号登陆：");
                builder.setPositiveButton("本地账号",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,
                                                int whichButton) {
                                Toast.makeText(mainActivity,"选择使用本地账号",Toast.LENGTH_LONG).show();
                                if (!YSDKApi.switchUser(false)) {
                                    letUserLogout();
                                }
                            }
                        });
                builder.setNeutralButton("拉起账号",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,
                                                int whichButton) {
                                Toast.makeText(mainActivity,"选择使用拉起账号",Toast.LENGTH_LONG).show();
                                if (!YSDKApi.switchUser(true)) {
                                    letUserLogout();
                                }
                            }
                        });
                builder.show();
            }
        });
    }*/

    /*public int onShare(String jsonData) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(jsonData);
            String title = jsonObject.getString("title");
            String desc = jsonObject.getString("desc");
            String ext = jsonObject.getString("ext");
            String imgFile = jsonObject.getString("img");

            String platform = jsonObject.getString("platform");
            if(platform.equals("yyb_qq")) {
                ShareQQ(title, desc, ext, imgFile, jsonObject.getBoolean("group"));
            } else if(platform.equals("yyb_wechat")) {
                ShareWX(title, desc, ext, imgFile, jsonObject.getBoolean("group"));
            } else {
                Share(title, desc, ext, imgFile);
            }
        } catch (Exception e) {
            result = -100;
        }
        return result;
    }*/

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
        if(bmp == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] ShareQQ Load imgFile failed:" + imgFile);
            return -7;
        }

        if(qzone)
            ShareApi.getInstance().shareToQZone(bmp, title, desc, ext);
        else
            ShareApi.getInstance().shareToQQFriend(bmp, title, desc, ext);

        return 0;
    }

    /*public int onRecharge(String jsonData) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(jsonData);
            String ident = jsonObject.getString("ident");
            String value = jsonObject.getString("value");
            Boolean canChange = jsonObject.getBoolean("canChange");
            String ext = jsonObject.getString("ext");
            String imgFile = jsonObject.getString("img");

            Recharge(ident, value, canChange, ext, imgFile);
        } catch (Exception e) {
            result = -100;
        }
        return result;
    }

    public boolean Recharge(String ident, String value, boolean canChange, String ext, String imgFile) {
        Bitmap bmp = BitmapFactory.decodeFile(imgFile);
        if(bmp == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "Recharge", "decode bmp failed:" + imgFile);
            return false;
        }

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bmp.compress(Bitmap.CompressFormat.PNG, 100, stream);
        byte[] imgData = stream.toByteArray();

        YSDKApi.recharge(ident, value, canChange, imgData, ext, new YSDKCallback(mainActivity));

        return true;
    }*/

    /*public int onRecharge(String jsonData) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(jsonData);
            String ident = jsonObject.getString("ident");
            String url = jsonObject.getString("url");
            String ext = jsonObject.getString("ext");
            String imgFile = jsonObject.getString("img");

            Recharge(ident, url, ext, imgFile);
        } catch (Exception e) {
            result = -100;
        }
        return result;
    }*/

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

        YSDKApi.buyGoods(ident, url, imgData, ext, new YSDKCallback(mainActivity));

        return 0;
    }

    /*public int onRecharge(String jsonData) {
        int result = 0;

        boolean canChange = false;
        try {
            JSONObject jsonObject = new JSONObject(jsonData);
            String ident = jsonObject.getString("ident");
            String ext = jsonObject.getString("ext");
            String imgFile = jsonObject.getString("img");

            String itemID = jsonObject.getString("itemID");
            String itemName = jsonObject.getString("itemName");
            String itemDesc = jsonObject.getString("itemDesc");
            int itemPrice = Integer.parseInt(jsonObject.getString("itemPrice"));
            int itemNum = Integer.parseInt(jsonObject.getString("itemNum"));
            String appKey = jsonObject.getString("appKey");
            String ysdkExt = jsonObject.getString("ysdkExt");
            String midasExt = jsonObject.getString("midasExt");
            if(jsonObject.has("canChange"))
                canChange = jsonObject.getBoolean("canChange");

            PayItem item = new PayItem();
            item.id = itemID;
            item.name = itemName;
            item.desc = itemDesc;
            item.price = itemPrice;
            item.num = itemNum;

            Recharge(ident, item, appKey, ysdkExt, midasExt, imgFile, canChange);
        } catch (Exception e) {
            result = -100;
        }
        return result;
    }
    public boolean Recharge(String ident, PayItem item, String appKey, String ysdkExt, String midasExt, String imgFile, boolean canChange) {
        Bitmap bmp = BitmapFactory.decodeFile(imgFile);
        if(bmp == null) {
            UnityPlayer.UnitySendMessage("SDK_callback", "Recharge", "decode bmp failed:" + imgFile);
            return false;
            //bmp = Util.capForBitmap(mainActivity);
        }

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bmp.compress(Bitmap.CompressFormat.PNG, 100, stream);
        byte[] imgData = stream.toByteArray();

        YSDKApi.buyGoods(canChange, ident, item, appKey, imgData, ysdkExt, midasExt, new YSDKCallback(mainActivity));

        return true;
    }*/
}
