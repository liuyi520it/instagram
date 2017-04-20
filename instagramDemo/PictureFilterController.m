//
//  PictureFilterController.m
//  instagramDemo
//
//  Created by jishubu on 17/1/21.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "PictureFilterController.h"
#import "YBFilterScrollView.h"
#import "ImageUtil.h"
#define FULL_SCREEN_H [UIScreen mainScreen].bounds.size.height
#define FULL_SCREEN_W [UIScreen mainScreen].bounds.size.width
/**底部的scrollView的高*/
const CGFloat pasterScrollView_H = 120;
/**贴纸直接间隔距离*/
const CGFloat inset_space = 15;

@interface PictureFilterController ()< YBFilterScrollViewDelegate>
{
    NSInteger defaultIndex;
    NSString* _name;
}
/**上部的图片imageView*/
@property (nonatomic, strong) UIImageView *pasterImageView;
/**装多个滤镜样式的scrollView*/
@property (nonatomic, strong) YBFilterScrollView *filterScrollView;
/**图片数组*/
@property (nonatomic, copy) NSArray *imageArray;
@end
@implementation PictureFilterController
/**
 *  初始化一个对象
 *
 *  @param name 名字
 *
 *  @return 自己
 */
- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if(!self) return self;
    _name = name;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep)];
    self.navigationItem.rightBarButtonItem = rightButton;
    //设置UI
    [self setupUI];
    
}
-(void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)nextStep{
    NSLog(@"%@",self.pasterImageView.image);//传参
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
/**
 *  设置UI
 */
- (void)setupUI
{
    //默认选中“滤镜”位置
    defaultIndex = 0;
    
    UIImageView *pasterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, FULL_SCREEN_W, FULL_SCREEN_W)];
    pasterImageView.image = self.originalImage;
    pasterImageView.userInteractionEnabled = YES;
    [self.view addSubview:pasterImageView];
    self.pasterImageView = pasterImageView;
    
    //底部“滤镜”的scrollView
    [self.view addSubview:self.filterScrollView];
}
/**
 *  懒加载-get方法设置自定义滤镜的scrollView
 */
- (YBFilterScrollView *)filterScrollView
{
    if (!_filterScrollView) {
        _filterScrollView = [[YBFilterScrollView alloc]initWithFrame:CGRectMake(0, FULL_SCREEN_W+(FULL_SCREEN_H - FULL_SCREEN_W)/4, FULL_SCREEN_W, FULL_SCREEN_H - FULL_SCREEN_W)];
        _filterScrollView.backgroundColor = [UIColor whiteColor];
        _filterScrollView.showsHorizontalScrollIndicator = YES;
        _filterScrollView.bounces = YES;
        NSArray *titleArray = @[@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"瑞华",@"淡雅",@"酒红",@"青柠",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色"];
//                NSArray *titleArray = @[@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"瑞华"];
        _filterScrollView.titleArray = titleArray;
        _filterScrollView.filterScrollViewW = pasterScrollView_H;
        _filterScrollView.insert_space = inset_space*2/3;
        _filterScrollView.labelH = 30;
        _filterScrollView.originImage = self.originalImage;
        _filterScrollView.trimImage = self.trimImage;
        _filterScrollView.perButtonW_H = 100;
        
        _filterScrollView.contentSize = CGSizeMake(_filterScrollView.perButtonW_H * titleArray.count + _filterScrollView.insert_space * (titleArray.count + 1), pasterScrollView_H);
        _filterScrollView.filterDelegate = self;
        [_filterScrollView loadScrollView];
    }
    return _filterScrollView;
}
#pragma mark - YBFilterScrollViewDelegate
- (void)filterImage:(UIImage *)editedImage
{
    self.pasterImageView.image = editedImage;
}
/**
 *  测试有返回值的代理
 */
- (NSString *)deliverStr:(NSString *)originalStr
{
    NSString *string;
    string = originalStr;
    return string;
}
@end
