// TTTQuadrantControl.h
//
// Copyright (c) 2010 wangyong

#import <UIKit/UIKit.h>

typedef enum {
    TopRightLocation    = 1,
	TopLeftLocation     = 2,
	BottomLeftLocation  = 3,
	BottomRightLocation = 4,
} ButtonTypeQuadrantLocation;

@class ButtonTypeQuadrantView;

@interface ButtonTypeQuadrantControl : UIControl {
	id _delegate;
	
	ButtonTypeQuadrantLocation _activeLocation;
	
	ButtonTypeQuadrantView *_topLeftQuadrantView;
	ButtonTypeQuadrantView *_topRightQuadrantView;
	ButtonTypeQuadrantView *_bottomLeftQuadrantView;
	ButtonTypeQuadrantView *_bottomRightQuadrantView;
}

@property (nonatomic, assign) id delegate;

- (void)setNumber:(NSNumber *)number 
		  caption:(NSString *)caption 
		   action:(SEL)action
	  forLocation:(ButtonTypeQuadrantLocation)location;


- (ButtonTypeQuadrantView *)quadrantViewAtLocation:(ButtonTypeQuadrantLocation)location;
- (ButtonTypeQuadrantLocation)locationAtPoint:(CGPoint)point;

@end

#pragma mark -

@interface ButtonTypeQuadrantView : UIView {
	NSNumber *_number;
	NSString *_caption;
	SEL _action;
}

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, assign) SEL action;

@end
