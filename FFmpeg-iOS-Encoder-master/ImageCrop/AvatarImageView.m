//
//  AvatarImageView.m
//  EasyTake
//
//  Created by wangyong on 13-1-18.
//
//

#import "AvatarImageView.h"

@implementation AvatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        [self setUserInteractionEnabled:YES];
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        self.layer.cornerRadius = 30.0f;
        self.layer.borderWidth = 3.0f;
        self.layer.masksToBounds = YES;
        self.multipleTouchEnabled = YES;
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Calculate and store offset, and pop view into front if needed
    startLocation = [[touches anyObject] locationInView:self.superview];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Calculate offset
    CGPoint pt = [[touches anyObject] locationInView:self.superview];
    float dx = pt.x - startLocation.x;
    float dy = pt.y - startLocation.y;
    CGPoint newcenter = CGPointMake(startLocation.x + dx, startLocation.y + dy);

    if (newcenter.x < 30.0)
    {
        newcenter.x = 30.0;
    }
    else if(newcenter.y < 30.0)
    {
        newcenter.y = 30.0;
    }
    else if(newcenter.x > 290.0)
    {
        newcenter.x = 290.0;
    }
    else if(newcenter.y > 450.0) {
        newcenter.y = 450.0;
    }
    
    [self setCenter:newcenter];
}


@end
