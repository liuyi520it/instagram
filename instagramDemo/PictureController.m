//
//  PictureController.m
//  instagramDemo
//
//  Created by jishubu on 17/1/19.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "PictureController.h"
#import "SCRecorder.h"
#import "TWPhotoPickerController.h"
#import "PictureEditController.h"
#import "PictureFilterController.h"
#import "ImageUtil.h"
#import "SCRecorderFocusView.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kVideoPreset AVCaptureSessionPresetHigh
static int clickRange=70;
@interface PictureController ()<SCRecorderDelegate>{
    SCRecorder *_recorder;
    BOOL wasLoad;
}
@property (strong, nonatomic) SCRecorderFocusView *focusView;
@property (strong, nonatomic) IBOutlet UIView *captureView;
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UIButton *setAssetsButton;
@property (strong, nonatomic) IBOutlet UIButton *setModelButton;
@property (strong, nonatomic) IBOutlet UIButton *shotButton;
@property (retain, nonatomic) UIBarButtonItem *rightButton;

- (IBAction)setAssetsTapped:(UIButton *)sender;  //摄像头变化
- (IBAction)shotTapped:(UIButton *)sender;  //快门
- (IBAction)setModelTapped:(UIButton *)sender;//图库
@end


@implementation PictureController
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.rightButton = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep)];
    self.navigationItem.rightBarButtonItem = nil;
    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = AVCaptureSessionPresetPhoto;
    _recorder.flashMode = SCFlashModeAuto;
    _recorder.photoEnabled = YES;
    _recorder.delegate = self;
    wasLoad = NO;
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
}
- (void) prepareCamera {
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(5, 10000);
        _recorder.recordSession = session;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.photoView setImage:[UIImage imageNamed:@""]];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_recorder.isCaptureSessionOpened) {
        [_recorder startRunningSession:nil];
    }
    if (!wasLoad) {
        wasLoad = YES;
        UIView *previewView = self.captureView;
        _recorder.previewView = previewView;
        CGRect rect =previewView.bounds;
        rect.size.height = rect.size.height-clickRange;
        self.focusView = [[SCRecorderFocusView alloc] initWithFrame:rect];
        self.focusView.recorder = _recorder;
        [previewView addSubview:self.focusView];
        
        self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
        self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_recorder endRunningSession];
}
- (IBAction)setAssetsTapped:(UIButton *)sender{
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
//    photoPicker.hidesBottomBarWhenPushed  =YES;
    [self.navigationController pushViewController:photoPicker animated:YES];
}
- (IBAction)shotTapped:(UIButton *)sender{
    self.shotButton.enabled = NO;
   [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            UIImage *imageNew= [ImageUtil getSubImage:[ImageUtil fixOrientation:image] mCGRect:CGRectMake(0, 0, image.size.width, image.size.width) centerBool:YES];
            [self.photoView setImage:imageNew];
//            self.navigationItem.rightBarButtonItem = self.rightButton;
            [self nextStep];
            self.shotButton.enabled = YES;

        } else {
            NSLog(@"Failed to capture photo");
        }
    }];
}
- (IBAction)setModelTapped:(UIButton *)sender{
    self.navigationItem.rightBarButtonItem = nil;
    if (self.shotButton.enabled ==YES) {
        if (UIImagePNGRepresentation(self.photoView.image) == nil) {
            [_recorder switchCaptureDevices];
        }else{
            [self.photoView setImage:[UIImage imageNamed:@""]];
        }
    }else{
        [_recorder switchCaptureDevices];
    }
}
- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation) deviceOrientation;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        default:
            break;
    }
    
    return result;
}
-(void)dismiss{
    [self.tabBarController dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
-(void)nextStep{
    PictureFilterController *pasterVC = [[PictureFilterController alloc]init];
    pasterVC.originalImage = self.photoView.image;
    pasterVC.trimImage = [self imageWithImageSimple:self.photoView.image scaledToSize:CGSizeMake(100, 100)];
    pasterVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pasterVC animated:YES];

}
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// Focus
- (void)recorderDidStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

- (void)recorderDidEndFocus:(SCRecorder *)recorder {
    [self.focusView hideFocusAnimation];
}
@end
