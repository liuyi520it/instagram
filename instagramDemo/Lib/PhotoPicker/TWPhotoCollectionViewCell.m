//
//  TWPhotoCollectionViewCell.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWPhotoCollectionViewCell.h"

@implementation TWPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.layer.borderColor = [UIColor blueColor].CGColor;
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-60,self.bounds.size.height-25 , 50, 20)];
        self.durationLabel.font = [UIFont systemFontOfSize:12.];
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.durationLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.imageView.layer.borderWidth = selected ? 0.5 : 0;
}

@end
