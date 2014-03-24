//
//  MyLauncherGenericItem.h
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

#import "MyLauncherGenericItem.h"

@implementation MyLauncherGenericItem

@synthesize genericDelegate = _genericDelegate;


-(id)initWithTitle:(NSString*)title delegate:(id<MyLauncherGenericItemDelegate>)genericDelegate deletable:(BOOL)deletable {
    if((self = [super initWithTitle:title deletable:deletable]))
	{
        _genericDelegate = genericDelegate;
	}
	return self;
}

-(void)selected:(MyLauncherViewController*)parent {
    [_genericDelegate start];
}

-(UIImage*)icon {
    return [_genericDelegate icon];
}

-(NSMutableDictionary*)itemToSave {
    NSMutableDictionary *itemToSave = [super itemToSave];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_genericDelegate];
    [itemToSave setObject:data forKey:@"genericDelegate"];
    
    return itemToSave;
}



@end
