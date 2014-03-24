//
//  VideoTrimmerView.m
//
//  Created by wangyongn on 3/2/12.
//  Copyright (c) 2012 wangyongn. All rights reserved.
//

#define kVideoTrimmerSidePadding 30 /*this ought to also be the distance for the stretchable image left and right caps */
#define kVideoTrimmerHandleWidth 30

#define kVideoTrimmerMinWidth kVideoTrimmerHandleWidth * 2 + 10 

#import "VideoTrimSliderView.h"
#import "ThumbnailPickerView.h"

@interface VideoTrimSliderView()
- (void)videoTrimmerSelectionChanged;
@end

@implementation VideoTrimSliderView
@synthesize overlayImageView;
@synthesize thumbnailPickerView = _thumbnailPickerView;


- (id)initWithFrame:(CGRect)frame moiveImages:(NSArray *)images delegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 71)];
        overlayImageView.image = [[UIImage imageNamed:@"trimSlider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 30)];
        overlayImageView.contentMode = UIViewContentModeScaleToFill;
        overlayImageView.clipsToBounds = YES;
        [self addSubview:overlayImageView];
        
        
        _thumbnailPickerView = [[[ThumbnailPickerView alloc] initWithFrame:CGRectMake(kVideoTrimmerHandleWidth-3 , 8, overlayImageView.width - kVideoTrimmerHandleWidth*1.6, overlayImageView.frame.size.height-16)] autorelease];
  
        
        [_thumbnailPickerView setDataSource:delegate];
        [_thumbnailPickerView setDelegate  :delegate];
        [_thumbnailPickerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_thumbnailPickerView setBackgroundColor:[UIColor blackColor]];
        [overlayImageView addSubview:_thumbnailPickerView];
        [overlayImageView setAutoresizesSubviews:YES];
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    if ([touches count] > 1)
    {
        return; 
    }

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:overlayImageView];

    //find handle locations      
    CGRect leftHandleRect = CGRectMake(0, 0, kVideoTrimmerHandleWidth, overlayImageView.frame.size.height);
    CGRect rightHandleRect = CGRectMake(overlayImageView.frame.size.width - kVideoTrimmerHandleWidth, 0, kVideoTrimmerHandleWidth, overlayImageView.frame.size.height);


    if (CGRectContainsPoint(leftHandleRect, point)) {
    //    NSLog(@"Point in LEFT: %@", NSStringFromCGPoint(point));
        actionType = VideoTrimmerActionMoveLeftHandle;
    }
    else if (CGRectContainsPoint(rightHandleRect, point)) {
        actionType = VideoTrimmerActionMoveRightHandle;
    //    NSLog(@"Point in RIGHT: %@", NSStringFromCGPoint(point));
    }
    else
    {
        if (actionType & VideoTrimmerActionMoveLeftHandle || actionType & VideoTrimmerActionMoveRightHandle)
        {

            NSLog(@"aa");
        }
        else
        {
            actionType = VideoTrimmerActionPan;
        }
      
    }
    

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:overlayImageView];
    CGPoint previousPoint = [touch previousLocationInView:overlayImageView];

    CGFloat distance = point.x - previousPoint.x;

    CGRect overlayFrame = overlayImageView.frame;

    if (actionType & VideoTrimmerActionMoveLeftHandle)
    { //if we are moving the left handle
        overlayFrame.origin.x += distance;
        overlayFrame.size.width -= distance;
    }
    else if (actionType & VideoTrimmerActionMoveRightHandle)
    {
        overlayFrame.size.width += distance;
    }
    else if (actionType & VideoTrimmerActionPan)
    {
        overlayFrame.origin.x += distance;
    }
    if (overlayFrame.size.width < kVideoTrimmerMinWidth || CGRectGetMinX(overlayFrame) < 0 || CGRectGetMaxX(overlayFrame) > self.frame.size.width) return; 
    overlayImageView.frame = overlayFrame;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoTrimmerSelectionChanged) object:nil];
    [self performSelector:@selector(videoTrimmerSelectionChanged) withObject:nil afterDelay:0.5]; //only fire off delegate

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { 
    actionType = VideoTrimmerActionNone; //reset
}
   
- (void)videoTrimmerSelectionChanged {
    [delegate videoTrimmer:self selectionChanged:NSMakeRange(overlayImageView.frame.origin.x, overlayImageView.frame.size.width)];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoTrimmerSelectionChanged) object:nil];
    delegate = nil;
    [overlayImageView release];
    [super dealloc];
}


@end
