// TTTQuadrantControl.h
//
// Copyright (c) 2010 wangyong

#import <UIKit/UIKit.h>

typedef enum {
    TopRightLocation    = 1,
	TopLeftLocation     = 2,
	BottomLeftLocation  = 3,
	BottomRightLocation = 4,
} TTTQuadrantLocation;

@class TTTQuadrantView;

@interface TTTQuadrantControl : UIControl {
	id _delegate;
	
	TTTQuadrantLocation _activeLocation;
	
	TTTQuadrantView *_topLeftQuadrantView;
	TTTQuadrantView *_topRightQuadrantView;
	TTTQuadrantView *_bottomLeftQuadrantView;
	TTTQuadrantView *_bottomRightQuadrantView;
}

@property (nonatomic, assign) id delegate;

- (void)setNumber:(NSNumber *)number 
		  caption:(NSString *)caption 
		   action:(SEL)action
	  forLocation:(TTTQuadrantLocation)location;
- (TTTQuadrantView *)quadrantViewAtLocation:(TTTQuadrantLocation)location;
- (TTTQuadrantLocation)locationAtPoint:(CGPoint)point;

@end

#pragma mark -

@interface TTTQuadrantView : UIView {
	NSNumber *_number;
	NSString *_caption;
	SEL _action;
}

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, assign) SEL action;

@end
