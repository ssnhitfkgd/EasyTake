//
//  SetPageViewController.m
//  EasyTake
//
//  Created by wangyong on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "SetPageViewController.h"
#import "MyLauncherViewControllerItem.h"
#import "MyLauncherGenericItem.h"
#import "OpenWebURLItem.h"
#import "CustomBadge.h"
#import "ItemViewController.h"
#import "QuitItem.h"
#import "FeedbackItemViewController.h"
#import "AboutItemViewController.h"


@interface SetPageViewController ()

@end

@implementation SetPageViewController

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

    [[self appControllers] setObject:[ItemViewController class] forKey:@"ItemViewController"];
    
    [[self appControllers] setObject:[FeedbackItemViewController class] forKey:@"FeedbackItemViewController"];
    
    [[self appControllers] setObject:[AboutItemViewController class] forKey:@"AboutItemViewController"];
    
	if(![self hasSavedLauncherItems])
	{
            OpenWebURLItem *urlItem = [[OpenWebURLItem alloc] initWithURL:@"http://google.com" andIcon:[UIImage imageNamed:@"Atomica"]];
            QuitItem *quitItem = [[QuitItem alloc] initWithIcon:[UIImage imageNamed:@"Atomica"]];

        
            [self.launcherView setPages:  [NSMutableArray arrayWithObjects:
                                          [NSMutableArray arrayWithObjects:
                                          [[MyLauncherViewControllerItem alloc] initWithTitle:@"管理好友"
                                                                                  iPhoneImage:@"Atomica"
                                                                                    iPadImage:@"itemImage-iPad"
                                                                                       target:@"ItemViewController"
                                                                                  targetTitle:@"管理好友"
                                                                                    deletable:NO],
                                          
                                          [[MyLauncherViewControllerItem alloc] initWithTitle:@"参数设置"
                                                                                  iPhoneImage:@"Atomica"
                                                                                    iPadImage:@"itemIcon_2"
                                                                                       target:@"ItemViewController"
                                                                                  targetTitle:@"参数设置"
                                                                                    deletable:YES],
                                          
                                          [[MyLauncherViewControllerItem alloc] initWithTitle:@"平台分享"
                                                                                  iPhoneImage:@"Atomica"
                                                                                    iPadImage:@"itemImage-iPad"
                                                                                       target:@"ItemViewController"
                                                                                  targetTitle:@"平台分享"
                                                                                    deletable:NO],
//                                          
//                                          [[MyLauncherViewControllerItem alloc] initWithTitle:@"版本检测"
//                                                                                  iPhoneImage:@"Atomica"
//                                                                                    iPadImage:@"itemImage-iPad"
//                                                                                       target:@"ItemViewController"
//                                                                                  targetTitle:@"版本检测"
//                                                                                    deletable:YES],
//                                          
//                                          [[MyLauncherViewControllerItem alloc] initWithTitle:@"使用帮助"
//                                                                                  iPhoneImage:@"Atomica"
//                                                                                    iPadImage:@"itemImage-iPad"
//                                                                                       target:@"ItemViewController"
//                                                                                  targetTitle:@"使用帮助"
//                                                                                    deletable:NO],
                                           
                                           [[MyLauncherViewControllerItem alloc] initWithTitle:@"意见反馈"
                                                                                   iPhoneImage:@"Atomica"
                                                                                     iPadImage:@"itemImage-iPad"
                                                                                        target:@"FeedbackItemViewController"
                                                                                   targetTitle:@"意见反馈"
                                                                                     deletable:NO],
                                          
                                          [[MyLauncherViewControllerItem alloc] initWithTitle:@"关于我们"
                                                                                  iPhoneImage:@"Atomica"
                                                                                    iPadImage:@"itemImage-iPad"
                                                                                       target:@"AboutItemViewController"
                                                                                  targetTitle:@"关于我们"
                                                                                    deletable:NO],
                                           
                                           [[MyLauncherGenericItem alloc] initWithTitle:@"打个分吧"
                                                                               delegate:urlItem
                                                                              deletable:NO],
                                           
                                          [[MyLauncherGenericItem alloc] initWithTitle:@"退    出"
                                                                                     delegate:quitItem
                                                                                    deletable:NO],
                                    
                                          nil],
                                          nil]];
            
            // Set number of immovable items below; only set it when you are setting the pages as the
            // user may still be able to delete these items and setting this then will cause movable
            // items to become immovable.
            // [self.launcherView setNumberOfImmovableItems:1];
            
            // Or uncomment the line below to disable editing (moving/deleting) completely!
            // [self.launcherView setEditingAllowed:NO];
        }
        
        // Set badge text for a MyLauncherItem using it's setBadgeText: method
        [(MyLauncherViewControllerItem *)[[[self.launcherView pages] objectAtIndex:0] objectAtIndex:0] setBadgeText:@"4"];
        
        // Alternatively, you can import CustomBadge.h as above and setCustomBadge: as below.
        // This will allow you to change colors, set scale, and remove the shine and/or frame.
        [(MyLauncherViewControllerItem *)[[[self.launcherView pages] objectAtIndex:0] objectAtIndex:1] setCustomBadge:[CustomBadge customBadgeWithString:@"2" withStringColor:[UIColor blackColor] withInsetColor:[UIColor whiteColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor blackColor] withScale:0.8 withShining:NO]];
    
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
