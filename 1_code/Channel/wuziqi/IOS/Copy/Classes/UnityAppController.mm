#import "UnityAppController.h"
#import "UnityAppController+ViewHandling.h"
#import "UnityAppController+Rendering.h"
#import "iPhone_Sensors.h"

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CADisplayLink.h>
#import <Availability.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#include <mach/mach_time.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <BUAdSDK/BUAdSDKManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/ASIdentifierManager.h>

// MSAA_DEFAULT_SAMPLE_COUNT was moved to iPhone_GlesSupport.h
// ENABLE_INTERNAL_PROFILER and related defines were moved to iPhone_Profiler.h
// kFPS define for removed: you can use Application.targetFrameRate (30 fps by default)
// DisplayLink is the only run loop mode now - all others were removed

#include "CrashReporter.h"

#import "WXApi.h"
#include "UI/OrientationSupport.h"
#include "UI/UnityView.h"
#include "UI/Keyboard.h"
#include "UI/SplashScreen.h"
#include "Unity/InternalProfiler.h"
#include "Unity/DisplayManager.h"
#include "Unity/EAGLContextHelper.h"
#include "Unity/GlesHelper.h"
#include "Unity/ObjCRuntime.h"
#include "PluginBase/AppDelegateListener.h"
#include "ios_permission.h"
#include "MyCLLocationManager.h"

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

#pragma mark WXApi Delegate

#define WeiXinID @"wxfbbdf6d20dc91113"
#define UniversalLink @"https://game-support.jyhd919.cn/"
#define sendAuthRequestNotification @"sendAuthRequestNotification"
#define GameObjectName "SDK_callback"
#define LoginMethodName "OnLoginSuc"
#define FailMethodName "OnWeChatError"
#define WeChatShareMethodName "OnWeChatShare"
#define UpdateCityName "OnUpdCityName"
#define RecordingName "OnRecord"
#define PlayRecordFinish "OnPlayRecordFinish"

#define ETRECORD_RATE 11025.0

#define IsValidString(string) (string && [string isEqualToString:@""] == NO)

enum ShareType {
    IsWeiChatInstalled = 1,
    RequestLogin = 2,
    Url = 3,
    Text = 4,
    Music = 5,
    Video = 6,
    Image = 7
};
NSString *gStrDeviceID = @"";
NSString *gStrURL = @"";
NSString *gCafFile = @"";
NSString *gMp3File = @"";
NSString *gMp3Record = @"";
NSString *gAmrRecord = @"";

static UIImage* scaleToSize(UIImage *img, CGSize size) {
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage *scaleImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImg;
}

static void UnityFeedback(const char *callback, NSDictionary *dictData) {
	NSError *error = nil;
	NSData *json_data = [NSJSONSerialization dataWithJSONObject:dictData options:NSJSONWritingPrettyPrinted error:&error];
	if([json_data length] > 0 && error == nil) {
		NSString *string = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
		UnitySendMessage(GameObjectName, callback, [string UTF8String]);
    } else {
        NSString *string = [[NSString alloc] initWithFormat:@"%@ json exception", callback];
		UnitySendMessage(GameObjectName, [@"LogError" UTF8String], [string UTF8String]);
    }
}

static void SimpleFeedback(const char *callback, int result, int error) {
	NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithCapacity:2];
	[dictData setObject:[NSNumber numberWithInt:result] forKey:@"result"];
	[dictData setObject:[NSNumber numberWithInt:error] forKey:@"errno"];

	UnityFeedback(callback, dictData);
}

