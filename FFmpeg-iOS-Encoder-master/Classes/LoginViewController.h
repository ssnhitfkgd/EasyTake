//
//  BasicHintView.h
//  TBHintViewDemo
//
//  Created by Stefan Immich on 4/6/12.
//  Copyright (c) 2012 touchbee Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBHintView.h"

typedef enum
{
    kHintID_Home = 1,
    kHintID_B,
    kHintID_C,
    
    kHintID_First = kHintID_Home,
    kHintID_Last = kHintID_C
    
} HintID;


@interface LoginViewController : UIView<TBHintViewDataSource, TBHintViewDelegate>

typedef void (^DemoHintViewBlock)();

@property (nonatomic,copy) NSString* title;
@property (nonatomic,retain) UIImage* icon;
@property (nonatomic,assign) NSUInteger maxHeight;
@property (nonatomic,assign) HintID hintID;

+(LoginViewController*) infoHintView;
+(LoginViewController*) warningHintView;
+(LoginViewController*) otherHintView;

+(BOOL) shouldShowHint:(NSUInteger)hintID;
+(void) resetAllHints;

+(void) enableHints:(BOOL)enable;
+(BOOL) hintsEnabled;

+(BOOL) isHintVisibleInView:(UIView*)view;
+(void) dismissVisibleHintInView:(UIView*)view;

-(void) addPageWithTitle:(NSString*)title text:(NSString*)text;
-(void) addPageWithTitle:(NSString*)title image:(UIImage*)image;
-(void) addPageWithtitle:(NSString*)title text:(NSString*)text buttonText:(NSString*)buttonText buttonAction:(DemoHintViewBlock)buttonAction;

-(void) addPageWithText:(NSString*)text;
-(void) addPageWithImage:(UIImage*)image;
-(void) addPageWithText:(NSString*)text buttonText:(NSString*)buttonText buttonAction:(DemoHintViewBlock)buttonAction;

-(void) setDismissedHandler:(DemoHintViewBlock)dismissed;

-(void) showInView:(UIView*)view;
-(void) showInView:(UIView*)view orientation:(TBHintViewOrientation)orientation;

-(void) showInView:(UIView*)view duration:(NSTimeInterval)duration;
-(void) showInView:(UIView*)view orientation:(TBHintViewOrientation)orientation duration:(NSTimeInterval)duration;

-(void) showInView:(UIView*)view presentation:(TBHintViewPresentationAnimation)presentation;
-(void) showInView:(UIView*)view orientation:(TBHintViewOrientation)orientation presentation:(TBHintViewPresentationAnimation)presentation;

-(void) showInView:(UIView*)view duration:(NSTimeInterval)duration presentation:(TBHintViewPresentationAnimation)presentation;
-(void) showInView:(UIView*)view orientation:(TBHintViewOrientation)orientation duration:(NSTimeInterval)duration presentation:(TBHintViewPresentationAnimation)presentation;
+(LoginViewController*) showLoginView;
-(void) dismiss;

@end
