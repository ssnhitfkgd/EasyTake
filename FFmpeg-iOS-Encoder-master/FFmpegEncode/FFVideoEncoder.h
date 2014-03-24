//
//  FFVideoEncoder.h
//  RosyWriter
//
//  Copyright (c) 2012 yong wang. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "FFAVEncoder.h"

@interface FFVideoEncoder : FFAVEncoder {
    int frameNumber, ret, got_output;
    FILE *f;
    CMVideoDimensions outputSize;
    CMVideoDimensions inputSize;
    struct SwsContext *sws_ctx;
    AVFrame *scaledFrame;
}

- (void) setupEncoderWithFormatDescription:(CMFormatDescriptionRef)newFormatDescription desiredOutputSize:(CMVideoDimensions)desiredOutputSize;

@end
