//
//  AVPlayerView.m
//
//  Created by wangyong on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AVPlayerView.h"

@implementation AVPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)self.layer player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)self.layer setPlayer:player];
    [(AVPlayerLayer *)self.layer setVideoGravity:AVLayerVideoGravityResize];
}

@end
