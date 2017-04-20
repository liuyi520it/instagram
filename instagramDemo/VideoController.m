//
//  VideoController.m
//  instagramDemo
//
//  Created by jishubu on 17/1/19.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "VideoController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCRecorder.h"
#import "SCTouchDetector.h"
#import "VideoPlayerController.h"
static int clickRange=70;
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kVideoPreset AVCaptureSessionPresetHigh
@interface VideoController ()<SCRecorderDelegate>
{
    SCRecorder *_recorder;
    BOOL wasLoad;
}
@property (strong, nonatomic) IBOutlet UIView *captureView;

@property (strong, nonatomic) IBOutlet UIButton *flashButton;
@property (strong, nonatomic) IBOutlet UIButton *setModelButton;

@property (strong, nonatomic) IBOutlet UIButton *videoButton;
@property (strong, nonatomic) IBOutlet UIProgressView *gressView;
@property (retain, nonatomic) UIBarButtonItem *rightButton;

- (IBAction)flashTapped:(UIButton *)sender;

@property (nonatomic) BOOL wasLoaded;
@end


@implementation VideoController
- (IBAction)flashTapped:(UIButton *)sender{
        self.navigationItem.rightBarButtonItem = nil;
        if (self.gressView.progress==0) {
            [_recorder switchCaptureDevices];
        }else{
            _recorder.recordSession = nil;
            [self prepareCamera];
            [self updateLabelForSecond:0];
        }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.rightButton = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep)];
    self.navigationItem.rightBarButtonItem = nil;
    
    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = kVideoPreset;
    _recorder.audioEnabled = YES;
    _recorder.delegate = self;
    wasLoad = NO;
    
    [self.videoButton addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        [self prepareCamera];
    }];
}
- (void)recorder:(SCRecorder *)recorder didReconfigureInputs:(NSError *)videoInputError audioInputError:(NSError *)audioInputError {
    NSLog(@"Reconfigured inputs, videoError: %@, audioError: %@", videoInputError, audioInputError);
}


- (void)viewDidAppear:(BOOL)animated {
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_recorder endRunningSession];
}

- (void)updateLabelForSecond:(Float64)totalRecorded {
    [self.gressView setProgress:totalRecorded/8];
    if (totalRecorded==8) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"达到最大录制时间8秒" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)showVideo:(AVAsset*)asset andUrl:(NSURL *)outputUrl {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerController * videoPlayerViewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoPlayerControllerID"];
    videoPlayerViewController.asset = asset;
    videoPlayerViewController.outPutUrl = outputUrl;
    videoPlayerViewController.hidesBottomBarWhenPushed  =YES;
    [self.navigationController pushViewController:videoPlayerViewController animated:YES];
    _recorder.recordSession = nil;
    [self prepareCamera];
    [self updateLabelForSecond:0];
}


- (void) handleReverseCameraTapped:(id)sender {
    [_recorder switchCaptureDevices];
}
- (void)finishSession:(SCRecordSession *)recordSession {
    [recordSession endSession:^(NSError *error) {
        if (error == nil) {
            [self showVideo:[AVURLAsset URLAssetWithURL:recordSession.outputUrl options:nil] andUrl:recordSession.outputUrl];
        } else {
            NSLog(@"Failed to end session: %@", error);
        }
    }];
}

- (void) handleRetakeButtonTapped:(id)sender {
    [self prepareCamera];
    [self updateLabelForSecond:0];
}
- (void) prepareCamera {
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(8, 10000); //设置最大秒 8
        _recorder.recordSession = session;
    }
}

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession {
    [self finishSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginRecordSegment:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didEndRecordSegment:(SCRecordSession *)recordSession segmentIndex:(NSInteger)segmentIndex error:(NSError *)error {
    NSLog(@"End record segment %d: %@", (int)segmentIndex, error);
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {
    [self.gressView setProgress:CMTimeGetSeconds(recordSession.currentRecordDuration)/8];
}

- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
    if (touchDetector.state == UIGestureRecognizerStateBegan) {
        self.setModelButton.hidden = YES;
        [_recorder record];
    } else if (touchDetector.state == UIGestureRecognizerStateEnded) {
//        self.navigationItem.rightBarButtonItem = self.rightButton;
        [_recorder pause];
        [self nextStep];
    }
}
-(void)dismiss{
    [self.tabBarController dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
-(void)nextStep{
    SCRecordSession *recordSession = _recorder.recordSession;
    
    if (recordSession != nil) {
//        self.navigationItem.rightBarButtonItem = nil;
        [self finishSession:recordSession];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"长按录制视频" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
 
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.setModelButton.hidden = NO;
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
