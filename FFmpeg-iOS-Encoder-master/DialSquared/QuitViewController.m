//
//  KNThirdViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuitViewController.h"
#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>

@interface QuitViewController ()

@end

@implementation QuitViewController

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

    // You can customize your own semi-modal size
    self.view.frame = CGRectMake(0, 0, 320, 180);
    self.view.backgroundColor = [UIColor colorWithWhite:0.80 alpha:1];

    UILabel * demoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,15, 320, 50)];
    demoLabel.backgroundColor = [UIColor clearColor];
    demoLabel.text = @"注销功能为切换当前帐号,并清除本地缓存\n(退出功能直接退出软件)";
    demoLabel.font = [UIFont systemFontOfSize:12];
    demoLabel.numberOfLines = 3;
    demoLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:demoLabel];

    
    
    UIButton * logoffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoffButton setBackgroundColor:[UIColor redColor]];
    [logoffButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoffButton setTitle:@"注销" forState:UIControlStateNormal];
    [logoffButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    logoffButton.layer.cornerRadius = 10.0f;
    logoffButton.layer.masksToBounds = YES;
    logoffButton.frame = CGRectMake(63, 80, 60, 60);
    [logoffButton addTarget:self
                    action:@selector(quitSystem)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoffButton];
    
    UIButton * quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [quitButton setBackgroundColor:[UIColor redColor]];
    [quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitButton setTitle:@"退出" forState:UIControlStateNormal];
    [quitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    quitButton.layer.cornerRadius = 10.0f;
    quitButton.layer.masksToBounds = YES;
    quitButton.frame = CGRectMake(180, 80, 60, 60);
    [quitButton addTarget:self
                     action:@selector(quitSystem)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quitButton];
    
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.layer.cornerRadius = 10.0f;
    dismissButton.layer.masksToBounds = YES;
    [dismissButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    dismissButton.frame = CGRectMake(5, 5, 30, 30);
    [dismissButton addTarget:self.parentViewController
                      action:@selector(dismissSemiModalView)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
}

- (void)quitSystem
{
    assert(0);
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