extern "C" {
    void WXLogin(const char *appID) {
        if([WXApi isWXAppInstalled])
            [[NSNotificationCenter defaultCenter] postNotificationName:sendAuthRequestNotification object:nil];
        else
            UnitySendMessage(GameObjectName, FailMethodName, [@"NeedInstall" cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    void WXShare(const char *json) {
        NSString *strJson = [[NSString alloc] initWithUTF8String:json];
        NSData *jsonData = [strJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        
        NSNumber *type = [dic objectForKey:@"type"];
        switch([type intValue])
        {
            case ShareType::Url:
                {
                    WXMediaMessage *message = [WXMediaMessage message];
                    message.title = [dic objectForKey:@"title"];
                    message.description = [dic objectForKey:@"description"];
                    
                    NSString *filePath = [dic objectForKey:@"icon"];
                    UIImage *thumbImage = [UIImage imageWithContentsOfFile:filePath];
                    if(thumbImage == nullptr)
                        [message setThumbImage:[UIImage imageNamed:@"AppIcon40x40"]];
                    else
                        [message setThumbImage:scaleToSize(thumbImage, CGSizeMake(100,100))];

                    WXWebpageObject *webpageObject = [WXWebpageObject object];
                    webpageObject.webpageUrl = [dic objectForKey:@"url"];
                    message.mediaObject = webpageObject;
                    
                    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                    req.bText               = NO;
                    req.message = message;
                    
                    NSNumber *isCircleOfFriends = [dic objectForKey:@"isCircleOfFriends"];
                    if([isCircleOfFriends boolValue])
                        req.scene = WXSceneTimeline;
                    else
                        req.scene = WXSceneSession;
                    
                    [WXApi sendReq:req completion:^(BOOL success) {
                        if(success)
                            UnitySendMessage(GameObjectName, [@"Log" UTF8String], [@"wx send url success" UTF8String]);
                        else
                            UnitySendMessage(GameObjectName, [@"LogError" UTF8String], [@"wx send url failed" UTF8String]);
                    }];
                } break;
            case ShareType::Text:
            {
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                req.text                = [dic objectForKey:@"text"];
                req.bText               = YES;
                NSNumber *isCircleOfFriends = [dic objectForKey:@"isCircleOfFriends"];

                if([isCircleOfFriends boolValue])
                    req.scene = WXSceneTimeline;
                else
                    req.scene = WXSceneSession;
                
                [WXApi sendReq:req completion:^(BOOL success) {
                    if(success)
                        UnitySendMessage(GameObjectName, [@"Log" UTF8String], [@"wx send text success" UTF8String]);
                    else
                        UnitySendMessage(GameObjectName, [@"LogError" UTF8String], [@"wx send text failed" UTF8String]);
                }];
            } break;
                
            case ShareType::Image:
            {
                WXMediaMessage *message = [WXMediaMessage message];
                
                NSString *filePath = [dic objectForKey:@"imgFile"];
                UIImage *thumbImage = [UIImage imageWithContentsOfFile:filePath];
                thumbImage = scaleToSize(thumbImage, CGSizeMake(100,100));
                [message setThumbImage:thumbImage];
                
                WXImageObject *imageObject = [WXImageObject object];
                
                imageObject.imageData = [NSData dataWithContentsOfFile:filePath];
                message.mediaObject = imageObject;
                
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                req.bText               = NO;
                req.message = message;
                
                NSNumber *isCircleOfFriends = [dic objectForKey:@"isCircleOfFriends"];
                if([isCircleOfFriends boolValue])
                    req.scene = WXSceneTimeline;
                else
                    req.scene = WXSceneSession;
                
                [WXApi sendReq:req completion:^(BOOL success) {
                    if(success)
                        UnitySendMessage(GameObjectName, [@"Log" UTF8String], [@"wx send img success" UTF8String]);
                    else
                        UnitySendMessage(GameObjectName, [@"LogError" UTF8String], [@"wx send img failed" UTF8String]);
                }];
            } break;
        }
    }
    
    void HandleInit(const char *json_data) {
        SimpleFeedback("InitResult", 0, 0);
    }
    void HandleLogin(const char *json_data) {
        if([WXApi isWXAppInstalled]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:sendAuthRequestNotification object:nil];
        } else
            SimpleFeedback("LoginResult", -2, 0);
    }
    void HandleLoginOut(const char *json_data) {
        SimpleFeedback("LoginOutResult", 0, 0);
    }
    void HandleRelogin(const char *json_data) {
        [[NSNotificationCenter defaultCenter] postNotificationName:sendAuthRequestNotification object:nil];
    }
    void HandlePay(const char *json_data) {
        SimpleFeedback("PayResult", 0, 0);
    }
    void HandleShare(const char *json_data) {
        WXShare(json_data);
    }
    void HandleShowAccountCenter(const char *json_data) {
        SimpleFeedback("ShowAccountCenterResult", 0, 0);
    }

    void HandleSetupAD(const char *json_data) {
        NSString *strJson = [[NSString alloc] initWithUTF8String:json_data];
        NSData *jsonData = [strJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        NSString *adAppId = [dic objectForKey:@"appId"];
        [BUAdSDKManager setAppID:adAppId];
        [BUAdSDKManager setIsPaidApp:NO];
        SimpleFeedback("HandleSetupADResult", 0, 0);
    }
    
    const char* DeviceID() {
    	if(@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                if(status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    gStrDeviceID = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                } else {
                    NSLog(@"请在设置-隐私-Tracking中允许App请求跟踪");
                }
            }];
        } else {
            if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
                gStrDeviceID = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            } else {
                NSLog(@"请在设置-隐私-广告中打开广告跟踪功能");
            }
        }
        
        NSString *strNone = @"00000000-0000-0000-0000-000000000000";
        if([gStrDeviceID isEqualToString:strNone])
            return NULL;
        
        const char *raw = [gStrDeviceID UTF8String];
        char *mem = (char*)malloc(strlen(raw) + 1);
        strcpy(mem, raw);
        
        return mem;
    }

    const char* Deeplink()
    {
        if([gStrURL isEqual:[NSNull null]])
            return NULL;
        
        const char *raw = [gStrURL UTF8String];
        char *mem = (char*)malloc(strlen(raw) + 1);
        strcpy(mem, raw);
        
        gStrURL = @"";
        
        return mem;
    }
    
    const char* PushDeviceToken() {
            return NULL;
    }

    void PhoneCallUp(const char *number) {
        NSString *strNumber = [[NSString alloc] initWithUTF8String:number];
        NSURL *opt1 = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:strNumber]];
        NSURL *opt2 = [NSURL URLWithString:[@"tel://" stringByAppendingString:strNumber]];
        NSURL *targetURL = nil;
        if([UIApplication.sharedApplication canOpenURL:opt1])
            targetURL = opt1;
        else if([UIApplication.sharedApplication canOpenURL:opt2])
            targetURL = opt2;
        if(targetURL) {
            if(@available(iOS 10.0, *))
                [UIApplication.sharedApplication openURL:targetURL options:@{} completionHandler:nil];
            else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [UIApplication.sharedApplication openURL:targetURL];
#pragma clang diagnostic pop
            }
        }
    }

    void QueryingCityName(float latitude, float longitude) {
        AppController_QueryingCityName(latitude, longitude);
    }
    
    void QueryingGPS() {
        [[MyCLLocationManager shareManager] startLocation:nil];
    }

    void ShowProductRating() {
    }
	
	void CallingScheme(const char *scheme) {
		NSString *param = [[NSString alloc] initWithUTF8String:scheme];
		AppController_CallingScheme(param);
	}

	int CallingCamera() {
        return AppController_CallingCamera();
	}
	int CallingPhoto() {
        return AppController_CallingPhoto();
	}

    int CanLocation() {
    	//return getCanIosLocation();
        return [[MyCLLocationManager shareManager] canLocation];
    }
    int CanVoice() {
    	return getCanIosVoice();
    }
    int CanCamera(bool deep) {
        return getCanIosCamera();
    }
    int CanPushNotification() {
        return getCanPushNotification();
    }
    void OpeningLocation() {
        //openIosLocation();
        [[MyCLLocationManager shareManager] openLocation];
    }
    void OpeningVoice() {
        openIosVoice();
    }
    void OpeningCamera() {
        openIosCamera();
    }
    void GoingSetScene(const char *mode) {
        gotoSetScene(mode);
    }
    void ForceQuiting() {
    }
}

