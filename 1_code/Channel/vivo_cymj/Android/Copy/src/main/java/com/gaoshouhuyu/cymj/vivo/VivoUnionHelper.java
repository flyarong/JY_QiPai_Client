package com.gaoshouhuyu.cymj.vivo;

import com.unity3d.player.UnityPlayer;

import org.json.JSONObject;

public class VivoUnionHelper {
    //取消支付返回数据
    public static void SendPayResult(String cpOrderNumber, String transNo, String productPrice) {
        try {
            JSONObject jsonResult = new JSONObject();
            jsonResult.put("result", 0);
            jsonResult.put("cpOrderNumber", cpOrderNumber);
            jsonResult.put("transNo", transNo);
            jsonResult.put("productPrice", productPrice);
            UnityPlayer.UnitySendMessage("SDK_callback", "PayResult", jsonResult.toString());
        } catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] SendPayResult exception:" + e.getMessage());
        }
    }
}
