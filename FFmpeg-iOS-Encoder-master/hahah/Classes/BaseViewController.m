//
//  BaseViewController.m
//  RosyWriter
//
//  Created by wangyong on 13-1-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomNavigationBar.h"


@interface BaseViewController ()

@end

@implementation BaseViewController

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
 
 	// Do any additional setup after loading the view.
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