#pragma mark -

//
UnityAppController* _UnityAppController = nil;

// Standard Gesture Recognizers enabled on all iOS apps absorb touches close to the top and bottom of the screen.
// This sometimes causes an ~1 second delay before the touch is handled when clicking very close to the edge.
// You should enable this if you want to avoid that delay. Enabling it should not have any effect on default iOS gestures.
#define DISABLE_TOUCH_DELAYS 1

// we keep old bools around to support "old" code that might have used them
bool _ios42orNewer = false, _ios43orNewer = false, _ios50orNewer = false, _ios60orNewer = false, _ios70orNewer = false;
bool _ios80orNewer = false, _ios81orNewer = false, _ios82orNewer = false, _ios83orNewer = false, _ios90orNewer = false, _ios91orNewer = false;
bool _ios100orNewer = false, _ios101orNewer = false, _ios102orNewer = false, _ios103orNewer = false;
bool _ios110orNewer = false, _ios111orNewer = false, _ios112orNewer = false;

// was unity rendering already inited: we should not touch rendering while this is false
bool    _renderingInited        = false;
// was unity inited: we should not touch unity api while this is false
bool    _unityAppReady          = false;
// see if there's a need to do internal player pause/resume handling
//
// Typically the trampoline code should manage this internally, but
// there are use cases, videoplayer, plugin code, etc where the player
// is paused before the internal handling comes relevant. Avoid
// overriding externally managed player pause/resume handling by
// caching the state
bool    _wasPausedExternal      = false;
// should we skip present on next draw: used in corner cases (like rotation) to fill both draw-buffers with some content
bool    _skipPresent            = false;
// was app "resigned active": some operations do not make sense while app is in background
bool    _didResignActive        = false;

// was startUnity scheduled: used to make startup robust in case of locking device
static bool _startUnityScheduled    = false;

bool    _supportsMSAA           = false;

#if UNITY_SUPPORT_ROTATION
// Required to enable specific orientation for some presentation controllers: see supportedInterfaceOrientationsForWindow below for details
NSInteger _forceInterfaceOrientationMask = 0;
#endif

@implementation UnityAppController

@synthesize unityView               = _unityView;
@synthesize unityDisplayLink        = _displayLink;

@synthesize rootView                = _rootView;
@synthesize rootViewController      = _rootController;
@synthesize mainDisplay             = _mainDisplay;
@synthesize renderDelegate          = _renderDelegate;
@synthesize quitHandler             = _quitHandler;

#if UNITY_SUPPORT_ROTATION
@synthesize interfaceOrientation    = _curOrientation;
#endif


- (CLGeocoder *)geocoder
{
      if (!_geocoder) {
          _geocoder = [[CLGeocoder alloc] init];
      }
      return _geocoder;
}

