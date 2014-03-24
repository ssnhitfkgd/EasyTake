//
//  PlayerView.m
//
//  Created by wangyong on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AVPlayerView.h"
#import "PlayerView.h"

@implementation PlayerView
@synthesize videoID;
@synthesize playerItem;
@synthesize player;
@synthesize btnPlayback;
@synthesize btnInfo;
@synthesize infoView;
@synthesize info;
@synthesize loadingView;
@synthesize autoPlayWhenGetReady;
@synthesize playerView;
@synthesize tapGesture;
@synthesize topWindow;
@synthesize previewView;


- (id)initWithAssetURL:(NSURL *)_URL rotation:(AVCaptureVideoOrientation)_rotation purchase:(int)purchase
{

    //isLandscape = UIDeviceOrientationIsLandscape(_rotation);
    isLandscape = YES;
    CGRect frame = isLandscape ? CGRectMake(20, 0, 280, 210) : CGRectMake(60, 0, 210, 280);
    if (self = [super initWithFrame:frame]) { // 320x(280+10) or 320x(210+10)
        
        NSString *videoURL = [[[NSMutableString alloc] initWithString:[_URL absoluteString]] autorelease];

        URL = [_URL retain];
        rotation = _rotation;
        autoPlayWhenGetReady = YES;

        UIImage *shadowImage = isLandscape ? [UIImage imageNamed:@"replay_shadow_landscape"] : [UIImage imageNamed:@"replay_shadow_portrait"];
        UIImageView *shadowView = [[[UIImageView alloc] initWithImage:shadowImage] autorelease];
        shadowView.top = self.height - (isLandscape?7:2); // 阴影的图本来高得多余，盖住上部6px，不直接改图，较灵活
        [self addSubview:shadowView];

        previewView = [[UIImageView alloc] init];
        previewView.layer.cornerRadius = 4;
        previewView.layer.masksToBounds = YES;
        previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        previewView.contentMode = UIViewContentModeScaleAspectFit;
        [previewView setImage:[UIImage imageNamed:@"1"]];
        [self addSubview:previewView];
 
        self.btnPlayback = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 62, 59)] autorelease];
        [btnPlayback setBackgroundImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
        [btnPlayback addTarget:self action:@selector(btnPlaybackTapped) forControlEvents:UIControlEventTouchUpInside];
        btnPlayback.centerX = self.width / 2;
        btnPlayback.centerY = self.height / 2;
        btnPlayback.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:btnPlayback];

         if([videoURL hasPrefix:@"http://"])
         {
             self.btnInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [btnInfo addTarget:self action:@selector(btnInfoTapped) forControlEvents:UIControlEventTouchUpInside];
            btnInfo.right = self.width - 4;
            btnInfo.top = self.height - 24;
            btnInfo.showsTouchWhenHighlighted = NO;
             btnInfo.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
            [self addSubview:btnInfo];
         }

        self.loadingView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        loadingView.frame = btnPlayback.frame;
        loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:loadingView];

        doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFullScreen)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
    }
  
    return self;
}

- (void)dealloc {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerView.layer removeObserver:self forKeyPath:@"readyForDisplay"];
    [player pause];
    [videoID release];
    [topWindow release];
    [doubleTap release];
    [tapGesture release];
    [playerView release];
    [previewView release];
    [player release];
    [btnPlayback release];
    [btnInfo release];
    [playerItem release];
    [loadingView release];
    [URL release];
    [super dealloc];
}

#define kAnimationDuration .4

- (void)toggleFullScreen {
    if (isAnimating) {
        return;
    }
    isAnimating = YES;
    if (savedSuperview) {
        // i'm in fullscreen mode
        [UIView animateWithDuration:kAnimationDuration animations:^{
            topWindow.backgroundColor = [UIColor clearColor];
            self.frame = [topWindow convertRect:savedFrame fromView:savedSuperview];
        } completion:^(BOOL finished) {
            [savedSuperview addSubview:self];
            savedSuperview = nil;
            self.frame = savedFrame;
            self.topWindow = nil;
            isAnimating = NO;
        }];
    } else {
        savedSuperview = self.superview;
        savedFrame = self.frame;
        self.topWindow = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
        topWindow.windowLevel = UIWindowLevelStatusBar + 1;
        topWindow.hidden = NO;
        topWindow.backgroundColor = [UIColor clearColor];
        [topWindow addSubview:self];
        self.center = [topWindow convertPoint:self.center fromView:savedSuperview];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            CGFloat height = isLandscape ? topWindow.width / 4 * 3 : topWindow.width / 3 * 4;
            self.frame = CGRectMake(0, (topWindow.height - height) / 2, topWindow.width, height);
            topWindow.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            isAnimating = NO;
        }];
    }
}

- (void)showButtons {
    btnPlayback.hidden = btnInfo.hidden = NO;
    [self bringSubviewToFront:btnPlayback];
    [self bringSubviewToFront:btnInfo];
    [self removeGestureRecognizer:tapGesture];
}

- (void)pausePlaying {
    [player pause];
    [self showButtons];
}

