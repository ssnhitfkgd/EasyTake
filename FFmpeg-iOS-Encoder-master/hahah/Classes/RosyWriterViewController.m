/*
     File: RosyWriterViewController.m
 Abstract: View controller for camera interface
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (c) 2012 yong wang. All rights reserved.
 
 */

#import <QuartzCore/QuartzCore.h>
#import "RosyWriterViewController.h"
#import "UIImage+vImage.h"
#import "ImageUtil.h"
#import "ColorMatrix.h"

static inline double radians (double degrees) { return degrees * (M_PI / 180); }

@implementation RosyWriterViewController
@synthesize previewImageView;
@synthesize previewView;
@synthesize recordButton;
@synthesize scrollerView;
@synthesize frameImageView;

- (void)updateLabels
{
	if (shouldShowStats) {
		NSString *frameRateString = [NSString stringWithFormat:@"%.2f FPS ", [videoProcessor videoFrameRate]];
 		frameRateLabel.text = frameRateString;
 		[frameRateLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
 		
 		NSString *dimensionsString = [NSString stringWithFormat:@"%d x %d ", [videoProcessor videoDimensions].width, [videoProcessor videoDimensions].height];
 		dimensionsLabel.text = dimensionsString;
 		[dimensionsLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
 		
 		CMVideoCodecType type = [videoProcessor videoType];
 		type = OSSwapHostToBigInt32( type );
 		NSString *typeString = [NSString stringWithFormat:@"%.4s ", (char*)&type];
 		typeLabel.text = typeString;
 		[typeLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
        
        NSString *videoSizeString = [NSString stringWithFormat:@"%.2f K ", (float)([videoProcessor videoSize]/1024)];
 		videoSizeLabel.text = videoSizeString;
 		[videoSizeLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];

        
 	}
 	else {
 		frameRateLabel.text = @"";
 		[frameRateLabel setBackgroundColor:[UIColor clearColor]];
 		
 		dimensionsLabel.text = @"";
 		[dimensionsLabel setBackgroundColor:[UIColor clearColor]];
 		
 		typeLabel.text = @"";
 		[typeLabel setBackgroundColor:[UIColor clearColor]];
        
        videoSizeLabel.text = @"";
        [videoSizeLabel setBackgroundColor:[UIColor clearColor]];
 	}
}

- (UILabel *)labelWithText:(NSString *)text yPosition:(CGFloat)yPosition
{
	CGFloat labelWidth = 200.0;
	CGFloat labelHeight = 40.0;
	CGFloat xPosition = previewView.bounds.size.width - labelWidth - 10;
	CGRect labelFrame = CGRectMake(xPosition, yPosition, labelWidth, labelHeight);
	UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
	[label setFont:[UIFont systemFontOfSize:36]];
	[label setLineBreakMode:UILineBreakModeWordWrap];
	[label setTextAlignment:UITextAlignmentRight];
	[label setTextColor:[UIColor whiteColor]];
	[label setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
	[[label layer] setCornerRadius: 4];
	[label setText:text];
	
	return label;
}

- (void)applicationDidBecomeActive:(NSNotification*)notifcation
{
	// For performance reasons, we manually pause/resume the session when saving a recording.
	// If we try to resume the session in the background it will fail. Resume the session here as well to ensure we will succeed.
	[videoProcessor resumeCaptureSession];
}

// UIDeviceOrientationDidChangeNotification selector
- (void)deviceOrientationDidChange
{
    return;
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	// Don't update the reference orientation when the device orientation is face up/down or unknown.
	if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) )
		[videoProcessor setReferenceOrientation:orientation];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];

    // Initialize the class responsible for managing AV capture session and asset writer
    videoProcessor = [[RosyWriterVideoProcessor alloc] init];
	videoProcessor.delegate = self;

	// Keep track of changes to the device orientation so we can update the video processor
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		
    // Setup and start the capture session
    [videoProcessor setupAndStartCaptureSession];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
	oglView = [[RosyWriterPreviewView alloc] initWithFrame:CGRectZero];
	// Our interface is always in portrait.
	oglView.transform = [videoProcessor transformFromCurrentVideoOrientationToOrientation:UIInterfaceOrientationPortrait];
    [previewView addSubview:oglView];
    [previewView setBackgroundColor:[UIColor blackColor]];
    
    previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 260.0, 100, 100)];
    self.previewImageView.layer.cornerRadius = 8;  
    self.previewImageView.layer.masksToBounds = YES; 
    
    float rotateAngle = M_PI_2;
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
    self.previewImageView.transform = transform;
    //自适应图片宽高比例
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;  
    
    UITapGestureRecognizer *tapRecognize=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTape:)];//调用函数handTap实现点击事件。
    [self.previewImageView setUserInteractionEnabled:YES];
    [self.previewImageView addGestureRecognizer:tapRecognize];
    [self.view addSubview:self.previewImageView];
    
    
    
 	CGRect bounds = CGRectZero;
 	bounds.size = [self.previewView convertRect:self.previewView.bounds toView:oglView].size;
 	oglView.bounds = bounds;
    oglView.center = CGPointMake(previewView.bounds.size.width/2.0, previewView.bounds.size.height/2.0);
 	
 	// Set up labels
 	shouldShowStats = YES;
    m_nImageType = 0;
	
	frameRateLabel = [self labelWithText:@"" yPosition: (CGFloat) 40.0];
	[previewView addSubview:frameRateLabel];
	
	dimensionsLabel = [self labelWithText:@"" yPosition: (CGFloat) 84.0];
	[previewView addSubview:dimensionsLabel];
	
	typeLabel = [self labelWithText:@"" yPosition: (CGFloat) 128.0];
	[previewView addSubview:typeLabel];
    
    videoSizeLabel = [self labelWithText:@"" yPosition: (CGFloat) 172.0];
	[previewView addSubview:videoSizeLabel];
    
    
    scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, oglView.bottom - 100, 320, 60)];
    scrollerView.backgroundColor = [UIColor clearColor];
    scrollerView.indicatorStyle = UIScrollViewIndicatorStyleBlack;//滚动条样式
    scrollerView.showsHorizontalScrollIndicator = NO;
    //显示横向滚动条
    scrollerView.showsVerticalScrollIndicator = NO;//关闭纵向滚动条
    scrollerView.bounces = YES;//取消反弹效果
    //scrollerView.pagingEnabled = YES;//划一屏
    scrollerView.contentSize = CGSizeMake(640, 30);
    
    for(int i = 0;i < 14;i ++)
    {
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.3+46*i, 10, 25, 30)];
        [bgImageView setTag:i];
        UIImage *bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",i]];
        bgImageView.image = bgImage;
        
        UITapGestureRecognizer *tapRecognize=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTapeSelected:)];//调用函数handTap实现点击事件。
        [bgImageView setUserInteractionEnabled:YES];
        [bgImageView addGestureRecognizer:tapRecognize];
        [scrollerView addSubview:bgImageView];
    }
    
    frameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 45, 50)];
    frameImageView.image = [UIImage imageNamed:@"110.png"];
    [scrollerView addSubview:frameImageView];
   
    [self.view addSubview:scrollerView];
    
    
    UIButton *reverseCam = [[UIButton alloc] initWithFrame:CGRectMake(30, 10, 64,30)];
    [reverseCam setImage:[UIImage imageNamed:@"reverseLens"] forState:UIControlStateNormal];
    [reverseCam addTarget:self action:@selector(openLightPush:) forControlEvents:UIControlEventTouchUpInside];
    [reverseCam setTag:1];
    [self.view addSubview:reverseCam];
    
    
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(10, self.view.bottom - 44, 300, 44)];
    
   
    [self.view addSubview:toolBarView];
    UIButton *openFront = [[UIButton alloc] initWithFrame:CGRectMake(30, 10, 64,30)];
    [openFront setImage:[UIImage imageNamed:@"reverseLens"] forState:UIControlStateNormal];
    [openFront addTarget:self action:@selector(openLightPush:) forControlEvents:UIControlEventTouchUpInside];
    [openFront setTag:1];
    [self.view addSubview:openFront];
    
}