- (AVAudioRecorder*)audioRecorder {
    if(!_audioRecorder) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    
        NSURL *url = [self getSavePath];
        NSDictionary *setting = [self getAudioSetting];
        
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        [_audioRecorder prepareToRecord];
        if(error) {
            NSLog(@"Create audioRecorder failed: %@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

- (NSDictionary*) getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dicM setObject:@(ETRECORD_RATE) forKey:AVSampleRateKey];
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    return dicM;
}

- (NSURL*) getSavePath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"AudioData"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        BOOL createDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!createDir)
            NSLog(@"createDir failed");
    }

    NSString *fileName = @"record";
    NSString *cafFile = [NSString stringWithFormat:@"%@.caf", fileName];
    NSString *mp3File = [NSString stringWithFormat:@"%@.mp3", fileName];

    gCafFile = [path stringByAppendingPathComponent:cafFile];
    gMp3File = [path stringByAppendingPathComponent:mp3File];
    
    NSURL *url = [NSURL fileURLWithPath:gCafFile];
    
    return url;
}

- (id)init
{
    if ((self = _UnityAppController = [super init]))
    {
        // due to clang issues with generating warning for overriding deprecated methods
        // we will simply assert if deprecated methods are present
        // NB: methods table is initied at load (before this call), so it is ok to check for override
        NSAssert(![self respondsToSelector: @selector(createUnityViewImpl)],
            @"createUnityViewImpl is deprecated and will not be called. Override createUnityView"
            );
        NSAssert(![self respondsToSelector: @selector(createViewHierarchyImpl)],
            @"createViewHierarchyImpl is deprecated and will not be called. Override willStartWithViewController"
            );
        NSAssert(![self respondsToSelector: @selector(createViewHierarchy)],
            @"createViewHierarchy is deprecated and will not be implemented. Use createUI"
            );
    }
    return self;
}

- (void)setWindow:(id)object        {}
- (UIWindow*)window                 { return _window; }


- (void)shouldAttachRenderDelegate  {}
- (void)preStartUnity               {}


- (void)startUnity:(UIApplication*)application
{
    NSAssert(_unityAppReady == NO, @"[UnityAppController startUnity:] called after Unity has been initialized");

    UnityInitApplicationGraphics();

    // we make sure that first level gets correct display list and orientation
    [[DisplayManager Instance] updateDisplayListCacheInUnity];

    UnityLoadApplication();
    Profiler_InitProfiler();

    [self showGameUI];
    [self createDisplayLink];

    UnitySetPlayerFocus(1);
}

-(void)signInWithApple API_AVAILABLE(ios(13.0))
{
    ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [provider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    
    ASAuthorizationController *vc = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    vc.delegate = self;
    vc.presentationContextProvider = self;
    [vc performRequests];
}

-(ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0))
{
    return self.rootView.window;
}

-(void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0))
{
    NSString *errorMsg = nil;
    switch(error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"user cancel authorization";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"authorization failed";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"authorization request no response";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"authorization not handle";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"authorization failed and unknown reason";
            break;
    }
    NSLog(@"%@", errorMsg);

    SimpleFeedback("LoginResult", -5, error.code);
}

-(void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0))
{
    if([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        ASAuthorizationAppleIDCredential *credential = authorization.credential;
        NSString *state = credential.state;
        NSString *userID = credential.user;
        NSPersonNameComponents *fullName = credential.fullName;
        NSString *email = credential.email;
        NSString *authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding];
        NSString *identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding];
        ASUserDetectionStatus realUserStatus = credential.realUserStatus;

        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"appleID"];
        [[NSUserDefaults standardUserDefaults] setObject:identityToken forKey:@"appleIDIdentityToken"];
        
        NSLog(@"state: %@", state);
        NSLog(@"userID: %@", userID);
        NSLog(@"fullName: %@", fullName);
        NSLog(@"email: %@", email);
        NSLog(@"authorizationCode: %@", authorizationCode);
        NSLog(@"identityToken: %@", identityToken);
        NSLog(@"realUserStatus: %@", @(realUserStatus));


	NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithCapacity:2];
	[dictData setObject:[NSNumber numberWithInt:0] forKey:@"result"];
	//[dictData setObject:@"" forKey:@"appid"];
	[dictData setObject:userID forKey:@"user"];
	[dictData setObject:authorizationCode forKey:@"authorizationCode"];
	[dictData setObject:identityToken forKey:@"identityToken"];
	UnityFeedback("LoginResult", dictData);
    }
}
-(void)checkCredentialState API_AVAILABLE(ios(13.0)) {
    NSString * userIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:@"appleID"];
    if(userIdentifier) {
        ASAuthorizationAppleIDProvider * appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        [appleIDProvider getCredentialStateForUserID:userIdentifier completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
            switch(credentialState) {
                case ASAuthorizationAppleIDProviderCredentialAuthorized:
                {
                    NSString * identityToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"appleIDIdentityToken"];
                    NSLog(@"state: ASAuthorizationAppleIDProviderCredentialAuthorized %@", identityToken);
                }
                    break;
                case ASAuthorizationAppleIDProviderCredentialRevoked:
                    NSLog(@"state: ASAuthorizationAppleIDProviderCredentialRevoked");
                    break;
                case ASAuthorizationAppleIDProviderCredentialNotFound:
                    NSLog(@"state: ASAuthorizationAppleIDProviderCredentialNotFound");
                    break;
            }
        }];
    }
}

