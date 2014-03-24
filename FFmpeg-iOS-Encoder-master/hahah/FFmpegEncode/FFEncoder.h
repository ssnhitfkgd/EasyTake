//
//  FFEncoder.h
//  RosyWriter
//
//  Copyright (c) 2012 yong wang. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "FFVideoEncoder.h"
#import "FFAudioEncoder.h"

@interface FFEncoder : NSObject

@property (nonatomic, strong) FFVideoEncoder *videoEncoder;
@property (nonatomic, strong) FFAudioEncoder *audioEncoder;

@end
