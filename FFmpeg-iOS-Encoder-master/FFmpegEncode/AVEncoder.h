//
//  AVEncoder.h
//  RosyWriter
//
//  Copyright (c) 2012 yong wang. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVEncoder : NSObject

- (void) setupEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void) finishEncoding;
- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@property (nonatomic) BOOL readyToEncode;
@property (nonatomic) CMFormatDescriptionRef formatDescription;

@end
