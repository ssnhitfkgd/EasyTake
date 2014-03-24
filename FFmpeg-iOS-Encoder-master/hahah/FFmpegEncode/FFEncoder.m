//
//  FFEncoder.m
//  RosyWriter
//
//  Copyright (c) 2012 yong wang. All rights reserved.
//
//

#import "FFEncoder.h"

@implementation FFEncoder
@synthesize videoEncoder, audioEncoder;

- (id) init {
    if (self = [super init]) {
        self.videoEncoder = [[FFVideoEncoder alloc] init];
        self.audioEncoder = [[FFAudioEncoder alloc] init];
        /* register all the codecs */
        avcodec_register_all();
    }
    return self;
}

@end
