//
//  VCOutlineView.m
//

#import "VCOutlineView.h"

@implementation VCOutlineView
@synthesize outlineColor = _color;

-(UIColor*)outlineColor
{
    if(_color){
        return _color;
    }
    else{
        return [UIColor grayColor];
    }
}

- (void)drawRect:(CGRect)rect
{
    //Init context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetStrokeColorWithColor(context, self.outlineColor.CGColor);
    CGContextSetShadow(context, CGSizeMake(2, 2), 1);
    
    //Create Path
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddRect(context, self.frame);
    
    //Paint path
    CGContextStrokePath(context);
}

-(void)dealloc
{
    [super dealloc];
    [_color release];
}

@end
