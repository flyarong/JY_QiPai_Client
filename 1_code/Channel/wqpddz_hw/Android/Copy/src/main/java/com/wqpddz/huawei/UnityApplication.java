package com.wqpddz.huawei;

import android.app.Application;

import android.app.Notification;
import android.content.Context;
import android.os.Handler;
import android.util.Log;
import android.widget.Toast;

import com.huawei.my.SDKController;

public class UnityApplication extends Application {
    private Handler handler;
    @Override
    public void onCreate() {
        super.onCreate();
        SDKController.GetInstance().onAppCreate(this);
    }
    public void onTerminate() {
        super.onTerminate();
        SDKController.GetInstance().onAppDestroy();
    }
}
