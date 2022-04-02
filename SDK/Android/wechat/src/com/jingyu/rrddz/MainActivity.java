package com.jingyu.rrddz;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.sdk.my.WeChatController;
import com.unity3d.player.UnityPlayer;
import com.unity3d.player.UnityPlayerActivity;

import org.json.JSONObject;

public class MainActivity extends UnityPlayerActivity {

    public static MainActivity Instance;
    Context mContext = null;
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	Log.i("tag", ">>>>>>>>>OnCreate MainActivity 0");
        super.onCreate(savedInstanceState);
        Instance = this;
        mContext = this;
        Log.i("tag", ">>>>>>>>>OnCreate MainActivity 1");
    }
    
    //默认是微信登录
    public void Login(String appId){
    	//先注册appid
    	WeChatController.GetInstance().RegisterToWeChat(this, appId);
    	//登录
    	WeChatController.GetInstance().WeChatLogin();
    }
    
    public void RegisterToWeChat(String appId)
    {
        WeChatController.GetInstance().RegisterToWeChat(this, appId);
    }
    public void StartAc(String appId)
    {
        Toast.makeText(MainActivity.Instance, "////////////", Toast.LENGTH_SHORT).show();
    }
    
    public void WeChatLogin(String param){
    	 WeChatController.GetInstance().WeChatLogin();
    }
    
    public void WeChat(String param)
    {
        try {
            JSONObject jsonObject = new JSONObject(param);
            int _type =  jsonObject.getInt("type");
            WeChatController con = WeChatController.GetInstance();
            switch (_type)
            {
                case WeChatController.Type.WeiChatInterfaceType_IsWeiChatInstalled:
                    break;
                case WeChatController.Type.WeiChatInterfaceType_RequestLogin:
                    con.WeChatLogin();
                    break;
                case WeChatController.Type.WeiChatInterfaceType_ShareUrl:
                    con.ShareLinkUrl(jsonObject);
                    break;
                case WeChatController.Type.WeiChatInterfaceType_ShareImage:
                    con.ShareImage(jsonObject);
                    break;
                case WeChatController.Type.WeiChatInterfaceType_ShareText:
                    con.ShareText(jsonObject);
                    break;
                case WeChatController.Type.WeiChatInterfaceType_ShareVideo:
                    con.ShareVideo(jsonObject);
                    break;
                case WeChatController.Type.WeiChatInterfaceType_ShareMusic:
                    con.ShareMusic(jsonObject);
                    break;
            }
        }catch (Exception e) {
            UnityPlayer.UnitySendMessage("Android", "CallBack", e.toString());
        }

    }

}
