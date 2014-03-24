//
//  MyLauncherViewControllerItem.m
//  @rigoneri
//
//  Copyright 2010 Rodrigo Neri
//  Copyright 2011 David Jarrett
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

#import "MyLauncherViewControllerItem.h"
#import "CustomBadge.h"

@implementation MyLauncherViewControllerItem


@synthesize image = _image;
@synthesize iPadImage = _iPadImage;
@synthesize controllerStr = _controllerStr;
@synthesize controllerTitle = _controllerTitle;
@synthesize deletable = _deletable;

#pragma mark - Lifecycle

-(id)initWithTitle:(NSString *)title image:(NSString *)image target:(NSString *)targetControllerStr deletable:(BOOL)deletable {
	return [self initWithTitle:title 
                   iPhoneImage:image 
                     iPadImage:image 
                        target:targetControllerStr 
                   targetTitle:title 
                     deletable:deletable];
}

-(id)initWithTitle:(NSString *)title iPhoneImage:(NSString *)image iPadImage:(NSString *)iPadImage target:(NSString *)targetControllerStr targetTitle:(NSString *)targetTitle deletable:(BOOL)deletable {
    
    if((self = [super initWithTitle:title deletable:deletable]))
	{
		[self setImage:image];
        [self setIPadImage:iPadImage];
		[self setControllerStr:targetControllerStr];
        [self setControllerTitle:targetTitle];
	}
	return self;
}

-(UIImage*)icon {
    UIImage *image = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [self iPadImage]) {
        image = [UIImage imageNamed:self.iPadImage];
    } else {
        image = [UIImage imageNamed:self.image];
    }
    
    return image;
}

-(void)selected:(MyLauncherViewController*)parent {
    
    Class viewCtrClass = [[parent appControllers] objectForKey:_controllerStr];
	UIViewController *controller = [[viewCtrClass alloc] init];
    
    [parent launchSelectedItemViewController:controller withTopTitle:_controllerTitle];
}

-(NSMutableDictionary*)itemToSave {
    NSMutableDictionary *itemToSave = [super itemToSave];
   
    [itemToSave setObject:_image forKey:@"image"];
    [itemToSave setObject:_iPadImage forKey:@"iPadImage"];
    [itemToSave setObject:_controllerStr forKey:@"controller"];
    [itemToSave setObject:_controllerTitle forKey:@"controllerTitle"];

    return itemToSave;
}

#pragma mark - Layout

-(void)layoutItem
{
	if(!self.image)
		return;
	
	for(id subview in [self subviews]) 
		[subview removeFromSuperview];
	
    UIImage *image = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [self iPadImage]) {
        image = [UIImage imageNamed:self.iPadImage];
    } else {
        image = [UIImage imageNamed:self.image];
    }
    
	UIImageView *itemImage = [[UIImageView alloc] initWithImage:image];
	CGFloat itemImageX = (self.bounds.size.width/2) - (itemImage.bounds.size.width/2);
	CGFloat itemImageY = (self.bounds.size.height/2) - (itemImage.bounds.size.height/2);
	itemImage.frame = CGRectMake(itemImageX, itemImageY, itemImage.bounds.size.width, itemImage.bounds.size.height);
	[self addSubview:itemImage];
    CGFloat itemImageWidth = itemImage.bounds.size.width;

    if(self.badge) {
        self.badge.frame = CGRectMake((itemImageX + itemImageWidth) - (self.badge.bounds.size.width - 6), 
                                      itemImageY-6, self.badge.bounds.size.width, self.badge.bounds.size.height);
        [self addSubview:self.badge];
    }
	
	if(_deletable)
	{
		self.closeButton.frame = CGRectMake(itemImageX-10, itemImageY-10, 30, 30);
		[self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
		self.closeButton.backgroundColor = [UIColor clearColor];
		[self.closeButton addTarget:self action:@selector(closeItem:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.closeButton];
	}
	
	CGFloat itemLabelY = itemImageY + itemImage.bounds.size.height;
	CGFloat itemLabelHeight = self.bounds.size.height - itemLabelY;
    
    if (_titleBoundToBottom)
    {
        itemLabelHeight = 34;
        itemLabelY = (self.bounds.size.height + 6) - itemLabelHeight;
    }
	
	UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, itemLabelY, self.bounds.size.width, itemLabelHeight)];
	itemLabel.backgroundColor = [UIColor clearColor];
	itemLabel.font = [UIFont boldSystemFontOfSize:11];
	itemLabel.textColor = COLOR(46, 46, 46);
	itemLabel.textAlignment = UITextAlignmentCenter;
	itemLabel.lineBreakMode = UILineBreakModeTailTruncation;
	itemLabel.text = self.title;
	itemLabel.numberOfLines = 2;
	[self addSubview:itemLabel];
}

#pragma mark - Touch



@end
