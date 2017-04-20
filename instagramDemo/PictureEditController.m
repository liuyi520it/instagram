//
//  PictureEditController.m
//  instagramDemo
//
//  Created by jishubu on 17/1/19.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "PictureEditController.h"
#import "TGAssetsLibrary.h"
#import "TGCameraColor.h"
#import "TGCameraFilterView.h"
#import "UIImage+CameraFilters.h"
@interface PictureEditController ()
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet TGCameraFilterView *filterView;
@property (strong, nonatomic) IBOutlet UIButton *filterButtonOne;
@property (strong, nonatomic) IBOutlet UIButton *filterButtonTwo;
@property (strong, nonatomic) IBOutlet UIButton *filterButtonThree;
@property (strong, nonatomic) IBOutlet UIButton *filterButtonFour;

@property (weak) id<TGCameraDelegate> delegate;
@property (strong, nonatomic) UIView *detailFilterView;



- (IBAction)defaultFilterTapped:(UIButton *)button;
- (IBAction)satureFilterTapped:(UIButton *)button;
- (IBAction)curveFilterTapped:(UIButton *)button;
- (IBAction)vignetteFilterTapped:(UIButton *)button;

- (void)addDetailViewToButton:(UIButton *)button;
+ (instancetype)newController;

@end



@implementation PictureEditController

+ (instancetype)newWithDelegate:(id<TGCameraDelegate>)delegate photo:(UIImage *)photo
{
    PictureEditController *viewController = [PictureEditController newController];
    
    if (viewController) {
        viewController.delegate = delegate;
        viewController.photo = photo;
    }
    
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _photoView.clipsToBounds = YES;
    _photoView.image = _photo;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self addDetailViewToButton:self.filterButtonOne];
//    [self.filterButtonFour setImage:_photo forState:UIControlStateNormal];
//    [self.filterButtonOne setImage:[_photo saturateImage:1.8 withContrast:1] forState:UIControlStateNormal];
//    [self.filterButtonTwo setImage:[_photo curveFilter] forState:UIControlStateNormal];
//    [self.filterButtonThree setImage:[_photo vignetteWithRadius:0 intensity:6] forState:UIControlStateNormal];
}
-(void)dismiss{
    [self.tabBarController dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
-(void)nextStep{

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -
#pragma mark - Filter view actions

- (IBAction)defaultFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    _photoView.image = _photo;
}

- (IBAction)satureFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    _photoView.image = [_photo saturateImage:1.8 withContrast:1];
}

- (IBAction)curveFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    _photoView.image = [_photo curveFilter];
}

- (IBAction)vignetteFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    _photoView.image = [_photo vignetteWithRadius:0 intensity:6];
}

#pragma mark -
#pragma mark - Private methods
- (void)addimageViewToButton:(UIImage *)image{

}
- (void)addDetailViewToButton:(UIButton *)button
{
    [_detailFilterView removeFromSuperview];
    
    CGFloat height = 2.5;
    
    CGRect frame = button.frame;
    frame.size.height = height;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(button.frame) - height;
    
    _detailFilterView = [[UIView alloc] initWithFrame:frame];
    _detailFilterView.backgroundColor = [TGCameraColor orangeColor];
    _detailFilterView.userInteractionEnabled = NO;
    
    [button addSubview:_detailFilterView];
}

+ (instancetype)newController
{
    return [super new];
}
@end