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
@synthesize revealSideViewController = _revealSideViewController;

// Create a view controller and setup it's tab bar item with a title and image
- (id)viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image viewClass:(NSString*)viewClass
{   
       
    Class viewControllerClass = NSClassFromString(viewClass);
    UIViewController* viewController = [[[viewControllerClass alloc] init] autorelease];
    viewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    
    if (title == nil) {
        return navigationController;
    }
    
    FontLabel *fontLabel = [[[FontLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)
                                                    fontName:@"Schwarzwald Regular" pointSize:24.0f] autorelease];
	fontLabel.textColor = [UIColor blackColor];
	fontLabel.textAlignment = UITextAlignmentCenter;
	fontLabel.lineBreakMode = UILineBreakModeTailTruncation;
	fontLabel.backgroundColor = [UIColor clearColor];
	fontLabel.numberOfLines = 0;
    viewController.navigationItem.titleView = fontLabel;
    [fontLabel setText: title];
 
    if([viewClass isEqualToString:@"AccountViewController"] && !_revealSideViewController)
    {
        _revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:navigationController];
        [_revealSideViewController.tabBarItem setImage:image];
        [_revealSideViewController.tabBarItem setTitle:title];
        _revealSideViewController.delegate = self;
        return _revealSideViewController;
    }
    
    
    return navigationController;
}

- (UIViewController*)viewControllerWithSubClass:(NSString*)viewClass
{   
    Class viewControllerClass = NSClassFromString(viewClass);
    UIViewController* viewController = [[[viewControllerClass alloc] init] autorelease];
    return viewController;
}


- (void) pprevealSideViewController:(PPRevealSideViewController *)controller willPushController:(UIViewController *)pushedController {
    
}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didPushController:(UIViewController *)pushedController {
    
}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller willPopToController:(UIViewController *)centerController {
    
}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController {
    
}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didChangeCenterController:(UIViewController *)newCenterController {
    
}

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateDirectionGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view {
    return NO;    
}

- (PPRevealSideDirection)pprevealSideViewController:(PPRevealSideViewController*)controller directionsAllowedForPanningOnView:(UIView*)view {
    
    if ([view isKindOfClass:NSClassFromString(@"UIWebBrowserView")]) return PPRevealSideDirectionLeft | PPRevealSideDirectionRight;
    
    return PPRevealSideDirectionLeft | PPRevealSideDirectionRight | PPRevealSideDirectionTop | PPRevealSideDirectionBottom;
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
    UIViewController* viewController = [[[NSClassFromString(@"CameraViewController") alloc] init] autorelease];
    [self presentModalViewController:viewController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
