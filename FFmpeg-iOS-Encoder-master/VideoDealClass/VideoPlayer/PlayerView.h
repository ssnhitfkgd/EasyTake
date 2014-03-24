//
//  PlayerView.h
//
//  Created by wangyong on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@class HttpImageView;
@class AVPlayerView;

@interface PlayerView : UIView {
    BOOL isLandscape;
    NSURL *URL;
    AVCaptureVideoOrientation rotation;
    
    UITapGestureRecognizer *doubleTap;

    // fullscreen support
    BOOL isAnimating;
    UIView *savedSuperview;
    CGRect savedFrame;
}
@property (nonatomic, retain) UIImageView *previewView;
@property (nonatomic, retain) AVPlayerItem *playerItem;
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) UIButton *btnPlayback;
@property (nonatomic, retain) UIButton *btnInfo;
@property (nonatomic, retain) UIView *infoView;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) AVPlayerView *playerView;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) NSString *videoID;
@property (nonatomic, retain) UIWindow *topWindow; // for fullscreen playing

// public
@property (nonatomic, assign) BOOL autoPlayWhenGetReady; // default: YES

//- (id)initWithAssetURL:(NSURL *)URL rotation:(AVCaptureVideoOrientation)rotation;
- (id)initWithAssetURL:(NSURL *)_URL rotation:(AVCaptureVideoOrientation)_rotation purchase:(int)purchase;
- (void)setPreviewImageURL:(NSString *)urlPath;
- (void)loadPlayer;
- (void)pausePlaying;

@end
