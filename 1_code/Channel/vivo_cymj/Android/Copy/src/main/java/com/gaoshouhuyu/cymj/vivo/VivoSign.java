package com.gaoshouhuyu.cymj.vivo;

import com.gaoshouhuyu.cymj.vivo.bean.OrderBean;
import com.vivo.unionsdk.open.VivoPayInfo;

import java.util.HashMap;
import java.util.Map;


public class VivoSign {




    //TODO 有服务器的游戏，请让服务器去计算验签，如果没有服务器，可以通过这段代码去生成验签
    /**
     * 计算验签
     *
     * @param orderBean 订单信息
     * @return
     */
    public static String getSignature(OrderBean orderBean) {
        HashMap<String, String> params = new HashMap<>();
        //appid
        params.put("appId", Config.APP_ID);
        //订单号
        params.put("cpOrderNumber", orderBean.getCpOrderNumber());
        //商品价格
        params.put("orderAmount", orderBean.getOrderAmount());
        //商品名称
        params.put("productName", orderBean.getProductName());
        //商品描述
        params.put("productDesc", orderBean.getProductDesc());
        //回调通知URL
        params.put("notifyUrl", orderBean.getNotifyUrl());

        return VivoSignUtils.getVivoSign(params, Config.APP_KEY);
    }

    /**
     * 登录vivo帐号后，创建VivoPayInfo
     *
     * @param uid       用户id
     * @param orderBean 订单信息
     * @return
     */
    public static VivoPayInfo createPayInfo(String uid, OrderBean orderBean) {
        //步骤1：计算支付参数签名
        String signature = getSignature(orderBean);
        //步骤2：创建VivoPayInfo
        VivoPayInfo vivoPayInfo = new VivoPayInfo.Builder()
                //基本支付信息
                .setAppId(Config.APP_ID)
                .setCpOrderNo(orderBean.getCpOrderNumber())
                .setProductName(orderBean.getProductName())
                .setProductDesc(orderBean.getProductDesc())
                .setOrderAmount(orderBean.getOrderAmount())
                //计算出来的参数验签
                .setVivoSignature(signature)
                //接入vivo帐号传uid，未接入传""
                .setExtUid(uid)
                .setNotifyUrl(orderBean.getNotifyUrl())
                .build();

        return vivoPayInfo;
    }

}
