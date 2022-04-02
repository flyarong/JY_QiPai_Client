#import "IOSAlbumCameraController.h"
#define GameObjectName "SDK_callback"
@implementation IOSAlbumCameraController
- (void)leftAction
{
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}

- (void)rightAction
{
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
-(void)OpenCamera:(UIImagePickerControllerSourceType)type{
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    //创建UIImagePickerController实例
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //设置代理
    picker.delegate = self;
    //是否允许编辑 (默认为NO)
    picker.allowsEditing = YES;
    //设置照片的来源
    picker.sourceType = type;
    //展示选取照片控制器
    //if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary &&[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        picker.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popover = picker.popoverPresentationController;
        //picker.preferredContentSize = [UIScreen mainScreen].bounds.size;
        popover.delegate = self;
        popover.sourceRect = CGRectMake(0, 0, 0, 0);
        popover.sourceView = self.view;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:picker animated:YES completion:nil];
   // } else {
    //    [self presentViewController:picker animated:YES completion:^{}];
  //  }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (image == nil) {
        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    }
    //图片旋转
    if (image.imageOrientation != UIImageOrientationUp) {
        //图片旋转
        image = [self fixOrientation:image];
    }
    NSString *imagePath = [self GetSavePath:@"Temp.jpg"];
    [self SaveFileToDoc:image path:imagePath];
}
-(NSString*)GetSavePath:(NSString *)filename{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [pathArray objectAtIndex:0];
    return [docPath stringByAppendingPathComponent:filename];
}
-(void)SaveFileToDoc:(UIImage *)image path:(NSString *)path{
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    UnitySendMessage( GameObjectName, [@"PicCallFunc" UTF8String], [@"Temp.jpg" UTF8String]);
    // UnitySendMessage("MainScriptHolder", "PicCallFunc", "Temp.jpg");
    NSData *data;
    if (UIImagePNGRepresentation(image)==nil) {
        data = UIImageJPEGRepresentation(image, 1);
    }else{
        data = UIImagePNGRepresentation(image);
    }
    [data writeToFile:path atomically:YES];
}
// 打开相册后点击“取消”的响应
- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    NSLog(@" --- imagePickerControllerDidCancel !!");
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    UnitySendMessage( GameObjectName, [@"PicCallFunc" UTF8String], [@"" UTF8String]);
    // UnitySendMessage( "MainScriptHolder", "PicCallFunc", (@"").UTF8String);
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 图片处理方法
//图片旋转处理
- (UIImage *)fixOrientation:(UIImage *)aImage {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(void) saveImageToPhotosAlbum:(NSString*) readAdr
{
    NSLog(@"readAdr: ");
    NSLog(readAdr);
    UIImage* image = [UIImage imageWithContentsOfFile:readAdr];
    UIImageWriteToSavedPhotosAlbum(image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   NULL);
}

+(void) image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    NSString* result;
    if(error)
    {
        result = @"图片保存到相册失败!";
    }
    else
    {
        result = @"图片保存到相册成功!";
    }
    NSLog(@"didFinishSavingWithError: ");
    NSLog(result);
    UnitySendMessage( GameObjectName, [@"SaveImageToPhotosAlbumCallBack" UTF8String], result.UTF8String);

    // if(success)
    //     UnitySendMessage(GameObjectName, [@"Log" UTF8String], [@"wx send url success" UTF8String]);
    // else
    //     UnitySendMessage(GameObjectName, [@"LogError" UTF8String], [@"wx send url failed" UTF8String]);        
}
//videoPath为视频下载到本地之后的本地路径
+ (void)saveVideo:(NSString *)videoPath{
    
    NSLog(@"路径:%@",videoPath);
    if (videoPath) {
        NSURL *url = [NSURL URLWithString:videoPath];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) == NO) {
            NSLog(@"可以保存 ");
        }
        else
        {  NSLog(@"不可以保存 ");
        }
        //保存相册核心代码
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, @selector(savedVedioImage:didFinishSavingWithError:contextInfo:), nil);
    }
}
//保存视频完成之后的回调
+ (void) savedVedioImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    NSString* result;
    if (error) {
        result =@"视频保存失败";
    }
    else {
        result =@"保存视频成功";
    }
    UnitySendMessage( GameObjectName, [@"SaveVedioToPhotosAlbumCallBack" UTF8String], result.UTF8String);
    // UnitySendMessage( "MainScriptHolder", "SaveVedioToPhotosAlbumCallBack", result.UTF8String);
}
@end

#if defined (__cplusplus)
extern "C" {
#endif
    // 打开相册
    void _OpenPhotoAlbums()
    {
        IOSAlbumCameraController *app = [[IOSAlbumCameraController alloc]init];
        UIViewController *vc = UnityGetGLViewController();
        [vc.view addSubview:app.view];
        [app OpenCamera:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    void _SaveImageToPhotosAlbum(char* readAddr)
    {
        NSString* temp = [NSString stringWithUTF8String:readAddr];
        [IOSAlbumCameraController saveImageToPhotosAlbum:temp];
    }
    
    void _SaveVideoToPhotosAlbum(char* readAddr)
    {
        NSString* temp = [NSString stringWithUTF8String:readAddr];
        [IOSAlbumCameraController saveVideo:temp];
    }
    
#if defined (__cplusplus)
}
#endif