-(void)observeAppleSignInState {
    if(@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}

-(void)handleSignInWithAppleStateChanged:(NSNotification*) notification {
    NSLog(@"%@", notification.userInfo);
}

/*
if (@available(iOS 13.0, *))
	[self showAuthorizationLogin];
*/

-(void)showAuthorizationLogin API_AVAILABLE(ios(13.0)) {
	ASAuthorizationAppleIDButton * appleIDBtn = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeDefault style:ASAuthorizationAppleIDButtonStyleWhite];
	appleIDBtn.frame = CGRectMake(30, 80, self.rootView.bounds.size.width - 60, 64);
	[appleIDBtn addTarget:self action:@selector(didAppleIDBtnClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.rootView addSubview:appleIDBtn];
}

-(void)didAppleIDBtnClicked {
	[self signInWithApple];
}

- (void)CallingScheme:(NSString*)scheme
{
}

- (int)CallingCamera
{
    //判断是否已授权
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied||authStatus == AVAuthorizationStatusRestricted)
            return -2;
    }
    // 判断是否可以打开相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.rootViewController presentViewController:picker animated:YES completion:nil];
        
        return 0;
    } else
        return -1;
}
- (int)CallingPhoto
{
    //判断是否已授权
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == AVAuthorizationStatusDenied)
            return -2;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //self.isReload = NO;
        [self.rootViewController presentViewController:picker animated:YES completion:nil];
        
        return 0;
    } else
        return -1;
}

extern "C" void UnityDestroyDisplayLink()
{
    [GetAppController() destroyDisplayLink];
}

extern "C" void UnityRequestQuit()
{
    _didResignActive = true;
    if (GetAppController().quitHandler)
        GetAppController().quitHandler();
    else
        exit(0);
}

#if UNITY_SUPPORT_ROTATION

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // No rootViewController is set because we are switching from one view controller to another, all orientations should be enabled
    if ([window rootViewController] == nil)
        return UIInterfaceOrientationMaskAll;

    // Some presentation controllers (e.g. UIImagePickerController) require portrait orientation and will throw exception if it is not supported.
    // At the same time enabling all orientations by returning UIInterfaceOrientationMaskAll might cause unwanted orientation change
    // (e.g. when using UIActivityViewController to "share to" another application, iOS will use supportedInterfaceOrientations to possibly reorient).
    // So to avoid exception we are returning combination of constraints for root view controller and orientation requested by iOS.
    // _forceInterfaceOrientationMask is updated in willChangeStatusBarOrientation, which is called if some presentation controller insists on orientation change.
    return [[window rootViewController] supportedInterfaceOrientations] | _forceInterfaceOrientationMask;
}

- (void)application:(UIApplication*)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
{
    // Setting orientation mask which is requiested by iOS: see supportedInterfaceOrientationsForWindow above for details
    _forceInterfaceOrientationMask = 1 << newStatusBarOrientation;
}

#endif

#if !PLATFORM_TVOS
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    AppController_SendNotificationWithArg(kUnityDidReceiveLocalNotification, notification);
    UnitySendLocalNotification(notification);
}

#endif

//#if UNITY_USES_REMOTE_NOTIFICATIONS
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
}

/*#if !PLATFORM_TVOS
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    AppController_SendNotificationWithArg(kUnityDidReceiveRemoteNotification, userInfo);
    UnitySendRemoteNotification(userInfo);
    if (handler)
    {
        handler(UIBackgroundFetchResultNoData);
    }
}

#endif
*/
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    AppController_SendNotificationWithArg(kUnityDidFailToRegisterForRemoteNotificationsWithError, error);
    UnitySendRemoteNotificationError(error);
    // alas people do not check remote notification error through api (which is clunky, i agree) so log here to have at least some visibility
    ::printf("\nFailed to register for remote notifications:\n%s\n\n", [[error localizedDescription] UTF8String]);
}

//#endif

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    NSMutableArray* keys    = [NSMutableArray arrayWithCapacity: 3];
    NSMutableArray* values  = [NSMutableArray arrayWithCapacity: 3];

    #define ADD_ITEM(item)  do{ if(item) {[keys addObject:@#item]; [values addObject:item];} }while(0)

    ADD_ITEM(url);
    ADD_ITEM(sourceApplication);
    ADD_ITEM(annotation);

    #undef ADD_ITEM

    NSDictionary* notifData = [NSDictionary dictionaryWithObjects: values forKeys: keys];
    AppController_SendNotificationWithArg(kUnityOnOpenURL, notifData);
    return YES;
}

- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    AppController_SendNotificationWithArg(kUnityWillFinishLaunchingWithOptions, launchOptions);
    return YES;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    ::printf("-> applicationDidFinishLaunching()\n");

    // send notfications
#if !PLATFORM_TVOS
    if (UILocalNotification* notification = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey])
        UnitySendLocalNotification(notification);

    if ([UIDevice currentDevice].generatesDeviceOrientationNotifications == NO)
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
#endif

    UnityInitApplicationNoGraphics([[[NSBundle mainBundle] bundlePath] UTF8String]);

    [self selectRenderingAPI];
    [UnityRenderingView InitializeForAPI: self.renderingAPI];

    _window         = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    _unityView      = [self createUnityView];

    [DisplayManager Initialize];
    _mainDisplay    = [DisplayManager Instance].mainDisplay;
    [_mainDisplay createWithWindow: _window andView: _unityView];

    [self createUI];
    [self preStartUnity];

    // if you wont use keyboard you may comment it out at save some memory
    [KeyboardDelegate Initialize];

#if !PLATFORM_TVOS && DISABLE_TOUCH_DELAYS
    for (UIGestureRecognizer *g in _window.gestureRecognizers)
    {
        g.delaysTouchesBegan = false;
    }
#endif
    
    [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
        NSLog(@"WeChatSDK: %@", log);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendAuthRequest) name:sendAuthRequestNotification object:nil];
    [WXApi registerApp:WeiXinID universalLink:UniversalLink];
    
    [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
        NSLog(@"%@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
    }];
    
    if([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }
    else
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIUserNotificationTypeSound)];
    }

    return YES;
}

-(void) userNotificationCenter:(UNUserNotificationCenter*) center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
}

-(void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    ::printf("-> applicationDidEnterBackground()\n");
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    ::printf("-> applicationWillEnterForeground()\n");

    // applicationWillEnterForeground: might sometimes arrive *before* actually initing unity (e.g. locking on startup)
    if (_unityAppReady)
    {
        // if we were showing video before going to background - the view size may be changed while we are in background
        [GetAppController().unityView recreateRenderingSurfaceIfNeeded];
    }
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    ::printf("-> applicationDidBecomeActive()\n");

    [self removeSnapshotView];

    if (_unityAppReady)
    {
        if (UnityIsPaused() && _wasPausedExternal == false)
        {
            UnityWillResume();
            UnityPause(0);
        }
        if (_wasPausedExternal)
        {
            if (UnityIsFullScreenPlaying())
                TryResumeFullScreenVideo();
        }
        UnitySetPlayerFocus(1);
    }
    else if (!_startUnityScheduled)
    {
        _startUnityScheduled = true;
        [self performSelector: @selector(startUnity:) withObject: application afterDelay: 0];
    }

    _didResignActive = false;
}

- (void)removeSnapshotView
{
    // do this on the main queue async so that if we try to create one
    // and remove in the same frame, this always happens after in the same queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_snapshotView)
        {
            [_snapshotView removeFromSuperview];
            _snapshotView = nil;

            // Make sure that the keyboard input field regains focus after the application becomes active.
            [[KeyboardDelegate Instance] becomeFirstResponder];
        }
    });
}

