//
//  ios_permission_test.m
//  iostest-mobile
//
//  Created by 何威 on 2018/8/15.
//
#include "ios_permission.h"
#import <CoreLocation/CLLocationManager.h>
#import <AVFoundation/AVCaptureDevice.h>
int getCanIosLocation()
{
    CLAuthorizationStatus authStatus=[CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined:
            //玩家还没选择
            return 1;
        case kCLAuthorizationStatusDenied:
            //玩家未授权
            return 2;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            //玩家授权
            return 0;
        case kCLAuthorizationStatusAuthorized:
            //玩家授权
            return 0;
        case kCLAuthorizationStatusRestricted:
            //家长限制
            return 3;
        default:
            break;
    }
    return 2;
}
int getCanIosVoice()
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
            //玩家还没选择
            return 1;
        case AVAuthorizationStatusRestricted:
            //家长限制
            return 3;
        case AVAuthorizationStatusDenied:
            //玩家未授权
            return 2;
        case AVAuthorizationStatusAuthorized:
            //玩家授权
            return 0;
        default:
            break;
    }
    return 2;
}
int getCanIosCamera()
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
            //玩家还没选择
            return 1;
        case AVAuthorizationStatusRestricted:
            //家长限制
            return 3;
        case AVAuthorizationStatusDenied:
            //玩家未授权
            return 2;
        case AVAuthorizationStatusAuthorized:
            //玩家授权
            return 0;
        default:
            break;
    }
    return 2;
}

int getCanPushNotification()
{
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *prefix = [[iOSVersion componentsSeparatedByString:@"."] firstObject];
    float version = [prefix floatValue];
    if(version >= 8) {
        if([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone)
            return 0;
        else
            return 1;
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(types != UIRemoteNotificationTypeNone)
            return 0;
        else
            return 1;
    }
}

void openIosLocation()
{
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    //使用的时候获取定位信息
    [manager requestWhenInUseAuthorization];
}
void openIosVoice()
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        NSLog(@"%@",granted ? @"麦克风准许":@"麦克风不准许");
    }];
}
void openIosCamera()
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        NSLog(@"%@",granted ? @"相机准许":@"相机不准许");
    }];}
void gotoSetScene(const char *mode)
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}