- (IBAction)pauseRecording:(id)sender;
{
    [videoProcessor setRecoredPause];
}

- (void)openLightPush:(id)sender
{
    [videoProcessor swapFrontAndBackCameras];
}

- (void)handTapeSelected:(UITapGestureRecognizer *)recognizer
{
    m_nImageType = recognizer.view.tag;
    //[self changeImage:recognizer.view.tag imageSrc:<#(UIImage *)#>]
}

- (void)changeImage:(int)nType imageSrc:(UIImage*)currentImage
{
    switch (nType) {
        case 1:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_lomo];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.Frame = CGRectMake(46, 0, 45, 50);
            [UIView commitAnimations];
            
        }
            break;
        case 2:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_heibai];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*2, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 3:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_huajiu];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*3, 0, 45, 50);
            [UIView commitAnimations];
            
        }
            break;
        case 4:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_gete];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*4, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 5:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_ruise];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*5, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 6:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_danya];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*6, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 7:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_jiuhong];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*7, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 8:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_qingning];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*8, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 9:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_langman];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*9, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 10:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_guangyun];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*10, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 11:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_landiao];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*11, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 12:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_menghuan];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*12, 0, 45, 50);
            [UIView commitAnimations];
        }
            break;
        case 13:
        {
            previewImageView.image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_yese];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.3];
            frameImageView.frame = CGRectMake(46*13, 0, 45, 50);
            [UIView commitAnimations];
        }
        default:
            break;
    }
}

- (void)cleanup
{
	oglView = nil;
    
    frameRateLabel = nil;
    dimensionsLabel = nil;
    typeLabel = nil;
    videoSizeLabel = nil;
    previewImageView = nil;
	
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];

    // Stop and tear down the capture session
	[videoProcessor stopAndTearDownCaptureSession];
	videoProcessor.delegate = nil;
}

