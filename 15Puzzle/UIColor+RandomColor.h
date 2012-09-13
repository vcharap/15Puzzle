//
//  UIColor+RandomColor.h
//

#import <UIKit/UIKit.h>

@interface UIColor (RandomColor)
+(UIColor*)randomColorExcludingColors:(NSArray*)colors;
@end
