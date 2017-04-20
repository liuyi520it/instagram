//
//  VideoPlayerController.m
//  instagramDemo
//
//  Created by jishubu on 17/1/22.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "VideoPlayerController.h"

@implementation VideoPlayerController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self fileHandle];
    });
    
    self.repeatButton.hidden = YES;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep)];
    self.navigationItem.rightBarButtonItem = rightButton;

    self.player = self.videoPlayerView.player;
    
    if (self.asset != nil) {
        [self.player setItemByAsset:self.asset];
        //        [player setSmoothLoopItemByAsset:self.asset smoothLoopCount:10];
    }
    
    self.player.shouldLoop = YES;
    [self.player play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
- (void) playReachedEnd:(NSNotification*)notification {
    if (notification.object == self.player.currentItem) {
        self.repeatButton.hidden = NO;
    }
}
-(void)fileHandle{
    // input file
    AVAsset* asset = [AVAsset assetWithURL:self.outPutUrl];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    [composition  addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // input clip
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    // make it square
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.width, clipVideoTrack.naturalSize.width);
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30) );
    
    // rotate to portrait
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    //            CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.height - clipVideoTrack.naturalSize.height) /2 );
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(0,0);
    CGAffineTransform t2 = CGAffineTransformRotate(t1, 0);
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    // export
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputFileType=AVFileTypeQuickTimeMovie;
    long timeInterval =  (long)[[NSDate date] timeIntervalSince1970];
    NSURL *output = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%ld%@", NSTemporaryDirectory(), timeInterval, @"NewVideo.mp4"]];
    exporter.outputURL = output;
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        UISaveVideoAtPathToSavedPhotosAlbum(output.path, nil, nil, nil);
        self.outPutUrl =output;
         NSLog(@"异步不阻塞------%@",self.outPutUrl);
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
-(void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)nextStep{
    NSLog(@"%@",self.outPutUrl);  //下一步参数获取本地路径
}
-(IBAction)repeat:(id)button{
    UIButton *btn =(UIButton *)button;
    btn.hidden = YES;
    if (self.asset != nil) {
        [self.player setItemByAsset:self.asset];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
    [self.player play];
}
@end
