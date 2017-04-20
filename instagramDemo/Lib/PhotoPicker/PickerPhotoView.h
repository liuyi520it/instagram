//
//  PickerPhotoView.h
//  instagramDemo
//
//  Created by jishubu on 17/1/17.
//  Copyright © 2017年 wx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerPhotoView : UIView
@property (nonatomic, copy) void(^cropBlock)(UIImage *image);
@end
