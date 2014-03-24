/*
     File: RosyWriterAppDelegate.m
 Abstract: Application delegate
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

#import "RosyWriterAppDelegate.h"
#import "DailyBoothViewController.h"


@implementation RosyWriterAppDelegate
@synthesize window;



#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    // Override point for customization after application launch.
   
	// Set the main view controller as the window's root view controller and display.
    //RootViewController *rootViewController = [[RootViewController alloc] init];
    [self customizeAppearance];
 
    //[self.window setRootViewController:dailyBoothViewController];


    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunch"]) 
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstLaunch"]; 
        PagePhotosView *pagePhotosView = [[PagePhotosView alloc] init];
        pagePhotosView.dataSource = self;
        [pagePhotosView.view setTag:0];
        [self.window setRootViewController:pagePhotosView];
    }
    else {
        DailyBoothViewController *dailyBoothViewController = [[DailyBoothViewController alloc] init];
        [self.window setRootViewController:dailyBoothViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    UIImageView *splashView =[[UIImageView alloc]initWithFrame:self.window.frame];
    [splashView setImage:[UIImage imageNamed:@"splashDefault.png"]];
    [splashView setTag: 1];
    [self.window addSubview:splashView];
    

    
    [self performSelector:@selector(splashAnimation) withObject:nil afterDelay:2];    return YES;
}

- (void)changeRootViewController:(UIViewController*)viewController
{
    DailyBoothViewController *dailyBoothViewController = [[DailyBoothViewController alloc] init];
    
    [viewController curtainRevealViewController:dailyBoothViewController transitionStyle:RECurtainTransitionHorizontal];
}


- (int)numberOfPages {
	return 5;
}

- (UIImage *)imageAtIndex:(int)index {
	NSString *imageName = [NSString stringWithFormat:@"page_%d.jpg", index + 1];
   	return [UIImage imageNamed:imageName];
}



- (void)splashAnimation{
    
    UIView *flashView = [self.window viewWithTag:1];
   
    [UIView animateWithDuration:2.0
                          delay:0.2
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         flashView.alpha = .9;
                         //flashView.centerX = -160;
                     }
     
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }];
}

- (void)customizeAppearance
{
    
    UIDevice *device = [UIDevice currentDevice];
    if([device.systemVersion floatValue] >= 5.0)
    {
        // Create resizable images
        UIImage *gradientImage44 = [[UIImage imageNamed:@"navigationBar_Bg.png"] 
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImage *gradientImage32 = [[UIImage imageNamed:@"navigationBar_Bg@2x.png"] 
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        // Set the background image for *all* UINavigationBars
        [[UINavigationBar appearance] setBackgroundImage:gradientImage44 
                                           forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:gradientImage32 
                                           forBarMetrics:UIBarMetricsLandscapePhone];
        
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor colorWithRed:200.0 green:32 blue:38], 
          UITextAttributeTextColor, 
          [UIColor whiteColor], 
          UITextAttributeTextShadowColor, 
          [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], 
          UITextAttributeTextShadowOffset, 
          [UIFont systemFontOfSize:18], 
          UITextAttributeFont, 
          nil]];
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



@end
