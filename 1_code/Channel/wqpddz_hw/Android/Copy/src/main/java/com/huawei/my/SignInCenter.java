package com.huawei.my;

import com.huawei.hms.support.hwid.result.AuthHuaweiId;

public class SignInCenter {

    private static SignInCenter INS = new SignInCenter();

    private static AuthHuaweiId currentAuthHuaweiId;

    public static SignInCenter get() {
        return INS;
    }

    public void updateAuthHuaweiId(AuthHuaweiId AuthHuaweiId) {
        currentAuthHuaweiId = AuthHuaweiId;
        if(SDKController.GetInstance().needCertification())
            SDKController.GetInstance().getCertificateInfo();
        else
            SDKController.GetInstance().getCurrentPlayer(1);
    }

    public AuthHuaweiId getAuthHuaweiId() {
        return currentAuthHuaweiId;
    }
}
