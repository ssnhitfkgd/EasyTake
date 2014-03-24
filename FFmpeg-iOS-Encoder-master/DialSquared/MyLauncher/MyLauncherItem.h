//
//  MyLauncherItem.h
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

#import <Foundation/Foundation.h>
#import "CustomBadge.h"

@class MyLauncherViewController;

@protocol MyLauncherItemDelegate <NSObject>
-(void)didDeleteItem:(id)item;
@end

@interface MyLauncherItem : UIControl {	
	BOOL _dragging;
    BOOL _titleBoundToBottom;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, strong) CustomBadge *badge;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic) BOOL deletable;


-(id)initWithTitle:(NSString*)title deletable:(BOOL)deletable;

-(NSMutableDictionary*)itemToSave;

-(void)selected:(MyLauncherViewController*)parent;

-(void)layoutItem;
-(void)setDragging:(BOOL)flag;
-(BOOL)dragging;
-(BOOL)deletable;

-(BOOL)titleBoundToBottom;
-(void)setTitleBoundToBottom:(BOOL)bind;

-(NSString *)badgeText;
-(void)setBadgeText:(NSString *)text;
-(void)setCustomBadge:(CustomBadge *)customBadge;

@end