- (void)startPlaying {
    
    if([[URL absoluteString] hasPrefix:@"http:"])
    {
        self.playerView.alpha = 0.0;
        [UIView animateWithDuration:4.0
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.playerView.alpha = 1.0; 
                         }
                         completion:^(BOOL finished){
                             [player play];
                             CGSize size =   playerItem.presentationSize;
                             NSLog(@"%f %f",size.width,size.height);
                            
                             self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pausePlaying)] autorelease];
                             [tapGesture requireGestureRecognizerToFail:doubleTap];
                             [self addGestureRecognizer:tapGesture];
                         }];
    }
    else {
        [player play];
        CGSize size =   playerItem.presentationSize;
        NSLog(@"%f %f",size.width,size.height);
    }
 
}



//submitConsumptionInfo

- (void)playerItemDidReachEnd:(NSNotification *)notification {
 
    if([[URL absoluteString] hasPrefix:@"http:"])
    {
        self.playerView.alpha = 1.0;
        [UIView animateWithDuration:3.0
                              delay:1.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.playerView.alpha = 0.0; 
                         }
                         completion:^(BOOL finished){
                             autoPlayWhenGetReady = NO;
                             
                             // must use zero tolerance
                             [player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                             
                             // if playing live stream, playerItem.status will be changed to ready again after didReachEnd
                             // it doesn't happen when playing local mp4
                             // so reset buttons here is also necessary
                             [self showButtons];
                         }];
    }
    else {
        autoPlayWhenGetReady = NO;
        
        // must use zero tolerance
        [player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        
        // if playing live stream, playerItem.status will be changed to ready again after didReachEnd
        // it doesn't happen when playing local mp4
        // so reset buttons here is also necessary
        [self showButtons];
    }


}

- (void)loadPlayer {
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
    NSLog(@"GET %@", asset.URL);
    NSString *tracksKey = @"tracks";
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];

  
    if (status == AVKeyValueStatusLoaded) {
        
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        self.playerView = [[[AVPlayerView alloc] initWithFrame:self.bounds] autorelease];
   
        NSLog(@"%f,%f",self.bounds.size.width,self.bounds.size.height);
        playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        playerView.player = player;
        [playerView.layer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:NULL];
        
        
//            if ([[URL absoluteString] hasPrefix:@"http://"]) { // mp4 has correct rotation metadata so no client fix required
//                if (rotation == AVCaptureVideoOrientationPortrait) {
//                    playerView.layer.transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1);
//                } 
//                else if (rotation == AVCaptureVideoOrientationPortraitUpsideDown) {
//                  playerView.layer.transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, -1);
//                }
//                else if (rotation == AVCaptureVideoOrientationLandscapeLeft) {
//                    playerView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
//                }
//            }
        playerView.layer.cornerRadius = 4.0f;
        playerView.layer.masksToBounds = YES;

    } else {
            NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:@"readyForDisplay"] && [[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
        playerView.frame = self.bounds; // just before adding
        // while playing local mp4, playerItem status becomes ready before layer becomes readyForDisplay
        // insert above preview but below control buttons
        [self insertSubview:playerView aboveSubview:previewView];
    } else if ([keyPath isEqualToString:@"status"] && [[change objectForKey:NSKeyValueChangeNewKey] unsignedIntValue] == AVPlayerItemStatusReadyToPlay) {
        [loadingView stopAnimating];
        if (autoPlayWhenGetReady) {
            [self startPlaying];
        } else {
            [self showButtons];
        }
    }
    else {
       
    }
}

- (void)btnPlaybackTapped {
    btnPlayback.hidden = btnInfo.hidden = YES;
    if (!player) {
        [loadingView startAnimating];
        [self loadPlayer];
    } else {
        [self startPlaying];
    }
}

- (void)btnInfoTapped {
    if (self.infoView) {
        [UIView animateWithDuration:.3
                         animations:^{ infoView.alpha = 0; }
                         completion:^(BOOL finished){ [infoView removeFromSuperview]; }];
        ;
        self.infoView = nil;
    } else if (info) {
        self.infoView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        infoView.layer.cornerRadius = 4;
        infoView.layer.masksToBounds = YES;
        infoView.opaque = NO;
        infoView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.65];
        UILabel *addr = [[[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 20, 18)] autorelease];
        addr.backgroundColor = [UIColor clearColor];
        addr.textColor = [UIColor whiteColor];
        addr.font = [UIFont systemFontOfSize:12];
        addr.textAlignment = UITextAlignmentLeft;
        addr.numberOfLines = 0;
        addr.text = info;
        [addr sizeToFit];
        [infoView addSubview:addr];
        infoView.alpha = 0;
        [self addSubview:infoView];
        [UIView animateWithDuration:.3
                         animations:^{ infoView.alpha = 1; }
                         completion:NULL];
        [self bringSubviewToFront:btnInfo];
    }
    // TODO: add a subview of video.address
}

- (void)setPreviewImageURL:(NSString *)urlPath {
    //[previewView setUrlPath:urlPath videoType:VIDEO_PLAY_URL];
}

@end
