//
//  NonLinearViewController.m
//  RosyWriter
//
//  Created by wangyong on 13-1-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NonLinearViewController.h"
#import "VideoTrimSliderView.h"
#import "PlayerView.h"

@interface NonLinearViewController ()
@property(nonatomic, retain) VideoTrimSliderView *videoTrimSliderView;
@end

@implementation NonLinearViewController
@synthesize videoTrimSliderView;
@synthesize imagesWithMoive;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    
    
    [self.imagesWithMoive addObserver:self forKeyPath:@"imagesWithMoive" options:NSKeyValueObservingOptionOld context:nil];
    
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"1357267570.361781.mp4"];
    NSLog(@"%@",defaultDBPath);
    
    PlayerView *videoView = [[PlayerView alloc] initWithAssetURL:[NSURL fileURLWithPath:defaultDBPath] rotation:1 purchase:-1];
    videoView.top = 10;
    [videoView setTag:0];
    videoView.autoPlayWhenGetReady = NO;
    [videoView loadPlayer]; // load immediately
    [self.view addSubview:videoView];
    
    self.videoTrimSliderView = [[VideoTrimSliderView alloc] initWithFrame:CGRectMake(20, videoView.bottom + 20, 280, 30)
                                                            moiveImages:[self getImagesWithMoiveWithURL:[NSURL fileURLWithPath:defaultDBPath]]
                                                            delegate:self];
    [self.view addSubview:self.videoTrimSliderView]; 

    
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:nil];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:paths.count];
    for (NSString *path in paths) {
        [images addObject:[UIImage imageWithContentsOfFile:path]];
    }
    //self.viewController.images = images;
    self.imagesWithMoive = images;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"hahahahhahdiasufhkjdashfkjalshf");
    
//    if (object == imagesWithMoive && [keyPath isEqualToString:@"imagesWithMoive"]) {
//        NSLog(@"hahahahhahdiasufhkjdashfkjalshf");
//        [self.thumbnailPickerView reloadData];
//    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)thumbShowImage:(UIImage*)image
{
    NSLog(@"fdsaf");
   // [self.view viewWithTag:0]
}


- (NSArray*)getImagesWithMoiveWithURL:(NSURL*)moiveUrl
{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:moiveUrl options:opts];

    
    //float second = 0.0f;
    
    //second = myAsset.duration.value / myAsset.duration.timescale; // 获取视频总时长,单位秒
    
    AVAssetImageGenerator *myImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:myAsset];
    myImageGenerator.appliesPreferredTrackTransform = YES;
    //    //解决 时间不准确问题
    myImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    myImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    
    // 获取视频总时长,单位秒
    Float64 durationSeconds = CMTimeGetSeconds([myAsset duration]);
    
    for(int i = 0; i < durationSeconds; i++)
        [myImageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(i, 20)]] completionHandler:
         ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
         {
             
             NSLog(@"actual got image at time:%f", CMTimeGetSeconds(actualTime));
             if (image)
             {
                 
                 NSLog(@"actual got image at t111111111");
                 [CATransaction begin];
                 [CATransaction setDisableActions:YES];
                 //[layer setContents:(id)image];
                 UIImage *img = [UIImage imageWithCGImage:image];
                 [imagesArray addObject:img];
                 [CATransaction commit];
             }
         }];
    
    return imagesArray;
}

- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

#pragma mark - ThumbnailPickerView data source

- (NSUInteger)numberOfImagesForThumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView
{
    return [self.imagesWithMoive count];
}

- (UIImage *)thumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView imageAtIndex:(NSUInteger)index
{
    UIImage *image = [self.imagesWithMoive objectAtIndex:index];
    usleep(10*1000);
    return image;
}

- (void)thumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView didSelectImageWithIndex:(NSUInteger)index
{
    [self updateUIWithSelectedIndex:index];
}

- (void)updateUIWithSelectedIndex:(NSUInteger)index
{
    [self thumbShowVideoImageView:[self.imagesWithMoive objectAtIndex:index]];
}

- (void)thumbShowVideoImageView:(UIImage*)image {
   
}


- (void)videoTrimmer:(VideoTrimSliderView *)trimmer selectionChanged:(NSRange)newSelection
{
}
@end
