//
//  VideoPlayerController.h
//  instagramDemo
//
//  Created by jishubu on 17/1/22.
//  Copyright © 2017年 wx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoPlayerView.h"
@interface VideoPlayerController : UIViewController
@property (weak, nonatomic) IBOutlet SCVideoPlayerView *videoPlayerView;
@property (strong, nonatomic)SCPlayer *player;
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) NSURL *outPutUrl;
@property (weak, nonatomic)IBOutlet UIButton *repeatButton;
@property (weak, nonatomic)IBOutlet UIImageView *repeatImage;
-(IBAction)repeat:(id)button;
@end
