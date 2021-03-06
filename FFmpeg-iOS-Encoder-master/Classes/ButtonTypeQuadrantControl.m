// TTTQuadrantControl.m
//
// Copyright (c) 2011 wangyong

#import <QuartzCore/QuartzCore.h>
#import "ButtonTypeQuadrantControl.h"

static NSUInteger const kAFTTTQuadrantNullLocation = 0;

@interface ButtonTypeQuadrantControl ()
@property (readwrite, nonatomic, assign) ButtonTypeQuadrantLocation activeLocation;
@property (readwrite, nonatomic, retain) ButtonTypeQuadrantView *topLeftQuadrantView;
@property (readwrite, nonatomic, retain) ButtonTypeQuadrantView *topRightQuadrantView;
@property (readwrite, nonatomic, retain) ButtonTypeQuadrantView *bottomLeftQuadrantView;
@property (readwrite, nonatomic, retain) ButtonTypeQuadrantView *bottomRightQuadrantView;

- (void)commonInit;
@end

@implementation ButtonTypeQuadrantControl
@synthesize delegate = _delegate;
@synthesize activeLocation = _activeLocation;
@synthesize topLeftQuadrantView = _topLeftQuadrantView;
@synthesize topRightQuadrantView = _topRightQuadrantView;
@synthesize bottomLeftQuadrantView = _bottomLeftQuadrantView;
@synthesize bottomRightQuadrantView = _bottomRightQuadrantView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
		return nil;
    }

    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (!self) {
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    self.topRightQuadrantView = [[[ButtonTypeQuadrantView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:self.topRightQuadrantView];
    
    self.topLeftQuadrantView = [[[ButtonTypeQuadrantView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:self.topLeftQuadrantView];
    
    self.bottomLeftQuadrantView = [[[ButtonTypeQuadrantView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:self.bottomLeftQuadrantView];
    
    self.bottomRightQuadrantView = [[[ButtonTypeQuadrantView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:self.bottomRightQuadrantView];
    
    self.layer.cornerRadius = 8.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.masksToBounds = YES;
}

- (void)dealloc {
	[_topLeftQuadrantView release];
	[_topRightQuadrantView release];
	[_bottomLeftQuadrantView release];
	[_bottomRightQuadrantView release];
    [super dealloc];
}

- (void)setNumber:(NSNumber *)number 
		  caption:(NSString *)caption 
		   action:(SEL)action
	  forLocation:(ButtonTypeQuadrantLocation)location 
{
	ButtonTypeQuadrantView * quadrantView = [self quadrantViewAtLocation:location];
	quadrantView.number = number;
	quadrantView.caption = caption;
	quadrantView.action = action;
}

- (ButtonTypeQuadrantLocation)locationAtPoint:(CGPoint)point {
	if (point.x < self.center.x) {
		if (point.y < self.center.y) {
			return TopLeftLocation;
		} else {
			return BottomLeftLocation;
		}
	} else {
		if (point.y < self.center.y) {
			return TopRightLocation;
		} else {
			return BottomRightLocation;
		}
	}
}

- (ButtonTypeQuadrantView *)quadrantViewAtLocation:(ButtonTypeQuadrantLocation)location {
	switch (location) {
        case TopRightLocation: 
			return self.topRightQuadrantView;
		case TopLeftLocation: 
			return self.topLeftQuadrantView;
		case BottomLeftLocation:
			return self.bottomLeftQuadrantView;
		case BottomRightLocation: 
			return self.bottomRightQuadrantView;
        default:
            return nil;
	}
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	self.activeLocation = [self locationAtPoint:point];
	[self setNeedsDisplay];
	[[self subviews] makeObjectsPerformSelector:@selector(setNeedsDisplay)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	switch (self.activeLocation) {
		case TopLeftLocation:
		case TopRightLocation: 
		case BottomLeftLocation:
		case BottomRightLocation:
			[self.delegate performSelector:[[self quadrantViewAtLocation:self.activeLocation] action]];
        default:
            break;
	}
	
	self.activeLocation = kAFTTTQuadrantNullLocation;
    
	[self setNeedsDisplay];
	[[self subviews] makeObjectsPerformSelector:@selector(setNeedsDisplay)];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.activeLocation = kAFTTTQuadrantNullLocation;
	
    [self setNeedsDisplay];
	[[self subviews] makeObjectsPerformSelector:@selector(setNeedsDisplay)];
}

#pragma mark - UIView

- (void)layoutSubviews {
    CGFloat width = round(self.frame.size.width / 2.0);
    CGFloat height = round(self.frame.size.height / 2.0);
    
    self.topLeftQuadrantView.frame = CGRectMake(0.0f, 0.0f, width, height);
    self.topRightQuadrantView.frame = CGRectMake(width, 0.0f, width, height);
    self.bottomLeftQuadrantView.frame = CGRectMake(0.0f, height, width, height);
    self.bottomRightQuadrantView.frame = CGRectMake(width, height, width, height);
}

- (void)drawRect:(CGRect)rect {	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	// Background Fill
	CGContextSetFillColorWithColor(c, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(c, rect);
	
	// Vertical Divider
	CGContextMoveToPoint(c, round(CGRectGetMidX(rect)) + 0.5f, 0.0f);
	CGContextAddLineToPoint(c, round(CGRectGetMidX(rect)) + 0.5f, round(rect.size.height));
	
	// Horizontal Divider
	CGContextMoveToPoint(c, 0.0f, round(CGRectGetMidY(rect)) + 0.5f);
	CGContextAddLineToPoint(c, round(rect.size.width), round(CGRectGetMidY(rect)) + 0.5f);
	
	CGContextSetLineWidth(c, 0.5f);
	CGContextSetStrokeColorWithColor(c, [[UIColor lightGrayColor] CGColor]);
	CGContextDrawPath(c, kCGPathStroke);      
    
	[self.topLeftQuadrantView setHighlighted:NO];
	[self.topRightQuadrantView setHighlighted:NO];
	[self.bottomLeftQuadrantView setHighlighted:NO];
	[self.bottomRightQuadrantView setHighlighted:NO];
    	
	// Draw gradient background for selected quadrant
	if (self.activeLocation) {
        ButtonTypeQuadrantView *activeQuadrantView = [self quadrantViewAtLocation:self.activeLocation];
        activeQuadrantView.highlighted = YES;
        
        CGRect activeRect = activeQuadrantView.frame;
		
		size_t num_locations = 2;
		CGFloat locations[2] = {0.0, 1.0};
		CGFloat components[8] = {0.000, 0.459, 0.968, 1.000,	//	#0075F6
								 0.000, 0.265, 0.897, 1.000};	//	#0043E4
		
		CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
		
		CGContextClipToRect(c, *(CGRect *)&activeRect);
		CGContextDrawLinearGradient(c, gradient, 
									CGPointMake(CGRectGetMidX(activeRect), CGRectGetMinY(activeRect)), 
									CGPointMake(CGRectGetMidX(activeRect), CGRectGetMaxY(activeRect)), 0);
		
		CGColorSpaceRelease(rgbColorspace);
		CGGradientRelease(gradient);
	}
}

@end

#pragma mark -

@implementation ButtonTypeQuadrantView
@synthesize number = _number;
@synthesize caption = _caption;
@synthesize highlighted;
@synthesize action;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {	
		return nil;
    }
    
    self.highlighted = NO;
    self.opaque = NO;
	
    return self;
}

- (void)dealloc {
	[_number release];
	[_caption release];
	[super dealloc];
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    static NSNumberFormatter *_numberFormatter;
    
	if (!_numberFormatter) {
		_numberFormatter = [[NSNumberFormatter alloc] init];
		[_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	}
    
	[(self.highlighted ? [UIColor whiteColor] : [UIColor blackColor]) set];
	NSString * numberString = [_numberFormatter stringFromNumber:self.number];
	CGSize numberTextSize = [numberString sizeWithFont:[UIFont boldSystemFontOfSize:22] constrainedToSize:self.bounds.size];
	CGPoint numberDrawPoint = CGPointMake(round((self.bounds.size.width - numberTextSize.width) / 2.0), 3.0f);
	[numberString drawAtPoint:numberDrawPoint withFont:[UIFont boldSystemFontOfSize:22]];
	
	[(self.highlighted ? [UIColor whiteColor] : [UIColor darkGrayColor]) set];
	CGSize captionTextSize = [self.caption sizeWithFont:[UIFont boldSystemFontOfSize:12] constrainedToSize:self.bounds.size];
	CGPoint captionDrawPoint = CGPointMake(round((self.bounds.size.width - captionTextSize.width) / 2.0), 27.0f);
	[self.caption drawAtPoint:captionDrawPoint withFont:[UIFont boldSystemFontOfSize:12]];
}

@end
