//
//  VideoTrimmerView.h
//
//  Created by wangyongn on 3/2/12.
//  Copyright (c) 2012 wangyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ThumbnailPickerView;
enum {
  VideoTrimmerActionNone = 0,
  VideoTrimmerActionMoveLeftHandle = 1 << 0,
  VideoTrimmerActionMoveRightHandle = 1 << 1,
  VideoTrimmerActionPan = 1 << 2
}; 
typedef NSUInteger VideoTrimmerActionType;

@protocol VideoTrimSliderViewDelegate;

@interface VideoTrimSliderView : UIView{
  NSArray *thumbnails;
  VideoTrimmerActionType actionType;
  id <VideoTrimSliderViewDelegate> delegate;
  NSUInteger numberOfItems;
  
}

@property(retain, nonatomic) ThumbnailPickerView *thumbnailPickerView;
@property(retain, nonatomic) UIImageView *overlayImageView;

- (id)initWithFrame:(CGRect)frame moiveImages:(NSArray *)images delegate:(id)delegate;
@end

@protocol VideoTrimSliderViewDelegate <NSObject>

- (void)videoTrimmer:(VideoTrimSliderView *)trimmer selectionChanged:(NSRange)newSelection;

@end



