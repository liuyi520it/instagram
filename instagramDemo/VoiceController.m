//
//  VoiceController.m
//  instagramDemo
//
//  Created by jishubu on 17/1/19.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "VoiceController.h"
#import "SCTouchDetector.h"
@interface VoiceController () {
    SCRecorder *_recorder;
    int myTime;  //录音时长控制   如果自己测试可以把代码里面的60替换为自己想要的数字
}
@property (nonatomic,strong) NSTimer *myTimer;
@property (strong, nonatomic) SCPlayer * player;
@property (copy, nonatomic) NSURL * fileUrl;

@end

@implementation VoiceController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [self.player endSendingPlayMessages];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep)];
    self.navigationItem.rightBarButtonItem = rightButton;
    myTime = 60;
    self.player = [SCPlayer player];
    self.player.delegate = self;
    [self.player beginSendingPlayMessages];
    
    _recorder = [SCRecorder recorder];
    _recorder.delegate = self;
    _recorder.videoEnabled = NO;
    _recorder.photoEnabled = NO;
    [self.imageView setImage:[UIImage imageNamed:@"shengyin_7.png"]];
    
    
    
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        if (audioError != nil) {
            [self showError:audioError];
        } else {
            [_recorder startRunningSession:nil];
        }
    }];
    [self.recordButton addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self hidePlayControl];
}
- (void) playReachedEnd:(NSNotification*)notification {
    if (notification.object == self.player.currentItem) {
        [self.imageView stopAnimating];
    }
}
- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
    
    if (touchDetector.state == UIGestureRecognizerStateBegan) {
        [self dropFile];
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerMove) userInfo:nil repeats:YES];
        
        SCRecordSession *session = _recorder.recordSession;
        
        if (session == nil) {
            session = [SCRecordSession recordSession];
            session.fileType = AVFileTypeAppleM4A;
            
            _recorder.recordSession = session;
        }
        [_recorder record];
        [self animationAction];
        [self hidePlayControl];
    } else if (touchDetector.state == UIGestureRecognizerStateEnded) {
        [self.myTimer invalidate];
        self.myTimer=nil;
        [self psuseAction];
        [self.imageView stopAnimating];
        [self showPlayControl];
    }
    self.recordButton.selected = _recorder.isRecording;
}
-(void)timerMove{
    myTime --;
    NSLog(@"time : %d",myTime);
    if (myTime == 0) {//停止录音
        [_myTimer invalidate];
        _myTimer=nil;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"录音结束" message:@"最多允许录音60秒" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        alert.delegate=self;
        [alert show];
        [self psuseAction];
        [self.imageView stopAnimating];
        [self showPlayControl];
    }else{
        
    }
}
-(void)animationAction{
    self.imageView.animationImages =
    @[[UIImage imageNamed:@"shengyin_7.png"],
      [UIImage imageNamed:@"shengyin_6.png"],
      [UIImage imageNamed:@"shengyin_5.png"],
      [UIImage imageNamed:@"shengyin_4.png"],
      [UIImage imageNamed:@"shengyin_3.png"],
      [UIImage imageNamed:@"shengyin_2.png"],
      [UIImage imageNamed:@"shengyin_1.png"],];
    self.imageView.animationDuration = 2.0;
    self.imageView.animationRepeatCount = 0;
    [self.imageView startAnimating];
}
-(void)dismiss{
    [self.tabBarController dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
-(void)nextStep{
    NSLog(@"%@",self.fileUrl);
}
- (void)showError:(NSError*)error {
    [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)hidePlayControl {
    self.messageLabel.hidden = NO;
    self.playButton.hidden = YES;
}

- (void)showPlayControl{
    self.messageLabel.hidden = YES;
    self.playButton.hidden = NO;
}

- (void)recorder:(SCRecorder *)recorder didAppendAudioSampleBuffer:(SCRecordSession *)recordSession {
    self.recordTimeLabel.text = [NSString stringWithFormat:@"%.2fs", CMTimeGetSeconds(recordSession.currentRecordDuration)];
    [self.gressView setProgress:CMTimeGetSeconds(recordSession.currentRecordDuration)/60];
}
- (void)psuseAction{
    SCRecordSession *session = _recorder.recordSession;
    
    if (session != nil) {
        _recorder.recordSession = nil;
        [session endSession:^(NSError *error) {
            if (error == nil) {
                self.fileUrl = session.outputUrl;
                [self showPlayControl];
                [self.player setItemByUrl:self.fileUrl];
            } else {
                [self showError:error];
            }
        }];
    }
    /*
     file:///private/var/mobile/Containers/Data/Application/EBAC2238-8099-4433-8F2C-18BABA2A8E00/tmp/1484878895SCVideo.mp4
     */
    [_recorder pause];
    
}

- (IBAction)playButtonPressed:(id)sender {
    [self.imageView startAnimating];
    if (!self.playButton.selected ) {
        [self.player play];
        self.playButton.selected = self.player.isPlaying;
    }else{
        [self.player setItemByUrl:self.fileUrl];
        [self.player play];
    }
}

- (void)videoPlayer:(SCPlayer *)videoPlayer didChangeItem:(AVPlayerItem *)item {
    item = nil;
    [self.imageView stopAnimating];
    [self hidePlayControl];
}

- (void)videoPlayer:(SCPlayer *)videoPlayer didEndLoadingAtItemTime:(CMTime)itemTime {
    [self.imageView stopAnimating];
    [self hidePlayControl];
}
-(void)videoPlayer:(SCPlayer *)videoPlayer didPlay:(Float64)secondsElapsed loopsCount:(NSInteger)loopsCount{
    /*
     AVAssetExportSessionStatusUnknown,
     AVAssetExportSessionStatusWaiting,
     AVAssetExportSessionStatusExporting,
     AVAssetExportSessionStatusCompleted,
     AVAssetExportSessionStatusFailed,
     AVAssetExportSessionStatusCancelled
     */
}
-(void)videoPlayer:(SCPlayer *)videoPlayer didStartLoadingAtItemTime:(CMTime)itemTime{

}
- (IBAction)deletePressed:(id)sender {
    [self dropFile];
}
-(void)dropFile{
    myTime = 60;
    [self.gressView setProgress:0/60];
    self.fileUrl = nil;
    self.recordTimeLabel.text = @"00.00s";
    [self.imageView stopAnimating];
    [self hidePlayControl];
}
@end
