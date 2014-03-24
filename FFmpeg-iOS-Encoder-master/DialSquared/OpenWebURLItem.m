//
//  MyLauncherGenericItem.m
//
//  Copyright 2012 Nicolas Desjardins
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "OpenWebURLItem.h"

@implementation OpenWebURLItem

@synthesize url = _url;
@synthesize icon = _icon;

- (id)initWithURL:(NSString*)url andIcon:(UIImage*)icon {
    if (self = [super init]) {
        _url = url;
        _icon = icon;
    }
    return self;
}

- (void)start {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
}

- (UIImage*)icon {
    return _icon;
}

- (id)initWithCoder:(NSCoder*)coder {
    _url = [coder decodeObjectForKey:@"URL"];
    UIImage *tmpicon = [UIImage imageWithData:[coder decodeObjectForKey:@"icon"]];
    _icon = [UIImage imageWithCGImage:[tmpicon CGImage] scale:[coder decodeFloatForKey:@"scale"] orientation:UIImageOrientationUp];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:_url forKey:@"URL"];
    
    NSData *data = UIImagePNGRepresentation(_icon);
    [coder encodeObject:data forKey:@"icon"];
    
    [coder encodeFloat:[_icon scale] forKey:@"scale"];
}
@end
