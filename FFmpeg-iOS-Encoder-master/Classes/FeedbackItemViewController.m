//
//  FeedbackItemViewController.m
//  EasyTake
//
//  Created by wangyong on 13-1-10.
//
//

#import "FeedbackItemViewController.h"

@interface FeedbackItemViewController ()

@end

@implementation FeedbackItemViewController

- (void)viewDidLoad
{
   [self.view setBackgroundColor:COLOR(234,237,250)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paperView"]];
    [imageView setTop:10];
    [imageView setLeft:10];
    [self.view addSubview:imageView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
