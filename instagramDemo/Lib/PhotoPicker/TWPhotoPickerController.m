//
//  TWPhotoPickerController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TWPhotoPickerController.h"
#import "TWPhotoCollectionViewCell.h"
#import "TWImageScrollView.h"
#import "PictureFilterController.h"
#import "ImageUtil.h"

@interface TWPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    BOOL videoFlag;
}
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIImageView *maskView;
@property (strong, nonatomic) TWImageScrollView *imageScrollView;

@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSURL *outPutUrl;
@end

@implementation TWPhotoPickerController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.topView];
    [self.view insertSubview:self.collectionView belowSubview:self.topView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep)];
    self.navigationItem.rightBarButtonItem = rightButton;
    videoFlag = NO;
    [self loadPhotos];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.imageScrollView.scrollAsset!=nil) {
        [self.imageScrollView.player play];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.imageScrollView.scrollAsset!=nil) {
        [self.imageScrollView.player pause];
    }
    
}
-(void)dismiss{
    [self.tabBarController dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
-(void)nextStep{
    if (videoFlag) {
        NSLog(@"%@",self.outPutUrl);
    }else{
        PictureFilterController *pasterVC = [[PictureFilterController alloc]init];
        pasterVC.originalImage = [self imageWithImageSimple:[self.imageScrollView capture] scaledToSize:CGSizeMake(self.imageScrollView.imageView.frame.size.width, self.imageScrollView.imageView.frame.size.width)];
        pasterVC.trimImage = [self imageWithImageSimple:[self.imageScrollView capture] scaledToSize:CGSizeMake(100, 100)];
        pasterVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pasterVC animated:YES];
    }
}
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (NSMutableArray *)assets {
    if (_assets == nil) {
        _assets = [[NSMutableArray alloc] init];
    }
    return _assets;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (void)loadPhotos {
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [self.assets insertObject:result atIndex:0];
        }
        
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allAssets];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
            }
        }
        
        if (group == nil) {
            if (self.assets.count) {
                ALAsset *result = [self.assets objectAtIndex:0];
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:@"ALAssetTypeVideo"]) {
                    videoFlag = YES;
                    AVAsset *avasset = [AVAsset assetWithURL:result.defaultRepresentation.url];
                    self.outPutUrl =result.defaultRepresentation.url;
                    [self.imageScrollView displayVideo:avasset];
                    self.imageScrollView.scrollEnabled  = NO;
                }else{
                    videoFlag = NO;
                    UIImage *image = [UIImage imageWithCGImage:[[[self.assets objectAtIndex:0] defaultRepresentation] fullScreenImage]];
                    [self.imageScrollView displayImage:image];
                    self.imageScrollView.scrollEnabled  = YES;
                }
            }
            [self.collectionView reloadData];
        }
        
        
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:^(NSError *error) {
        NSLog(@"Load Photos Error: %@", error);
    }];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIView *)topView {
    if (_topView == nil) {
        CGRect rect = CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds));
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.clipsToBounds = YES;
        

        rect = CGRectMake(0, 0, CGRectGetWidth(self.topView.bounds), CGRectGetHeight(self.topView.bounds));
        self.imageScrollView = [[TWImageScrollView alloc] initWithFrame:rect];
        [self.imageScrollView.imageView setFrame:CGRectMake(self.imageScrollView.imageView.frame.origin.x, self.imageScrollView.imageView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.width)];
        [self.imageScrollView setBackgroundColor:[UIColor whiteColor]] ;
        [self.topView addSubview:self.imageScrollView];
        [self.topView sendSubviewToBack:self.imageScrollView];
        
        UIButton *cameraBtn = [[UIButton alloc]init];
        cameraBtn.frame = CGRectMake(self.topView.frame.size.height-60,self.topView.frame.size.height-60,40,40);
        [cameraBtn setImage:[UIImage imageNamed:@"btn_xiangji_normal.png"] forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(cameraClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:cameraBtn];
    }
    return _topView;
}
- (void)cameraClick:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat colum = 4.0, spacing = 2.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
        
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = CGSizeMake(value, value);
        layout.sectionInset                 = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing      = spacing;
        layout.minimumLineSpacing           = spacing;
        
        CGRect rect = CGRectMake(0, CGRectGetMaxY(self.topView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.topView.bounds));
        
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        UIEdgeInsets contentInset = _collectionView.contentInset;
        contentInset.top = -40;
        _collectionView.contentInset = contentInset;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[TWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"TWPhotoCollectionViewCell"];
    }
    return _collectionView;
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cropAction {
    if (self.cropBlock) {
        self.cropBlock(self.imageScrollView.capture);
    }
    [self backAction];
}
- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    CGRect topFrame = self.topView.frame;
    topFrame.origin.y = topFrame.origin.y ==44 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 44;
    
    CGRect collectionFrame = self.collectionView.frame;
    collectionFrame.origin.y = CGRectGetMaxY(topFrame);
    collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
    [UIView animateWithDuration:.3f animations:^{
        self.topView.frame = topFrame;
        self.collectionView.frame = collectionFrame;
    }];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TWPhotoCollectionViewCell";
    
    TWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageWithCGImage:[[self.assets objectAtIndex:indexPath.row] thumbnail]];
    ALAsset *result = [self.assets objectAtIndex:indexPath.row];
    for (UIView *view in [cell.contentView subviews]) {
        if ([view.class isSubclassOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:@"ALAssetTypeVideo"]) {

        AVAsset *avasset = [AVAsset assetWithURL:result.defaultRepresentation.url];
        CMTime   time = [avasset duration];
        int seconds = ceil(time.value/time.timescale);
        int minute = 0;
        if (seconds >= 60) {
            int index = seconds / 60;
            minute = index;
            seconds = seconds - index*60;
        }
        if (seconds>=10) {
            cell.durationLabel.text = [NSString stringWithFormat:@"%d:%d",minute,seconds];
        }else{
            cell.durationLabel.text = [NSString stringWithFormat:@"%d:0%d",minute,seconds];
        }
        [cell.contentView addSubview:cell.durationLabel];
    }
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = [UIImage imageWithCGImage:[[[self.assets objectAtIndex:indexPath.row] defaultRepresentation] fullScreenImage]];
//    [self.imageScrollView displayImage:[ImageUtil fixOrientation:image]];
    ALAsset *result = [self.assets objectAtIndex:indexPath.row];
    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:@"ALAssetTypeVideo"]) {
        videoFlag = YES;
        AVAsset *avasset = [AVAsset assetWithURL:result.defaultRepresentation.url];
        self.outPutUrl =result.defaultRepresentation.url;
       [self.imageScrollView displayVideo:avasset];
        self.imageScrollView.scrollEnabled  = NO;
    }else{
        videoFlag = NO;
       [self.imageScrollView displayImage:image];
        self.imageScrollView.scrollEnabled  = YES;
    }
    if (self.topView.frame.origin.y !=44) {
        [self tapGestureAction:nil];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"velocity:%f", velocity.y);
    if (velocity.y >= 2.0 && self.topView.frame.origin.y == 44) {
        [self tapGestureAction:nil];
    }
    if (velocity.y < 2.0 && self.topView.frame.origin.y != 44) {
        [self tapGestureAction:nil];
    }
}

@end
