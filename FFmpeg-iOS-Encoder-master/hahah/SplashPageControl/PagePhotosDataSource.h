//
//  PagePhotosDataSource.h
//
//  Created by wangyong on 10-8-23.
//  Copyright 2010 wangyong. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PagePhotosDataSource

- (int)numberOfPages;

- (UIImage *)imageAtIndex:(int)index;

- (void)changeRootViewController:(UIViewController*)viewController;

@end
