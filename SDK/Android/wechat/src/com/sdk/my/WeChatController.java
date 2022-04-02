package com.sdk.my;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.widget.Toast;

import com.jingyu.rrddz.MainActivity;
import com.tencent.mm.sdk.openapi.BaseReq;
import com.tencent.mm.sdk.openapi.SendAuth;
import com.tencent.mm.sdk.openapi.SendMessageToWX;
import com.tencent.mm.sdk.openapi.WXImageObject;
import com.tencent.mm.sdk.openapi.WXMediaMessage;
import com.tencent.mm.sdk.openapi.WXMusicObject;
import com.tencent.mm.sdk.openapi.WXTextObject;
import com.tencent.mm.sdk.openapi.WXVideoObject;
import com.tencent.mm.sdk.openapi.WXWebpageObject;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.unity3d.player.UnityPlayer;

import org.json.JSONObject;

/**
 * Created by Administrator on 2016/9/6 0006.
 */
public class WeChatController {
    static private IWXAPI api;
    private static WeChatController _instance;
    static public String APP_ID;
    private  WeChatController(){};

    public static WeChatController GetInstance(){
        if(_instance == null)
        {
            _instance = new WeChatController();
        }
        return _instance;
    }

    public void RegisterToWeChat(Context context, String appId){
        APP_ID = appId;
        api = WXAPIFactory.createWXAPI(context,APP_ID);
        boolean issuccess =  api.registerApp(APP_ID);
        if (issuccess)
        {
            UnityPlayer.UnitySendMessage("Android", "CallBack", "RegToWx success~~~~~~~" + appId);
        }else{
            UnityPlayer.UnitySendMessage("Android", "CallBack", "RegToWx failure~~~~~~~~~" + appId);
        }
    }

    //分享文字
    public void ShareText(JSONObject jsonObject) {
        String description = "";
        String text = "";
        boolean isCircleOfFriends = false;
        try {
            description = jsonObject.getString("description");
            text = jsonObject.getString("text");
            isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");
        }catch (Exception e) {
            Toast.makeText(MainActivity.Instance, e.toString(), Toast.LENGTH_SHORT).show();
        }
        WXTextObject textObj = new WXTextObject();
        textObj.text = text;
        // 用WXTextObject对象初始化一个WXMediaMessage对象
        WXMediaMessage msg = new WXMediaMessage();
        msg.mediaObject = textObj;
        // 发�?�文本类型的消息时，title字段不起作用
//         msg.title = "Will be ignored";
        msg.description = description;
        // 构�?�一个Req
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = Transaction.ShareText; // transaction字段用于唯一标识�?个请�?
        req.message = msg;
        req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
        // 调用api接口发�?�数据到微信
        SendReq(req);
    }

    public void ShareImage (JSONObject jsonObject) {
        boolean isCircleOfFriends = false;
        try {
            isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");
        }catch (Exception e) {
            Toast.makeText(MainActivity.Instance, e.toString(), Toast.LENGTH_SHORT).show();
        }
        Resources re = MainActivity.Instance.getResources();
        Bitmap bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", MainActivity.Instance.getPackageName()));
        WXImageObject imgObj = new WXImageObject(bmp);

        WXMediaMessage msg = new WXMediaMessage();
        msg.mediaObject = imgObj;

        // 设置消息的缩略图
        Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 150, 150, true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
        req.transaction = Transaction.ShareImage;
        req.message = msg;
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
            Toast.makeText(MainActivity.Instance, e.toString(), Toast.LENGTH_SHORT).show();
        }

        WXVideoObject video = new WXVideoObject();
        video.videoUrl = url;

        Resources re = MainActivity.Instance.getResources();
        Bitmap bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", MainActivity.Instance.getPackageName()));

        WXMediaMessage msg = new WXMediaMessage();
        msg.title = title;
        msg.description = description;
        msg.mediaObject = video;

        // 设置消息的缩略图
        Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 150, 150, true);
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
            Toast.makeText(MainActivity.Instance, e.toString(), Toast.LENGTH_SHORT).show();
        }
        WXMusicObject music = new WXMusicObject();
        music.musicUrl = "url";

        Resources re = MainActivity.Instance.getResources();
        Bitmap bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", MainActivity.Instance.getPackageName()));

        WXMediaMessage msg = new WXMediaMessage();
        msg.title = title;
        msg.description = description;

        msg.mediaObject = music;

        // 设置消息的缩略图
        Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 150, 150, true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
        req.transaction = Transaction.ShareMusic;
        req.message = msg;
        SendReq(req);
    }

    public void ShareLinkUrl(JSONObject jsonObject) {
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
            UnityPlayer.UnitySendMessage("Android", "CallBack", "异常");
            Toast.makeText(MainActivity.Instance, e.toString(), Toast.LENGTH_SHORT).show();
        }
        WXWebpageObject webpage = new WXWebpageObject();
        webpage.webpageUrl = url;
        //用WXMebpageObject 对象初始化一个WXMediaMessage对象，填写标题，描述

        WXMediaMessage msg = new WXMediaMessage(webpage);
        msg.title = title;
        msg.description = description;  //描述只在发�?�给朋友时显示，发�?�到朋友圈不显示
        //链接图片
        Resources re = MainActivity.Instance.getResources();  //通过�?个活动的Activity  (UnityPlayerActivity._instance)提换为可用的Activity

        Bitmap bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", MainActivity.Instance.getPackageName()));
        Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 150, 150, true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
//
//        int id = re.getIdentifier("app_icon", "drawable", MainActivity.Instance.getPackageName());
//        if (id == 0 )
//        {
//            Toast.makeText(MainActivity.Instance, "et app_icon fail ", Toast.LENGTH_SHORT).show();
//        }else
//        {
//            Bitmap thumb = BitmapFactory.decodeResource(re,id); //图片小于32k
//            msg.thumbData = Util.bmpToByteArray(thumb, true);
//        }
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = Transaction.ShareUrl;
        req.message = msg;
        req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
        SendReq(req);
    }
    public void WeChatLogin()
    {
        SendAuth.Req req = new SendAuth.Req();
        req.transaction = Transaction.RequestLogin;
        req.scope = "snsapi_userinfo";   // 应用授权作用域，如获取用户个人信息则填写snsapi_userinfo
        req.state = "wechat_sdk_demo_test";
        SendReq(req);
        UnityPlayer.UnitySendMessage("Android", "CallBack", "SendReq ~~~~~~~~~");
    }
    public void SendReq(BaseReq req)
    {
        boolean issuccess = api.sendReq(req);
        if (!issuccess)
        {
            UnityPlayer.UnitySendMessage("Android", "CallBack", "SendReq ~~~~~~~~~ fail");
        }else{
            UnityPlayer.UnitySendMessage("Android", "CallBack", "SendReq ~~~~~~~~~ succes");
        }
    }

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

