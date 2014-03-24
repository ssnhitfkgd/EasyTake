//
//  QuitItem.m
//  EasyTake
//
//  Created by wangyong on 13-1-10.
//
//

#import "QuitItem.h"
#import "UIViewController+KNSemiModal.h"
#import "EasyTakeAppdelegate.h"
#import "QuitViewController.h"


@interface QuitItem ()

@end

@implementation QuitItem
@synthesize icon = _icon;

- (id)initWithIcon:(UIImage*)icon {
    if (self = [super init]) {
        _icon = icon;
    }
    return self;
}

- (void)start {
    QuitViewController *quitViewController = [[QuitViewController alloc] init];
    
    [[EasyTakeAppdelegate shareInstance].window.rootViewController presentSemiViewController:quitViewController];
}

- (UIImage*)icon {
    return _icon;
}

- (id)initWithCoder:(NSCoder*)coder {
    UIImage *tmpicon = [UIImage imageWithData:[coder decodeObjectForKey:@"icon"]];
    _icon = [UIImage imageWithCGImage:[tmpicon CGImage] scale:[coder decodeFloatForKey:@"scale"] orientation:UIImageOrientationUp];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    NSData *data = UIImagePNGRepresentation(_icon);
    [coder encodeObject:data forKey:@"icon"];
    
    [coder encodeFloat:[_icon scale] forKey:@"scale"];
}

@end
