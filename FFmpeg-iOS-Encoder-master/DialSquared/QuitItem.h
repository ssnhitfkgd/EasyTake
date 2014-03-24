//
//  QuitItem.h
//  EasyTake
//
//  Created by wangyong on 13-1-10.
//
//

#import "MyLauncherGenericItem.h"
#import "MyLauncherViewController.h"


@interface QuitItem : NSObject<MyLauncherGenericItemDelegate, NSCoding>

@property (strong, nonatomic) UIImage *icon;

- (id)initWithIcon:(UIImage*)icon;
@end

