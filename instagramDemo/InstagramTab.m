//
//  InstagramTab.m
//  instagramDemo
//
//  Created by jishubu on 17/1/19.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "InstagramTab.h"
#import "VideoController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation InstagramTab
-(void)viewDidLoad{
    [super viewDidLoad];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0xCFCFCF), NSForegroundColorAttributeName, [UIFont fontWithName:@"Helvetica" size:18.0f],NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Helvetica" size:18.0f],NSFontAttributeName,nil] forState:UIControlStateSelected];
}
@end
