//
//  BaseViewController.m
//  RosyWriter
//
//  Created by wangyong on 13-1-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomNavigationBar.h"
#import "LoginViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize moivePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ProfileViewBk"]]];
 	// Do any additional setup after loading the view.
}

- (void)showLoginView
{
    //visual func
    __block LoginViewController* loginView = [LoginViewController  showLoginView];
    loginView.title = @"加入我们吧！";
    loginView.hintID = kHintID_Home;
    [loginView showInView:self.view orientation:kHintViewOrientationTop presentation:kHintViewPresentationSlide];
    
}

- (void)drawNavigationBar:(UINavigationBar*)navigationBar
{
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)navigationBar;
    // Set the nav bar's background
    [customNavigationBar setBackgroundWith:[UIImage imageNamed:@"db_navbar_bg.png"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