- (void)applicationWillResignActive:(UIApplication*)application
{
    ::printf("-> applicationWillResignActive()\n");

    if (_unityAppReady)
    {
        UnitySetPlayerFocus(0);

        _wasPausedExternal = UnityIsPaused();
        if (_wasPausedExternal == false)
        {
            // Pause Unity only if we don't need special background processing
            // otherwise batched player loop can be called to run user scripts.
            if (!UnityGetUseCustomAppBackgroundBehavior())
            {
                // Force player to do one more frame, so scripts get a chance to render custom screen for minimized app in task manager.
                // NB: UnityWillPause will schedule OnApplicationPause message, which will be sent normally inside repaint (unity player loop)
                // NB: We will actually pause after the loop (when calling UnityPause).
                UnityWillPause();
                [self repaint];
                UnityPause(1);

                // this is done on the next frame so that
                // in the case where unity is paused while going
                // into the background and an input is deactivated
                // we don't mess with the view hierarchy while taking
                // a view snapshot (case 760747).
                dispatch_async(dispatch_get_main_queue(), ^{
                    // if we are active again, we don't need to do this anymore
                    if (!_didResignActive)
                    {
                        return;
                    }

                    _snapshotView = [self createSnapshotView];
                    if (_snapshotView)
                        [_rootView addSubview: _snapshotView];
                });
            }
        }
    }

    _didResignActive = true;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    ::printf("WARNING -> applicationDidReceiveMemoryWarning()\n");
    UnityLowMemory();
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    ::printf("-> applicationWillTerminate()\n");

    Profiler_UninitProfiler();

    if (_unityAppReady)
    {
        UnityCleanup();
    }

    extern void SensorsCleanup();
    SensorsCleanup();
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}
-(BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    gStrURL = [url absoluteString];

    return [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

- (void)onReq:(BaseReq *)req // ????????????,?????????
{
    
}

- (void)onResp:(BaseResp *)resp // ???????????sendReq???,??onResp????
{
    if([resp isKindOfClass:[SendAuthResp class]]) // ????
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
	if(temp.errCode != 0)
		SimpleFeedback("LoginResult", -5, temp.errCode);
	else {
		NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithCapacity:2];
		[dictData setObject:[NSNumber numberWithInt:0] forKey:@"result"];
		[dictData setObject:temp.code forKey:@"token"];
		[dictData setObject:WeiXinID forKey:@"appid"];

		UnityFeedback("LoginResult", dictData);
	}

        /*if(temp.errCode != 0) {
            if(temp.errStr != NULL)
                UnitySendMessage(GameObjectName, FailMethodName, [temp.errStr cStringUsingEncoding:NSUTF8StringEncoding]);
            else {
                NSString *str = [NSString stringWithFormat:@"%d", temp.errCode];
                UnitySendMessage(GameObjectName, FailMethodName, [str UTF8String]);
            }
        } else
            UnitySendMessage(GameObjectName, LoginMethodName, [temp.code cStringUsingEncoding:NSUTF8StringEncoding]);*/
    }
    else if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
    	if(resp.errCode != 0)
		SimpleFeedback("ShareResult", -5, resp.errCode);
	else
		SimpleFeedback("ShareResult", 0, 0);

        /*if(resp.errCode != 0) {
            if(resp.errStr != NULL)
                UnitySendMessage(GameObjectName, WeChatShareMethodName, [resp.errStr cStringUsingEncoding:NSUTF8StringEncoding]);
            else {
                NSString *str = [NSString stringWithFormat:@"%d", resp.errCode];
                UnitySendMessage(GameObjectName, WeChatShareMethodName, [str UTF8String]);
            }
        } else
            UnitySendMessage(GameObjectName, WeChatShareMethodName, [@"OK" cStringUsingEncoding:NSUTF8StringEncoding]);*/
        
        // ??
        /*if(resp.errCode==0)
        {
            NSString *code = [NSString stringWithFormat:@"%d",resp.errCode]; // 0??? -2???
            NSLog(@"SendMessageToWXResp:%@",code);
            UnitySendMessage(GameObjectName, ShareMethod, [code cStringUsingEncoding:NSUTF8StringEncoding]);
        }*/
    }
}

- (void)sendAuthRequest

{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    
    req.scope = @"snsapi_userinfo";
    
    req.state = @"wechat_sdk_demo_test";

    [WXApi sendAuthReq:req viewController:_rootController delegate:self completion:^(BOOL success) {
        if(success)
            UnitySendMessage(GameObjectName, [@"Log" UTF8String], [@"wx send auth success" UTF8String]);
        else
            UnitySendMessage(GameObjectName, [@"LogError" UTF8String], [@"wx send auth failed" UTF8String]);
    }];
}

@end


void AppController_SendNotification(NSString* name)
{
    [[NSNotificationCenter defaultCenter] postNotificationName: name object: GetAppController()];
}

void AppController_SendNotificationWithArg(NSString* name, id arg)
{
    [[NSNotificationCenter defaultCenter] postNotificationName: name object: GetAppController() userInfo: arg];
}

void AppController_SendUnityViewControllerNotification(NSString* name)
{
    [[NSNotificationCenter defaultCenter] postNotificationName: name object: UnityGetGLViewController()];
}

void AppController_QueryingCityName(float inlatitude, float inlongitude)
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:inlatitude longitude:inlongitude];
    
    [GetAppController().geocoder reverseGeocodeLocation:location completionHandler: ^(NSArray *placemarks, NSError *error) {
        if(error || placemarks.count <= 0) {
        } else {
            /*for(CLPlacemark *placemark in placemarks) {
             NSDictionary *addressDic = placemark.addressDictionary;
             NSString *state=[addressDic objectForKey:@"State"];
             NSString *city=[addressDic objectForKey:@"City"];
             
             [self stopLocation];
             }*/
            
            CLPlacemark *placemark = placemarks.firstObject;
            NSDictionary *addressDic = placemark.addressDictionary;
            NSString *state=[addressDic objectForKey:@"State"];
            NSString *city=[addressDic objectForKey:@"City"];
	    NSString *thoroughfare=[addressDic objectForKey:@"Thoroughfare"];
	    NSString *address = [NSString stringWithFormat:@"%@%@", city, thoroughfare];

            UnitySendMessage(GameObjectName, UpdateCityName, [address UTF8String]);
        }
    }];
}

void AppController_CallingScheme(NSString *scheme)
{
    [GetAppController() CallingScheme:scheme];
}

int AppController_CallingCamera()
{
    return [GetAppController() CallingCamera];
}
int AppController_CallingPhoto()
{
    return [GetAppController() CallingPhoto];
}

