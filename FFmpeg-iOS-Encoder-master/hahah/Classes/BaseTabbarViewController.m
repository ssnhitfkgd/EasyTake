    //
//  BaseTabbarViewController.m
//  
//
//  Created by yongwang on 12/15/10.
//
// Copyright (c) 2011 yongwang
//
#import "BaseTabbarViewController.h"


@implementation BaseTabbarViewController

// Create a view controller and setup it's tab bar item with a title and image
- (UINavigationController*)viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image viewClass:(NSString*)viewClass
{   
       
    Class viewControllerClass = NSClassFromString(viewClass);
    
    UIViewController* viewController = [[[viewControllerClass alloc] init] autorelease];
    viewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
  
    return navigationController;
}

- (UIViewController*)viewControllerWithSubClass:(NSString*)viewClass
{   
    Class viewControllerClass = NSClassFromString(viewClass);
    UIViewController* viewController = [[[viewControllerClass alloc] init] autorelease];
    return viewController;
}

// Create a custom UIButton and add it to the center of our tab bar
- (void)addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];

    [button addTarget:self action:@selector(centerBtnTape:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
    {
        button.center = self.tabBar.center;
    }
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }

    [self.view addSubview:button];
}

- (void)centerBtnTape:(id)sender
{
    UIViewController* viewController = [[[NSClassFromString(@"RosyWriterViewController") alloc] init] autorelease];
    [self presentModalViewController:viewController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
