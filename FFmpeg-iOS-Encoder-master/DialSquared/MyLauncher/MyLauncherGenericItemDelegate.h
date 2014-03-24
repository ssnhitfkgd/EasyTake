//
//  MyLauncherGenericItemDelegate.h
//  MyLauncher
//
//  Created by Nicolas Desjardins on 2012-07-04.
//
//

#import <Foundation/Foundation.h>

@protocol MyLauncherGenericItemDelegate <NSObject>

-(void)start;
-(UIImage*)icon;
-(int)itemId;
-(int)version;

@end
