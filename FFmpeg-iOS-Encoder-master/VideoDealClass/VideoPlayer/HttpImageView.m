//
//  HttpImageView.m
//  Weipai
//
//  Created by wangyong on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HttpImageView.h"
//#import "User.h"

@interface HttpImageView (Loading)
- (void)showLoading:(BOOL)show;
@end

@implementation HttpImageView

@synthesize imageFetchedCallback;

- (void)dealloc {
    //[[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];

    [imageFetchedCallback release];
    [super dealloc];
}
//showType 0 列表视频图片  1播放背景图片   2用户头像
- (void)setUrlPath:(NSString *)url {

    if ([url isKindOfClass:[NSString class]] && [url length]) { // maybe nil or NSNull
        TTURLRequest *request = [TTURLRequest requestWithApi:url delegate:self];
        request.response = [[[TTURLImageResponse alloc] init] autorelease];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",VIDEO_FIR_URL] forKey:@"showType"];
        [request setUserInfo:dict];
        [self showLoading:YES];
        [request send];
    } 
}

- (void)setUrlPath:(NSString *)url videoType:(IMAGE_URL_TYPE)type{
    
    if ([url isKindOfClass:[NSString class]] && [url length]) { // maybe nil or NSNull
        TTURLRequest *request = [TTURLRequest requestWithApi:url delegate:self];
        request.response = [[[TTURLImageResponse alloc] init] autorelease];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",type] forKey:@"showType"];
        [request setUserInfo:dict];
        [self showLoading:YES];
        [request send];
    } 
}

- (void)setImageForFile:(UIImage*)image
{
    self.image = image;
    [self showLoading:NO];
    
}

- (void)requestDidFinishLoad:(TTURLRequest *)request {
    [self showLoading:NO];
    self.image = [(TTURLImageResponse *)request.response image];
    if (self.imageFetchedCallback) {
        self.imageFetchedCallback(self.image);
    }
}

- (UIImage *)thumbnailFromVideoAtPath:(NSString *)videoFilePath
{
 
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    //if([fileManager fileExistsAtPath:videoFilePath])
    {
        NSURL *url = [NSURL URLWithString:videoFilePath];
        AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:url options:nil] autorelease];
        AVAssetImageGenerator *generator = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];
        generator.appliesPreferredTrackTransform = YES;
        
        NSError *error = nil;
        CMTime time = CMTimeMakeWithSeconds(0.5, 60);
        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
        if (error.description != nil) 
            NSLog(@"Error: (thumbnailFromVideoAtPath:)%@", error.description);
        UIImage *image = [[[UIImage alloc] initWithCGImage:imgRef] autorelease];
        
        return image;
    }
    //return nil;
}

- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {  
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:videoURL options:nil] autorelease];  
    NSParameterAssert(asset);  
    AVAssetImageGenerator *assetImageGenerator = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];  
    assetImageGenerator.appliesPreferredTrackTransform = YES;  
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;  
    
    CGImageRef thumbnailImageRef = NULL;  
    CFTimeInterval thumbnailImageTime = time;  
    NSError *thumbnailImageGenerationError = nil;  
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];  
    
    if (!thumbnailImageRef)  
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);  
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[[UIImage alloc] initWithCGImage:thumbnailImageRef] autorelease] : nil;  
    
    return thumbnailImage;  
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
    TTDPRINT(@"error: %@", [error localizedDescription]);

    id obj = [request userInfo];
    IMAGE_URL_TYPE nShowType = [[obj objectForKey:@"showType"] intValue];

    [self showLoading:NO];
	// Ensure the source file exists
    NSRange range = [request.urlPath rangeOfString:@"file:/"];
	if (range.location != NSNotFound) 
    {
        NSString *str = request.urlPath;
        str = [str stringByReplacingCharactersInRange:range withString:@"file://"];
        range = [str rangeOfString:@"_vga_0.jpg"];
        if(range.location != NSNotFound)
        {
            str = [str stringByReplacingCharactersInRange:range withString:@".mov"];
            UIImage *image = [self thumbnailFromVideoAtPath:str];
            if(image != nil)
            {
                [self setImage:image];
               
            }
        
        }
        else {
            UIImage *image = [self thumbnailFromVideoAtPath:request.urlPath];
            if(image != nil)
            {
                [self setImage:image];
                
            }
        }

    }
    else {

        if(obj)
        {
                
            if(nShowType == USER_PORTRAIT_URL)
            {
                [self setImage:[UIImage imageNamed:@"userPhoto"]];
                return;
            }
            else if(nShowType == INSIGNIA_URL)
            {
            }
            else {

                if([self width] < [self height])
                {
                    [self setImage:[UIImage imageNamed:(nShowType == 1)?@"videoWit":@"vidWit"]];
                }
                else {
                    [self setImage:[UIImage imageNamed:(nShowType == 1)?@"videoHor":@"vidHor"]];
                }
            }

                 
        }
    }
        
        if(self.width > 100)
        {
            self.top = 0;
            self.left = 0;
        }else {
            self.left = 15;
        }
        if(nShowType == 0)
        {
            UIImageView *imageView = [[[UIImageView  alloc] initWithImage:[UIImage imageNamed:[self width] < [self height]?@"clip_shadow_portrait":@"clip_shadow_landscape"]] autorelease];
            
            [imageView setHeight:6];
            imageView.width = self.width; /* 4:3 */
            imageView.centerX = self.centerX;
            imageView.top = self.bottom - 2;
            [[self superview] addSubview:imageView];
            [[self superview] sendSubviewToBack:imageView];
        }



}

#pragma mark - Loading
- (void)showLoading:(BOOL)show {
    if (show) {
        self.backgroundColor = [UIColor clearColor];
        UIActivityIndicatorView *loading = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        [self addSubview:loading];
        loading.center = CGPointMake(self.width/2, self.height/2);
        [loading startAnimating];
    } else {
        for (id view in self.subviews) {
            if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
                [view removeFromSuperview];
                break;
            }
        }
    }
}

@end
