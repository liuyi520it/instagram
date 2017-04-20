//
//  PictureFilterController.h
//  instagramDemo
//
//  Created by jishubu on 17/1/21.
//  Copyright © 2017年 wx. All rights reserved.
//

#import <UIKit/UIKit.h>
#define YBWeak(selfName,weakSelf) __weak __typeof(selfName *)weakSelf = self
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
/**传给上个页面图片的block*/
typedef void(^PasterBlock)(UIImage *image);
@interface PictureFilterController : UIViewController
/**传数据的block*/
@property (nonatomic, copy) PasterBlock block;
/**从上页带回来的原始image*/
@property (nonatomic, strong) UIImage *originalImage;

/**从上页带回来的尺寸处理image*/
@property (nonatomic, strong) UIImage *trimImage;
/**
 *  初始化一个对象
 *
 *  @param name 名字
 *
 *  @return 自己
 */
- (instancetype)initWithName:(NSString *)name;
@end
