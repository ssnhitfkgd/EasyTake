//
//  ImageShowViewController.m
//  EasyTake
//
//  Created by wangyong on 13-1-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

// preview slows down frame rate (it's generating a new UIImage very frequently)
#define SHOW_PREVIEW YES

#import "ImageShowViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EasyTakeAppdelegate.h"


#ifndef CGWidth
#define CGWidth(rect)                   rect.size.width
#endif

#ifndef CGHeight
#define CGHeight(rect)                  rect.size.height
#endif

#ifndef CGOriginX
#define CGOriginX(rect)                 rect.origin.x
#endif

#ifndef CGOriginY
#define CGOriginY(rect)                 rect.origin.y
#endif

@implementation ImageShowViewController
@synthesize boundsText;
@synthesize imageCropper;
@synthesize preview;
@synthesize selImage;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)updateDisplay {
    //self.boundsText.text = [NSString stringWithFormat:@"(%.1f, %.1f) (%.1f, %.1f)", CGOriginX(self.imageCropper.crop), CGOriginY(self.imageCropper.crop), CGWidth(self.imageCropper.crop), CGHeight(self.imageCropper.crop)];

    dispatch_async(dealImage_queue, ^{
 
         UIImage *image = [self.imageCropper getCroppedImage];
       
         dispatch_async(dispatch_get_main_queue(), ^{
                self.preview.image = image;
    
        });
    });
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self.imageCropper] && [keyPath isEqualToString:@"crop"]) {
        [self updateDisplay];
    }
}

- (id)initWithImage:(UIImage*)image
{
    if(self = [super init])
    {
        self.selImage = image;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (dealImage_queue) {
        dispatch_release(dealImage_queue);
        dealImage_queue = NULL;
    }
       
    dealImage_queue = dispatch_queue_create("dealImage", DISPATCH_QUEUE_SERIAL);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tactile_noise.png"]];
    self.imageCropper = [[WYImageCropper alloc] initWithImage:self.selImage andMaxSize:CGSizeMake(410, 700)];
   [self.view addSubview:self.imageCropper];
    self.imageCropper.center = self.view.center;
    self.imageCropper.top = 0;
    self.imageCropper.imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.imageCropper.imageView.layer.shadowRadius = 3.0f;
    self.imageCropper.imageView.layer.shadowOpacity = 0.8f;
    self.imageCropper.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    
    [self.imageCropper addObserver:self forKeyPath:@"crop" options:NSKeyValueObservingOptionNew context:nil];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 20, 20)];
    [button setBackgroundImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cropImage) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    if (SHOW_PREVIEW) {
        
        Class avatarImageView = NSClassFromString(@"AvatarImageView");
        self.preview = [[avatarImageView alloc] initWithFrame:CGRectMake(0,420,60,60)];
        
        self.preview.image = [self.imageCropper getCroppedImage];
        [[EasyTakeAppdelegate shareInstance].window addSubview:self.preview];
    }
    
    
    [self updateDisplay];
}

- (void)cropImage
{
    if (dealImage_queue) {
		dispatch_release(dealImage_queue);
		dealImage_queue = nil;
	}
    
    
    [self.navigationController dismissModalViewControllerAnimated:NO];
    [self.preview setAlpha:1];
    [self.view setAlpha:1];
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.view setAlpha:.3];
                         [self.preview setAlpha:0.2];
                         [self.preview setCenter:CGPointMake(47, 178) ];
                     }
     
                     completion:^(BOOL finished){
                         [self.preview removeFromSuperview];
                     }
     ];

}

- (void)viewDidUnload
{
    [self setImageCropper:nil];
    [self setBoundsText:nil];
    [self setSelImage:nil];
    [self setPreview:nil];
    
       [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
