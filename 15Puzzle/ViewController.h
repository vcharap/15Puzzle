//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import "VCPuzzleGrid.h"

@interface ViewController : UIViewController
{
    VCPuzzleGrid *_puzzle;          //The puzzle model object
    NSArray *_views;                //The 16 views of the puzzle
    UIImageView *_bgImageView;
    
    CGFloat _viewWidth;
    CGFloat _viewHeight;
    
    
    NSArray *_trackedViews;         //views to be moved by pan gesture
    direction_t _trackingDirection;
    BOOL _trackingPan;              //flag for limiting touches when gesture present
    
    //pan gesture helper vars
    CGPoint _maxOrigin;
    CGPoint _minOrigin;
    CGPoint _initialOrigin;
}

@property (nonatomic, retain) IBOutlet UIImageView *bgImageView;

-(IBAction)pressedNew:(id)sender;
@end