- (void)viewDidUnload 
{
	[super viewDidUnload];

	[self cleanup];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{	
	[super viewDidDisappear:animated];

	[timer invalidate];
	timer = nil;
}

- (void)dealloc 
{
	[self cleanup];

}

- (IBAction)toggleRecording:(id)sender 
{
	// Wait for the recording to start/stop before re-enabling the record button.
	[[self recordButton] setEnabled:NO];
	
	if ( [videoProcessor isRecording] ) {
		// The recordingWill/DidStop delegate methods will fire asynchronously in response to this call
		[videoProcessor stopRecording];
	}
	else {
		// The recordingWill/DidStart delegate methods will fire asynchronously in response to this call
        [videoProcessor startRecording];
	}
}

- (void) lowQuailtyWithInputURL:(NSURL*)inputURL
                      outputURL:(NSURL*)outputURL
                   blockHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset     presetName:AVAssetExportPresetMediumQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeQuickTimeMovie;
    
    [session exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(session);
     }];
}


- (IBAction)getVideoList:(id)sender 
{
	// Wait for the recording to start/stop before re-enabling the record button.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dic = [paths objectAtIndex:0];
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dic error:nil];
    
    int nTemp = 0;
    for(NSString *str in array)
    {

        NSString *videoPath = [NSString stringWithFormat:@"%@/%@",dic,str];
        NSLog(@"path   %@",videoPath); 
        
        NSString *videoTempPath = [NSString stringWithFormat:@"%@/lowVideo%d.mp4",dic,nTemp];
        [self lowQuailtyWithInputURL:[NSURL fileURLWithPath:videoPath] outputURL:[NSURL fileURLWithPath:videoTempPath] blockHandler:^(AVAssetExportSession *session)
        {
           
        }];
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath,nil,nil,nil);
        nTemp ++;
        //else{}
    }
    
}

#pragma mark RosyWriterVideoProcessorDelegate

- (void)recordingWillStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:NO];	
		[[self recordButton] setTitle:@"Stop"];

		// Disable the idle timer while we are recording
		[UIApplication sharedApplication].idleTimerDisabled = YES;

		// Make sure we have time to finish saving the movie if the app is backgrounded during recording
		if ([[UIDevice currentDevice] isMultitaskingSupported])
			backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	});
}

- (void)recordingDidStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
	});
}

- (void)recordingWillStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Disable until saving to the camera roll is complete
		[[self recordButton] setTitle:@"Record"];
		[[self recordButton] setEnabled:NO];
		
		// Pause the capture session so that saving will be as fast as possible.
		// We resume the sesssion in recordingDidStop:
		//[videoProcessor pauseCaptureSession];
	});
}

- (void)recordingDidStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;

		[videoProcessor resumeCaptureSession];

		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
	});
}

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
	// Don't make OpenGLES calls while in the background.
    
	if ( [UIApplication sharedApplication].applicationState != UIApplicationStateBackground )
    {
   
		[oglView displayPixelBuffer:pixelBuffer];
    }
}

- (void)imageBufferReadyForDisplay:(UIImage*)pixelBuffer
{
	// Don't make OpenGLES calls while in the background.
    
	if ( [UIApplication sharedApplication].applicationState != UIApplicationStateBackground )
    {
        [self changeImage:m_nImageType imageSrc:pixelBuffer];
        //[self switchImageFilter:m_nImageType imageSrc:pixelBuffer];
		//[self.previewImageView setImage:[pixelBuffer edgeDetection]];
    }
}

- (void)switchImageFilter:(int)nType imageSrc:(UIImage*)image
{
    switch (nType) {
        case 0:
            break;
        case 1:
            self.previewImageView.image = [image gaussianBlur];
            break;
        case 2:
            self.previewImageView.image = [image edgeDetection];
            break;
        case 3:
            self.previewImageView.image = [image emboss];
            break;
        case 4:
            self.previewImageView.image = [image sharpen];
            break;
        case 5:
            self.previewImageView.image = [image unsharpen];
            break;
        case 6:
            self.previewImageView.image = [image rotateInRadians:M_PI_2 * 0.3];
            break;
        case 7:
            self.previewImageView.image = [image dilateWithIterations:3];
            break;
        case 8:
            self.previewImageView.image = [image erodeWithIterations:3];
            break;
        case 9:
            self.previewImageView.image = [image gradientWithIterations:3];
            break;
        case 10:
            self.previewImageView.image = [image tophatWithIterations:4];
            break;
        case 11:
            self.previewImageView.image = [image equalization];
            break;
        default:
            break;
    }

}

- (void)handTape:(UITapGestureRecognizer *)recognizer{
    
        NSLog(@"helloTap");
        self.previewImageView.viewPrintFormatter.view.hidden=NO;
        CATransition *animation = [CATransition animation];
        animation.delegate = self;
        [animation setDuration:1.25f];
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        [animation setType:kCATransitionPush];
        [animation setSubtype: kCATransitionFromBottom];
        [self.previewImageView.viewPrintFormatter.view.layer addAnimation:animation forKey:@"animation"];
        
        [UIView beginAnimations:[[NSString alloc]initWithFormat:@"animation" ] context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:2];
        if(++m_nImageType > 11)
        {
            m_nImageType = 0;
        }

 
}



@end