extern "C" UIWindow*            UnityGetMainWindow()        {
    return GetAppController().mainDisplay.window;
}
extern "C" UIViewController*    UnityGetGLViewController()  {
    return GetAppController().rootViewController;
}
extern "C" UIView*              UnityGetGLView()            {
    return GetAppController().unityView;
}
extern "C" ScreenOrientation    UnityCurrentOrientation()   { return GetAppController().unityView.contentOrientation; }


bool LogToNSLogHandler(LogType logType, const char* log, va_list list)
{
    NSLogv([NSString stringWithUTF8String: log], list);
    return true;
}

static void AddNewAPIImplIfNeeded();

// From https://stackoverflow.com/questions/4744826/detecting-if-ios-app-is-run-in-debugger
static bool isDebuggerAttachedToConsole(void)
// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;

    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.

    info.kp_proc.p_flag = 0;

    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.

    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();

    // Call sysctl.

    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);

    // We're being debugged if the P_TRACED flag is set.

    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

void UnityInitTrampoline()
{
    InitCrashHandling();

    NSString* version = [[UIDevice currentDevice] systemVersion];
#define CHECK_VER(s) [version compare: s options: NSNumericSearch] != NSOrderedAscending
    _ios81orNewer  = CHECK_VER(@"8.1"),  _ios82orNewer  = CHECK_VER(@"8.2"),  _ios83orNewer  = CHECK_VER(@"8.3");
    _ios90orNewer  = CHECK_VER(@"9.0"),  _ios91orNewer  = CHECK_VER(@"9.1");
    _ios100orNewer = CHECK_VER(@"10.0"), _ios101orNewer = CHECK_VER(@"10.1"), _ios102orNewer = CHECK_VER(@"10.2"), _ios103orNewer = CHECK_VER(@"10.3");
    _ios110orNewer = CHECK_VER(@"11.0"), _ios111orNewer = CHECK_VER(@"11.1"), _ios112orNewer = CHECK_VER(@"11.2");

#undef CHECK_VER

    AddNewAPIImplIfNeeded();

#if !TARGET_IPHONE_SIMULATOR
    // Use NSLog logging if a debugger is not attached, otherwise we write to stdout.
    if (!isDebuggerAttachedToConsole())
        UnitySetLogEntryHandler(LogToNSLogHandler);
#endif
}

extern "C" bool UnityiOS81orNewer() { return _ios81orNewer; }
extern "C" bool UnityiOS82orNewer() { return _ios82orNewer; }
extern "C" bool UnityiOS90orNewer() { return _ios90orNewer; }
extern "C" bool UnityiOS91orNewer() { return _ios91orNewer; }
extern "C" bool UnityiOS100orNewer() { return _ios100orNewer; }
extern "C" bool UnityiOS101orNewer() { return _ios101orNewer; }
extern "C" bool UnityiOS102orNewer() { return _ios102orNewer; }
extern "C" bool UnityiOS103orNewer() { return _ios103orNewer; }
extern "C" bool UnityiOS110orNewer() { return _ios110orNewer; }
extern "C" bool UnityiOS111orNewer() { return _ios111orNewer; }
extern "C" bool UnityiOS112orNewer() { return _ios112orNewer; }

// sometimes apple adds new api with obvious fallback on older ios.
// in that case we simply add these functions ourselves to simplify code
static void AddNewAPIImplIfNeeded()
{
    if (![[CADisplayLink class] instancesRespondToSelector: @selector(setPreferredFramesPerSecond:)])
    {
        IMP CADisplayLink_setPreferredFramesPerSecond_IMP = imp_implementationWithBlock(^void(id _self, NSInteger fps) {
            typedef void (*SetFrameIntervalFunc)(id, SEL, NSInteger);
            UNITY_OBJC_CALL_ON_SELF(_self, @selector(setFrameInterval:), SetFrameIntervalFunc, (int)(60.0f / fps));
        });
        class_replaceMethod([CADisplayLink class], @selector(setPreferredFramesPerSecond:), CADisplayLink_setPreferredFramesPerSecond_IMP, CADisplayLink_setPreferredFramesPerSecond_Enc);
    }

    if (![[UIScreen class] instancesRespondToSelector: @selector(maximumFramesPerSecond)])
    {
        IMP UIScreen_MaximumFramesPerSecond_IMP = imp_implementationWithBlock(^NSInteger(id _self) {
            return 60;
        });
        class_replaceMethod([UIScreen class], @selector(maximumFramesPerSecond), UIScreen_MaximumFramesPerSecond_IMP, UIScreen_maximumFramesPerSecond_Enc);
    }

    if (![[UIView class] instancesRespondToSelector: @selector(safeAreaInsets)])
    {
        IMP UIView_SafeAreaInsets_IMP = imp_implementationWithBlock(^UIEdgeInsets(id _self) {
            return UIEdgeInsetsZero;
        });
        class_replaceMethod([UIView class], @selector(safeAreaInsets), UIView_SafeAreaInsets_IMP, UIView_safeAreaInsets_Enc);
    }
}
