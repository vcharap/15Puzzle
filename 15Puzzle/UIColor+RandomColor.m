//
//  UIColor+RandomColor.m
//

#import "UIColor+RandomColor.h"

@implementation UIColor (RandomColor)

+(UIColor*)randomColorExcludingColors:(NSArray*)colors
{
    NSUInteger numColors = 14;

    
    UIColor *color = nil;
    __block BOOL run = YES;
    
    while(run){
        run = NO;
        NSUInteger rand = arc4random()%numColors;
        switch(rand){
            case 0:
            {
                color = [UIColor blackColor];
                break;
            }
            case 1:
            {
                color = [UIColor blueColor];
                break;
            }
            case 2:
            {
                color = [UIColor brownColor];
                break;
            }
            case 3:
            {
                color = [UIColor cyanColor];
                break;
            }
            case 4:
            {
                color = [UIColor darkGrayColor];
                break;
            }
            case 5:
            {
                color = [UIColor grayColor];
                break;
            }
            case 6:
            {
                color = [UIColor greenColor];
                break;
            }
            case 7:
            {
                color = [UIColor lightGrayColor];
                break;
            }
            case 8:
            {
                color = [UIColor magentaColor];
                break;
            }
            case 9:
            {
                color = [UIColor orangeColor];
                break;
            }
            case 10:
            {
                color = [UIColor purpleColor];
                break;
            }
            case 11:
            {
                color = [UIColor redColor];
                break;
            }
            case 12:
            {
                color = [UIColor whiteColor];
                break;
            }
            case 13:
            {
                color = [UIColor yellowColor];
                break;
            }
                
        }
        
        [colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIColor *otherColor = (UIColor*)obj;
            if(CGColorEqualToColor(color.CGColor, otherColor.CGColor)){
                run = YES;
                *stop = YES;
            } 
        }];
        
    }    
    
    return color;
}
@end
