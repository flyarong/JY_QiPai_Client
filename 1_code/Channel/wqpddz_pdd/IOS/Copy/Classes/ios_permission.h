//
//  ios_permission_test.h
//  iostest-mobile
//
//  Created by 何威 on 2018/8/15.
//

#ifndef ios_permission_h
#define ios_permission_h

int getCanIosLocation();
int getCanIosVoice();
int getCanIosCamera();
int getCanPushNotification();
void openIosVoice();
void gotoSetScene(const char *mode);
void openIosLocation();
void openIosCamera();

#endif /* ios_permission_test_h */
