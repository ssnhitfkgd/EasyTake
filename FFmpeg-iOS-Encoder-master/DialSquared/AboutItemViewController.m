//
//  AboutItemViewController.m
//  EasyTake
//
//  Created by wangyong on 13-1-11.
//
//

#import "AboutItemViewController.h"

@interface AboutItemViewController ()

@end

@implementation AboutItemViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    UIImageView *imageBKView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfileViewBk"]];
    [self.view addSubview:imageBKView];
    
    UIImageView * imageView =[[UIImageView alloc] initWithFrame:CGRectMake(136, 40, 44, 44)];
    [imageView setImage:[UIImage imageNamed:@"icon.png"]];
    [self.view addSubview:imageView];
    
    [self createLabel:imageView.bottom + 20 fontSize:14 text:@"             EasyTake   V0.6"];
    
    [self createLabel:imageView.bottom + 64 fontSize:14 text:@"TelPhone ： 13718378010"];
    
    [self createLabel:imageView.bottom + 84 fontSize:14 text:@"QQ       ： 50787460"];

    [self createLabel:imageView.bottom + 104 fontSize:14 text:@"Email    ： ssnhdg－521@163.com"];
 
    
    [self createLabel:imageView.bottom + 210 fontSize:10 text:@"Copyright@ 2012 FootStone All Right Reserver"];

    
 

}

- (void)createLabel:(float)top fontSize:(float)fontSize text:(NSString*)text 
{
    UILabel *labelTemp = [[UILabel alloc] initWithFrame:CGRectMake(58, top, 320, 18)];

    [labelTemp setTextAlignment:UITextAlignmentLeft];
    [labelTemp setTextColor:[UIColor lightTextColor]];
    [labelTemp setShadowColor:[UIColor blackColor]];
    [labelTemp setShadowOffset:CGSizeMake(0,1)];
    [labelTemp setBackgroundColor:[UIColor clearColor]];
    [labelTemp setFont:[UIFont systemFontOfSize:fontSize]];
    [labelTemp setText:text];
    [labelTemp setLineBreakMode:UILineBreakModeWordWrap];
    [self.view addSubview:labelTemp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
