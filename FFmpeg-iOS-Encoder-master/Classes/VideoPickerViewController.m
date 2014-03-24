//
//  VideoPickerViewController.m
//  EasyTake
//
//  Created by wangyong on 13-1-12.
//
//

#import "VideoPickerViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>


@interface VideoPickerViewController ()

@end

@implementation VideoPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBarHidden = YES;

	// Do any additional setup after loading the view.
    self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mediaTypes = [[NSArray alloc] initWithObjects: (__bridge NSString *) kUTTypeMovie, nil];
    self.allowsEditing = YES;
    self.delegate = self;
    self.navigationController.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [self addSomeElements:self];
}


#pragma mark get/show the UIView we want//Find the view we want in camera structure.
-(UIView *)findView:(UIView *)aView withName:(NSString *)name
{
    Class cl = [aView class];
    NSString *desc = [cl description];
    if ([name isEqualToString:desc])
        return aView;
    for (NSUInteger i = 0; i < [aView.subviews count]; i++)
    {
        UIView *subView = [aView.subviews objectAtIndex:i];
        subView = [self findView:subView withName:name];
        if (subView)
            return subView;
    }
    return nil;
}


-(void)addSomeElements:(UIViewController *)viewController
{ //Add the motion view here, PLCameraView and picker.view are both OK
    UIView *PLCameraView=[self findView:self.view withName:@"PLCameraView"];
//    [PLCameraView addSubview:touchView];
//    [self.view addSubview:self.touchView];
//    //You can also try this one. //Add button for Timer capture
//    [PLCameraView addSubview:timerButton];
//    [PLCameraView addSubview:continuousButton];
//    [PLCameraView insertSubview:bottomBarImageView atIndex:1]; //Used to hide the transiton, last added view will be the topest layer
//    [PLCameraView addSubview:myTransitionView]; //Add label to cropOverlay
//    UIView *cropOverlay=[self findView:PLCameraView withName:@"PLCropOverlay"];
//    [cropOverlay addSubview:lblWatermark]; //Get Bottom Bar
    UIView *bottomBar=[self findView:PLCameraView withName:@"PLCropOverlayBottomBar"]; //Get ImageView For Save
    UIImageView *bottomBarImageForSave = [bottomBar.subviews objectAtIndex:0]; //Get Button 0
    UIButton *retakeButton=[bottomBarImageForSave.subviews objectAtIndex:0]; [retakeButton setTitle:@"重拍" forState:UIControlStateNormal]; //Get Button 1
    UIButton *useButton=[bottomBarImageForSave.subviews objectAtIndex:1];
    [useButton setTitle:@"保存" forState:UIControlStateNormal]; //Get ImageView For Camera
    UIImageView *bottomBarImageForCamera = [bottomBar.subviews objectAtIndex:1]; 
    //Set Bottom Bar Image
    UIImage *image=[[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"BottomBar.png"]];
    bottomBarImageForCamera.image=image;
  
    UIButton *cameraButton=[bottomBarImageForCamera.subviews objectAtIndex:0];
    [cameraButton addTarget:self action:@selector(hideTouchView) forControlEvents:UIControlEventTouchUpInside]; //Get Button 1
    UIButton *cancelButton=[bottomBarImageForCamera.subviews objectAtIndex:1];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(hideTouchView) forControlEvents:UIControlEventTouchUpInside];
}
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self dismissModalViewControllerAnimated: YES];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {

    [self dismissModalViewControllerAnimated:NO];
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    // Handle a movie capture
    if (CFStringCompare ((__bridge CFStringRef)mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
//        NSString *moviePath = [[info objectForKey:
//                                UIImagePickerControllerMediaURL] path];
        MPMoviePlayerViewController* theMovie =
        [[MPMoviePlayerViewController alloc] initWithContentURL: [info objectForKey:
                                                                  UIImagePickerControllerMediaURL]];
        
        
        [self presentMoviePlayerViewControllerAnimated:theMovie];
        
        // Register for the playback finished notification
        [[NSNotificationCenter defaultCenter]
         addObserver: self
         selector: @selector(movieFinishedCallback:)
         name: MPMoviePlayerPlaybackDidFinishNotification
         object: theMovie];
        
        
    }
}
// When the movie is done, release the controller.
-(void) movieFinishedCallback: (NSNotification*) callback
{
    [self dismissMoviePlayerViewControllerAnimated];
    
    MPMoviePlayerController* theMovie = [callback object];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: theMovie];
    // Release the movie instance created in playMovieAtURL:
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    viewController.title = @"我的视频";
    navigationController.navigationBarHidden = YES;
   
    
        //[self addSomeElements:viewController]
	
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	
}


@end
