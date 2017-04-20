//
//  TWImageScrollView.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWImageScrollView.h"
#import "TWPhotoPickerController.h"
@interface TWImageScrollView ()<UIScrollViewDelegate>
{
    CGSize _imageSize;
    BOOL onceLoad;
    
}
@property(nonatomic)BOOL zoomOut_In;
@end

@implementation TWImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}
- (void) playReachedEnd:(NSNotification*)notification {
    if ([self getCurrentViewController:self].tabBarController.selectedIndex==0) {
        if (notification.object == self.player.currentItem&&onceLoad) {
            onceLoad = NO;
            if (self.scrollAsset != nil) {
                [self.player setItemByAsset:self.scrollAsset];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
            }
            [self.player play];
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
            
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                onceLoad = YES;
            });
        }
    }
}
#pragma mark - 获取当前view的viewcontroller
- (UIViewController *)getCurrentViewController:(UIView *) currentView
{
    for (UIView* next = [currentView superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

- (UIImage *)capture {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    
    [self drawViewHierarchyInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)displayVideo:(AVAsset *)asset;
{
//    if (asset==nil) {
//        [self.player pause];
//    }else{
        // clear the previous image
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        [self.playerView removeFromSuperview];
        self.playerView = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self.player.currentItem];
        onceLoad = YES;
        self.scrollAsset = nil;
        
        // reset our zoomScale to 1.0 before doing any further calculations
        self.zoomScale = 1.0;
        self.scrollAsset = asset;
        // make a new UIImageView for the new image
        self.playerView = [[SCVideoPlayerView alloc]init];
        [self addSubview:self.playerView];
        self.player = self.playerView.player;
        
        if (asset != nil) {
            [self.player setItemByAsset:asset];
        }
        
        self.player.shouldLoop = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        [self.player play];
        self.playerView.clipsToBounds = NO;
        
        
        CGRect frame = self.playerView.frame;
        frame.size.width = self.bounds.size.width;
        frame.size.height = self.bounds.size.width;
        self.playerView.frame = frame;
        self.contentOffset = CGPointMake(0, 0);
//    }
}
- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    self.scrollAsset = nil;
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.clipsToBounds = NO;
    [self addSubview:self.imageView];
    UITapGestureRecognizer* tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)];//给imageview添加tap手势
    tap.numberOfTapsRequired = 2;//双击图片执行tapGesAction
    self.imageView.userInteractionEnabled=YES;
    [self.imageView addGestureRecognizer:tap];
    _zoomOut_In = YES;//控制点击图片放大或缩小
    
    CGRect frame = self.imageView.frame;
    if (image.size.height > image.size.width) {
        frame.size.width = self.bounds.size.width;
        frame.size.height = (self.bounds.size.width / image.size.width) * image.size.height;
    } else {
        frame.size.height = self.bounds.size.height;
        frame.size.width = (self.bounds.size.height / image.size.height) * image.size.width;
    }
    self.imageView.frame = frame;
    [self configureForImageSize:self.imageView.bounds.size];
}
-(void)tapGesAction:(UIGestureRecognizer*)gestureRecognizer//手势执行事件
{
    float newscale=0.0;
    if (_zoomOut_In) {
        newscale = 0.8;
        _zoomOut_In = NO;
        [self setZoomScale:newscale animated:YES];
    }else
    {
        newscale = 1.0;
        _zoomOut_In = YES;
        [self setZoomScale:newscale animated:YES];
    }
    
//    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
//    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
//    NSLog(@"zoomRect:%@",NSStringFromCGRect(zoomRect));
//    [self zoomToRect:zoomRect animated:YES];//重新定义其cgrect的x和y值
    
}
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    
    zoomRect.origin.x    = center.x;
    
    zoomRect.origin.y    = center.y;
    
    return zoomRect;
}
- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    
    //to center
    if (imageSize.width > imageSize.height) {
        self.contentOffset = CGPointMake(imageSize.width/4, 0);
    } else if (imageSize.width < imageSize.height) {
        self.contentOffset = CGPointMake(0, imageSize.height/4);
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = 1.0;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    self.minimumZoomScale = 0.8;
    self.maximumZoomScale = 2.0;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
