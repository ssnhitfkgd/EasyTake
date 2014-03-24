//
//  BaseTabbarViewController.h
//  
//
//  Created by yongwang on 12/15/10.
//
// Copyright (c) 2011 yongwang


@interface BaseTabbarViewController : UITabBarController


- (UINavigationController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image viewClass:(NSString*)viewClass;
- (void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;
- (UIViewController*)viewControllerWithSubClass:(NSString*)viewClass;
@end
