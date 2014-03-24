//
//  UIViewAdditions.h
//  Weipai
//
//  Created by wangyong on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface UIView (Additions)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

- (void)setBorderColor:(UIColor *)borderColor;

@end

@interface UIColor (RGB)

+ (UIColor *)colorWithRed:(uint)r green:(CGFloat)g blue:(CGFloat)b ;
@end