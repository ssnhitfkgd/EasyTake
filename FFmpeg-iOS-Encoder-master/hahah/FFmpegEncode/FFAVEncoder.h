//
//  FFAVEncoder.h
//  RosyWriter
//
//  Copyright (c) 2012 yong wang. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#include <libavcodec/avcodec.h>
#import "AVEncoder.h"

@interface FFAVEncoder : AVEncoder {
    CMFormatDescriptionRef formatDescription;
    AVCodec *codec;
    AVCodecContext *c;
    AVFrame *frame;
    AVPacket pkt;
}

@end
