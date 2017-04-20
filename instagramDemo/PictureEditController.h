//
//  PictureEditController.h
//  instagramDemo
//
//  Created by jishubu on 17/1/19.
//  Copyright © 2017年 wx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureEditController : UIViewController
+ (instancetype)new __attribute__
((unavailable("[+new] is not allowed, use [+newWithDelegate:photo:]")));

- (instancetype) init __attribute__
((unavailable("[-init] is not allowed, use [+newWithDelegate:photo:]")));

@property (strong, nonatomic) UIImage *photo;@end
