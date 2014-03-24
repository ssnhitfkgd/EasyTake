//
//  BaseViewController.h
//  RosyWriter
//
//  Created by wangyong on 13-1-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, retain) NSString *moivePath;


- (void)showLoginView;
- (void)drawNavigationBar:(UINavigationBar*)navigationBar;
@end
