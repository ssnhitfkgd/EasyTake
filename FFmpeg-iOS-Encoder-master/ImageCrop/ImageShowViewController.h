//
//  ImageShowViewController.h
//  EasyTake
//
//  Created by wangyong on 13-1-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYImageCropper.h"

@interface ImageShowViewController : UIViewController {
    WYImageCropper *imageCropper;
    UILabel *boundsText;
    dispatch_queue_t dealImage_queue;
}

@property (nonatomic, strong) UILabel *boundsText;
@property (nonatomic, strong) UIImage *selImage;
@property (nonatomic, strong) WYImageCropper *imageCropper;
@property (nonatomic, strong) UIImageView *preview;

- (id)initWithImage:(UIImage*)image;

@end
