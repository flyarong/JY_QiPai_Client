
/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package com.huawei.my;

import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;

import com.huawei.hms.iap.entity.PurchaseIntentWithPriceReq;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;

public class IAPSupport {
    private static final String TAG = "HMS_LOG_CipherUtil";

    private static final String SIGN_ALGORITHMS = "SHA256WithRSA";

    private static final String PUBLIC_KEY = "MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAkmtufUYYIl5ELe8wzlkf7+4Bd+JVP/r1b2ZHmayZs+13H9G/4155ph1sJPzlsADIED1ZhgvMinWoQMmnOd/ipGhalHWViyPviNxGXAhHCaqYwHLuHYS5XofBzPEURU1G12fJNw5ubtULQK4o8L/aqpdu2MrtwnJX4mHtFLRw1rhQQ+/Z1HZ1AenEGmkiJ5JifrVtz6hT2AKAXKMeGVNkxgbhzxyj+0IEENNuWvE7GeYfVgX0Ua4lJ2SH5jAcuOZFF+YT97NkckVkOJFiMyumgrOVyIGobRtafKYg8j8esm1J0pF1aiuWqj1IaC/pD1YUqh3VausCioxC247Xg7t4oRObJkZvH98of9HUBzHd+Ni77XBcN/jxnw4Lc3NutARQgKC83KdXjAljeOBCxUUg1uRdbe/srdiH3g2PclIFCEQg3HK5qXVT6xXSMG78OROVePfp1C2ZxXFVD9JdVCXGbERaeyRDNL+tozFn9x67u1FRdcZdQntIR1o2pV4dZQFvAgMBAAE=";

    public static boolean doCheck(String content, String sign) {
        if (TextUtils.isEmpty(PUBLIC_KEY)) {
            Log.e(TAG, "publicKey is null");
            return false;
        }
        try {
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            byte[] encodedKey = Base64.decode(PUBLIC_KEY, Base64.DEFAULT);
            PublicKey pubKey = keyFactory.generatePublic(new X509EncodedKeySpec(encodedKey));
            java.security.Signature signature = java.security.Signature.getInstance(SIGN_ALGORITHMS);
            signature.initVerify(pubKey);
            signature.update(content.getBytes("utf-8"));
            return signature.verify(Base64.decode(sign, Base64.DEFAULT));
        } catch (NoSuchAlgorithmException e) {
            Log.e(TAG, "doCheck NoSuchAlgorithmException" + e);
        } catch (InvalidKeySpecException e) {
            Log.e(TAG, "doCheck InvalidKeySpecException" + e);
        } catch (InvalidKeyException e) {
            Log.e(TAG, "doCheck InvalidKeyException" + e);
        } catch (SignatureException e) {
            Log.e(TAG, "doCheck SignatureException" + e);
        } catch (UnsupportedEncodingException e) {
            Log.e(TAG, "doCheck UnsupportedEncodingException" + e);
        }
        return false;
    }

    /*
    ProductId：商品ID用于唯一标识一个商品，不能重复
    ProductName：商品名
    Amount：商品金额，保留小数点后两位
    PriceType: 0: 消耗型商品 / 1: 非消耗型商品
    DeveloperPayload：商户侧保留信息
    */
    public static PurchaseIntentWithPriceReq createGetBuyIntentWithPriceReq(String productId, String productName, String amount, int priceType, String developerPayload) {
        PurchaseIntentWithPriceReq request = new PurchaseIntentWithPriceReq();

        request.setProductId(productId);
        request.setProductName(productName);
        request.setAmount(amount);
        request.setPriceType(priceType);
        request.setDeveloperPayload(developerPayload);

        request.setCurrency("CNY");
        request.setCountry("CN");
        request.setServiceCatalog("X6");
        request.setSdkChannel("1");

        return request;
    }
}
