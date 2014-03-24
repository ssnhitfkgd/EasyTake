//
//  AVSegmentingAppleEncoder.h
//  RosyWriter
//
//  Copyright (c) 2012 yong wang. All rights reserved.
//
//

#import "AVAppleEncoder.h"

@interface AVSegmentingAppleEncoder : AVAppleEncoder {
    int videoBPS;
    int audioBPS;
    NSMutableArray *mutableArray;
}

@property (nonatomic, retain) AVAssetWriter *queuedAssetWriter;
@property (nonatomic, retain) AVAssetWriterInput *queuedAudioEncoder;
@property (nonatomic, retain) AVAssetWriterInput *queuedVideoEncoder;
@property (nonatomic, retain) NSString *lastMoivePath;

@property (nonatomic, retain) NSTimer *segmentationTimer;

- (id) initWithURL:(NSURL *)url segmentationInterval:(NSTimeInterval)timeInterval;

@end
