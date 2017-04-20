//
//  VoiceController.h
//  instagramDemo
//
//  Created by jishubu on 17/1/19.
//  Copyright © 2017年 wx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
#import "SCPlayer.h"

@interface VoiceController : UIViewController<SCRecorderDelegate, SCVideoPlayerDelegate>
@property (nonatomic ,weak)IBOutlet UIImageView*imageView;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *gressView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;


- (IBAction)playButtonPressed:(id)sender;
- (IBAction)deletePressed:(id)sender;
@end
