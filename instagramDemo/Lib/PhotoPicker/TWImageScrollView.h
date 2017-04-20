//
//  TWImageScrollView.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoPlayerView.h"


@interface TWImageScrollView : UIScrollView

- (void)displayImage:(UIImage *)image;
- (void)displayVideo:(AVAsset *)asset;  //视频播放

- (UIImage *)capture;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) SCPlayer *player;
@property (strong, nonatomic) SCVideoPlayerView *playerView;
@property (strong, nonatomic) AVAsset *scrollAsset;
@end
