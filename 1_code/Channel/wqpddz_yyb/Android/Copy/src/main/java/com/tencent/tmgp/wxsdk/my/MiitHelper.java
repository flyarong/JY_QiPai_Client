package com.tencent.tmgp.wxsdk.my;

import android.content.Context;
import android.util.Log;

import com.bun.miitmdid.core.ErrorCode;
import com.bun.miitmdid.core.JLibrary;
import com.bun.miitmdid.core.MdidSdk;
import com.bun.miitmdid.core.MdidSdkHelper;
import com.bun.supplier.IIdentifierListener;
import com.bun.supplier.IdSupplier;

public class MiitHelper implements IIdentifierListener {

    private static final String TAG = "MiitHelper";
    private AppIdsUpdater _listener;

    public static void install(Context base) {
        try {
            JLibrary.InitEntry(base);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void getDeviceIds(Context cxt, AppIdsUpdater callback) {
        _listener = callback;
        int responseCode = CallFromReflect(cxt.getApplicationContext());

        switch (responseCode) {
            case ErrorCode.INIT_ERROR_DEVICE_NOSUPPORT://不支持的设备
            case ErrorCode.INIT_ERROR_LOAD_CONFIGFILE://加载配置文件出错
            case ErrorCode.INIT_ERROR_MANUFACTURER_NOSUPPORT://不支持的设备厂商
//            case ErrorCode.INIT_ERROR_RESULT_DELAY://获取接口是异步的，结果会在回调中返回，回调执行的回调可能在工作线程
            case ErrorCode.INIT_HELPER_CALL_ERROR://反射调用出错
            {
                if (_listener != null) {
                    _listener.OnIdsAvailed(false, null);
                    _listener = null;
                }
            }
            break;
        }


//        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
//            return CallFromReflect(cxt.getApplicationContext());
//        }
//        return DirectCall(cxt);
    }

    /*
     * 通过反射调用，解决android 9以后的类加载升级，导至找不到so中的方法
     *
     * */
    private int CallFromReflect(Context cxt) {
        return MdidSdkHelper.InitSdk(cxt, false, this);
    }

    /*
     * 直接java调用，如果这样调用，在android 9以前没有题，在android 9以后会抛找不到so方法的异常
     * 解决办法是和JLibrary.InitEntry(cxt)，分开调用，比如在A类中调用JLibrary.InitEntry(cxt)，在B类中调用MdidSdk的方法
     * A和B不能存在直接和间接依赖关系，否则也会报错
     * */
    private int DirectCall(Context cxt) {
        MdidSdk sdk = new MdidSdk();
        return sdk.InitSdk(cxt, this);
    }

    @Override
    public void OnSupport(boolean isSupport, IdSupplier _supplier) {
        Log.d(TAG, "OnSupport: %s oaid %s" + isSupport + _supplier.getOAID());
        if (_supplier == null) {
            if (_listener != null) {
                _listener.OnIdsAvailed(isSupport, null);
                _listener = null;
            }
            return;
        }
        String oaid = _supplier.getOAID();
        if (_listener != null) {
            _listener.OnIdsAvailed(isSupport, oaid);
            _listener = null;
        }
    }

    public interface AppIdsUpdater {
        void OnIdsAvailed(boolean isSupport, String oaid);
    }


}
