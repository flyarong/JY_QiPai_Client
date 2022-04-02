package com.gaoshouhuyu.wuziqi.vivo.bean;

public class OrderBean {
    private String cpOrderNumber; //cp订单号
    private String notifyUrl; //回调地址
    private String orderAmount;  //商品金额
    private String productName; //商品名称
    private String productDesc;  //商品描述



    public OrderBean(String cpOrderNumber, String notifyUrl, String orderAmount, String productName, String productDesc) {
        this.cpOrderNumber = cpOrderNumber;
        this.notifyUrl = notifyUrl;
        this.orderAmount = orderAmount;
        this.productName = productName;
        this.productDesc = productDesc;
    }

    public String getCpOrderNumber() {
        return cpOrderNumber;
    }

    public String getNotifyUrl() {
        return notifyUrl;
    }

    public String getOrderAmount() {
        return orderAmount;
    }

    public String getProductName() {
        return productName;
    }

    public String getProductDesc() {
        return productDesc;
    }

    @Override
    public String toString() {
        return "OrderBean{" +
                "cpOrderNumber='" + cpOrderNumber + '\'' +
                ", notifyUrl='" + notifyUrl + '\'' +
                ", orderAmount='" + orderAmount + '\'' +
                ", productName='" + productName + '\'' +
                ", productDesc='" + productDesc + '\'' +
                '}';
    }
}
