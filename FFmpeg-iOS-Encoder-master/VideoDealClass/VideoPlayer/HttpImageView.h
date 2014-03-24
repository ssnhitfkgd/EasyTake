//
//  HttpImageView.h
//  Weipai
//
//  Created by wangyong on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

typedef enum
{
     VIDEO_FIR_URL = 0,
     VIDEO_PLAY_URL,
     USER_PORTRAIT_URL,
     INSIGNIA_URL
}IMAGE_URL_TYPE;

typedef void (^ImageFetchedCallback)(UIImage *);

@interface HttpImageView : UIImageView <TTURLRequestDelegate>

@property (nonatomic, copy) ImageFetchedCallback imageFetchedCallback;

- (void)setUrlPath:(NSString *)url;
- (void)setUrlPath:(NSString *)url videoType:(IMAGE_URL_TYPE)type;
- (void)setImageForFile:(UIImage*)image;
@end
