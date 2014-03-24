//
//  AccountViewController.m
//  RosyWriter
//
//  Created by wangyong on 13-1-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"
#import "A3ParallaxScrollView.h"
#import "ProfileViewController.h"
#import "SetPageViewController.h"

@interface AccountViewController ()
@property (nonatomic, strong) UIImageView *viewHeader;
@property (nonatomic, strong) A3ParallaxScrollView *parallaxScrollView;
@property (readwrite, nonatomic,retain) ProfileViewController *profileViewController;
@end

@implementation AccountViewController
@synthesize parallaxScrollView = _parallaxScrollView;
@synthesize viewHeader = _viewHeader;
@synthesize profileViewController = _profileViewController;

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
   
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)]; 
    [imageView setImage:[UIImage imageNamed:@"ProfileViewBk"]];
    [self.view insertSubview:imageView atIndex:0];
  
    
    self.parallaxScrollView = [[A3ParallaxScrollView alloc] initWithFrame:self.view.bounds];
    self.parallaxScrollView.delegate = self;
    [self.view addSubview:self.parallaxScrollView];
    CGSize contentSize = self.parallaxScrollView.frame.size;
    //contentSize.height *= 1.2f;
    
    self.parallaxScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.parallaxScrollView.contentSize = contentSize;
    self.parallaxScrollView.showsVerticalScrollIndicator = NO;
    
    // add header and content
    UIImage *imageHeader = [UIImage imageNamed:@"accountHeader.jpg"];
    self.viewHeader = [[UIImageView alloc] initWithImage:imageHeader];
    [self.viewHeader setFrame:CGRectMake(-30, 0, 380, 300)];
    CGRect headerFrame = CGRectMake(-30, 0, self.viewHeader.size.width, self.viewHeader.size.height);
    headerFrame.origin.y -= 122.0f;
    self.viewHeader.frame = headerFrame;
    [self.parallaxScrollView addSubview:self.viewHeader withAcceleration:CGPointMake(0.0f, 0.5f)];
    
    self.profileViewController = [[ProfileViewController alloc] init];
    [self.parallaxScrollView addSubview:self.profileViewController.view];
    [self.viewHeader setHeight:self.profileViewController.view.height];
    self.profileViewController.view.top = self.viewHeader.bottom - 280;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 20, 20)];
    [button setBackgroundImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onRevealDownMenu) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // reinit the bouncing directions (should not be done in your own implementation, this is just for the sample)
    [self.revealSideViewController setDirectionsToShowBounce:PPRevealSideDirectionBottom | PPRevealSideDirectionLeft | PPRevealSideDirectionRight | PPRevealSideDirectionTop];
}

- (void) onRevealDownMenu {
   
    SetPageViewController *setPageViewController = [[SetPageViewController alloc] init];
    UINavigationController *navigationPageController = [[UINavigationController alloc] initWithRootViewController:setPageViewController];
    
    [self.revealSideViewController pushViewController:navigationPageController onDirection:PPRevealSideDirectionTop withOffset:60.0 animated:YES];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // accelerate header just with half speed down, but with normal speed up
    if (scrollView.contentOffset.y > 0) {
        [self.parallaxScrollView setAcceleration:A3DefaultAcceleration forView:self.viewHeader];
    }else{
        [self.parallaxScrollView setAcceleration:CGPointMake(0.0f, 0.5f) forView:self.viewHeader];
    }
}

@end
