package com.wxsdk.my;

import android.content.Context;
import android.util.Log;

import com.bun.miitmdid.core.InfoCode;
import com.bun.miitmdid.core.MdidSdkHelper;
import com.bun.miitmdid.interfaces.IIdentifierListener;
import com.bun.miitmdid.interfaces.IdSupplier;
import com.bun.miitmdid.pojo.IdSupplierImpl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class MiitHelper implements IIdentifierListener {

    private static final String TAG = "MiitHelper";
    public static final int HELPER_VERSION_CODE = 20210928; // MiitHelper的版本号 跟SDK版本同步
    //private AppIdsUpdater _listener;
    private AppIdsUpdater appIdsUpdater;
    private boolean isCertInit = false;        //初始化证书的标识
    public boolean isSDKLogOn = true;          // [1]设置 是否开启sdk日志
    public static final String ASSET_FILE_NAME_CERT = "com.gaoshou.wqpddz.cert.pem";  // [2]设置 玩棋牌asset证书文件名

    public MiitHelper(){
        System.loadLibrary("nllvm1632808251147706677");  // [3]加固版本在调用前必须载入SDK安全库
        // DemoHelper版本需与SDK版本一致
        if(MdidSdkHelper.SDK_VERSION_CODE != HELPER_VERSION_CODE){
            Log.e(TAG,"SDK version incorrect.");
            throw new RuntimeException("SDK version incorrect");
        }
        //this.appIdsUpdater = appIdsUpdater;
    }

    public void getDeviceIds(Context cxt, AppIdsUpdater callback) {
        //this.appIdsUpdater = callback
        appIdsUpdater = callback;
        // 初始化SDK证书
        if(!isCertInit){ // 证书只需初始化一次
            // 证书为PEM文件中的所有文本内容（包括首尾行、换行符）
            isCertInit = MdidSdkHelper.InitCert(cxt, loadPemFromAssetFile(cxt, ASSET_FILE_NAME_CERT));
            if(!isCertInit){
                Log.w(TAG, "getDeviceIds: cert init failed");
            }
        }
        int code = MdidSdkHelper.InitSdk(cxt, isSDKLogOn, this);
        // 根据SDK返回的code进行不同处理
        IdSupplierImpl unsupportedIdSupplier = new IdSupplierImpl();
        if(code == InfoCode.INIT_ERROR_CERT_ERROR){                         // 证书未初始化或证书无效，SDK内部不会回调onSupport
            Log.w(TAG,"cert not init or check not pass");
            onSupport(unsupportedIdSupplier);
        }else if(code == InfoCode.INIT_ERROR_DEVICE_NOSUPPORT){             // 不支持的设备, SDK内部不会回调onSupport
            Log.w(TAG,"device not supported");
            onSupport(unsupportedIdSupplier);
        }else if( code == InfoCode.INIT_ERROR_LOAD_CONFIGFILE){            // 加载配置文件出错, SDK内部不会回调onSupport
            Log.w(TAG,"failed to load config file");
            onSupport(unsupportedIdSupplier);
        }else if(code == InfoCode.INIT_ERROR_MANUFACTURER_NOSUPPORT){      // 不支持的设备厂商, SDK内部不会回调onSupport
            Log.w(TAG,"manufacturer not supported");
            onSupport(unsupportedIdSupplier);
        }else if(code == InfoCode.INIT_ERROR_SDK_CALL_ERROR){             // sdk调用出错, SSDK内部不会回调onSupport
            Log.w(TAG,"sdk call error");
            onSupport(unsupportedIdSupplier);
        } else if(code == InfoCode.INIT_INFO_RESULT_DELAY) {             // 获取接口是异步的，SDK内部会回调onSupport
            Log.i(TAG, "result delay (async)");
        }else if(code == InfoCode.INIT_INFO_RESULT_OK){                  // 获取接口是同步的，SDK内部会回调onSupport
            Log.i(TAG, "result ok (sync)");
        }else {
            // sdk版本高于DemoHelper代码版本可能出现的情况，无法确定是否调用onSupport
            // 不影响成功的OAID获取
            Log.w(TAG,"getDeviceIds: unknown code: " + code);
        }
    }

     /**
     * APP自定义的getDeviceIds(Context cxt)的接口回调
     * @param supplier
     */
    @Override
    public void onSupport(IdSupplier supplier) {
        if(supplier==null) {
            Log.w(TAG, "onSupport: supplier is null");
            appIdsUpdater.OnIdsAvailed(null);
            return;
        }
        if(appIdsUpdater ==null) {
            Log.w(TAG, "onSupport: callbackListener is null");
            return;
        }
        // 获取Id信息
        boolean isSupported = supplier.isSupported();
        boolean isLimited  = supplier.isLimited();
        if (isSupported == false) {
            Log.w(TAG, "onSupport: isSupported is false");
            appIdsUpdater.OnIdsAvailed(null);
            return;
        }
        if (isLimited == true) {
            Log.w(TAG, "onSupport: isLimited is true");
            appIdsUpdater.OnIdsAvailed(null);
            return;
        }
        String oaid = supplier.getOAID();
        appIdsUpdater.OnIdsAvailed(oaid);
    }

    public interface AppIdsUpdater {
        void OnIdsAvailed(String oaid);
    }

    /**
     * 从asset文件读取证书内容
     * @param context
     * @param assetFileName
     * @return 证书字符串
     */
    public static String loadPemFromAssetFile(Context context, String assetFileName){
        try {
            InputStream is = context.getAssets().open(assetFileName);
            BufferedReader in = new BufferedReader(new InputStreamReader(is));
            StringBuilder builder = new StringBuilder();
            String line;
            while ((line = in.readLine()) != null){
                builder.append(line);
                builder.append('\n');
            }
            return builder.toString();
        } catch (IOException e) {
            Log.e(TAG, "loadPemFromAssetFile failed");
            return "";
        }
    }
}