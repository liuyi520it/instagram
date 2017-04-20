//
//  SCTouchDetector.m
//  instagramDemo
//
//  Created by jishubu on 17/1/20.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "SCTouchDetector.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
@implementation SCTouchDetector
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

@end
