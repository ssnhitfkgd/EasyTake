//
//  FFAudioEncoder.h
//  RosyWriter
//
//  Copyright (c) 2012 yong wang. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "FFAVEncoder.h"

@interface FFAudioEncoder : FFAVEncoder {
    const AudioStreamBasicDescription *currentASBD;
    int ret, got_output;
    int buffer_size;
    FILE *f;
    uint8_t *samples;
    uint8_t *buffer;
    NSUInteger bytesInBuffer;
    float t, tincr;
}

@end
