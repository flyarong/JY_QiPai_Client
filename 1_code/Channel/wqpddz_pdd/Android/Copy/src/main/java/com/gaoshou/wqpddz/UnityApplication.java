package com.gaoshou.wqpddz;

import android.app.Application;

import com.bun.miitmdid.core.JLibrary;
import com.wxsdk.my.MiitHelper;
import com.wxsdk.my.SDKController;
import com.xunmeng.pap.action.PAPAction;

import android.app.Notification;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.widget.Toast;

public class UnityApplication extends Application {
    private Handler handler;
    @Override
    protected void attachBaseContext(Context ctx) {
        super.attachBaseContext(ctx);
        try {
            JLibrary.InitEntry(ctx);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    @Override
    public void onCreate() {
        super.onCreate();

        PAPAction.init(this,"13366","1c042f6f4522f7fe92fa0436db24dff265d86f14",true);

        /*UMConfigure.setLogEnabled(true);
        UMConfigure.init(this, "5b8d0566f29d98698d0000c8", "Umeng", UMConfigure.DEVICE_TYPE_PHONE,
                "d400aaf4eb88701fc988134d876fb861");
        PushAgent mPushAgent = PushAgent.getInstance(this);
        mPushAgent.register(new IUmengRegisterCallback() {
            @Override
            public void onSuccess(String s) {
                Log.i("my_token", s);
                SDKController.GetInstance().SavePushDeviceToken(s);
            }

            @Override
            public void onFailure(String s, String s1) {
                Log.i("register failed: ", s + " " + s1);
            }
        });*/

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            new MiitHelper().getDeviceIds(this, new MiitHelper.AppIdsUpdater() {
                @Override
                public void OnIdsAvailed(boolean isSupport, String oaid) {
                    Log.i("oaid", "new get:" + oaid);
                    SDKController.GetInstance().SaveOAID(oaid);
                }
            });
        }
    }
}
