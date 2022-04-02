package com.tencent.tmgp.caiyunmj;

import android.app.Application;

import com.tencent.ysdk.my.YSDKController;
import android.app.Notification;
import android.content.Context;
import android.os.Handler;
import android.util.Log;
import android.widget.Toast;

public class UnityApplication extends Application {
    private Handler handler;
    @Override
    public void onCreate() {
        super.onCreate();
    }
}
