//
//  VCOutlineView.h
//

#import <UIKit/UIKit.h>

/*
    Returns a view with a 2 pixel outline around the border.
*/

@interface VCOutlineView : UIView
{
    UIColor *_color;
}

/* Set the color of the outline. Default is dark gray. Change to outline color will be reflected
    in the subsequent call to drawRect:
*/
@property (nonatomic, retain) UIColor *outlineColor;
@end
