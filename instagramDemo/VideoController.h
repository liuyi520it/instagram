//
//  VideoController.h
//  instagramDemo
//
//  Created by jishubu on 17/1/19.
//  Copyright © 2017年 wx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorderFocusView.h"

@interface VideoController : UIViewController

@property (nonatomic, copy) void(^cropBlock)(UIImage *image);
@property (strong, nonatomic) SCRecorderFocusView *focusView;
@end
