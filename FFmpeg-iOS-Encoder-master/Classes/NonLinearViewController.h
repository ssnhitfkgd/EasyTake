//
//  NonLinearViewController.h
//  RosyWriter
//
//  Created by wangyong on 13-1-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "VideoTrimSliderView.h"

#import "ThumbnailPickerView.h"
@interface NonLinearViewController : BaseViewController<VideoTrimSliderViewDelegate,ThumbnailPickerViewDataSource, ThumbnailPickerViewDelegate>



@property(nonatomic, retain) NSArray *imagesWithMoive;


- (void)videoTrimmer:(VideoTrimSliderView *)trimmer selectionChanged:(NSRange)newSelection;

@end
