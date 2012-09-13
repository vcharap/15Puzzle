//
//  ViewController.m
//

#import "ViewController.h"
#import "UIColor+RandomColor.h"
#import "VCOutlineView.h"

#define NUMBER_OF_VIEWS 16

#define ANIMATION_TIME 0.25
#define OUTLINE_VIEW_TAG 100


/*
    Private Category
*/
@interface ViewController ()

@property (nonatomic, retain) NSArray *trackedViews;

/* Slices given image into 16 sqaure pieces
 @args 
    a square image
 @return
    an array of 16 UIImages, or nil if the image is not square.
*/
-(NSArray*)sliceImage:(UIImage*)img;

/* Makes a new puzzle state by randomizing VCPuzzleGrid and moving cell views to new locations */
-(void)newGame;

/* Check whether give point is in bounds of _maxOrigin and _minOrigin */
-(BOOL)isInBounds:(CGPoint)point;


/* Normalizes translation for a specified direction, making sure that
   the translation value does not put a view out of bounds. 
 @args
    - the translation
    - the view being translated
    - direction of translation
 
     (Note: it is expected that the view arg is the view
     for which the values _minOrigin and _maxOrigin were set)
 
 @return
    a new translation value for the given direction.
 */
-(CGFloat)normalizeTranslation:(CGPoint)translation forView:(UIView*)view forDirection:(direction_t)direction;

/* Normalizes Y direction translation */
-(CGFloat)normalizedYTranslation:(CGPoint)translation forView:(UIView*)view;

/* Normalizes X direction translation.  */
-(CGFloat)normalizedXTranslation:(CGPoint)translation forView:(UIView*)view;


/* Completes the pan gesture if pan ended mid cell. Informs VCPuzzleGrid if move put puzzle in new state */
-(void)finishPanGesture:(UIGestureRecognizer*)gesture;

/* Pan gesture callback */
-(void)viewPanned:(UIGestureRecognizer*)gesture;

/* Finds the cell for a give point.
    @return
        Returns a specific cell's view, or nil if point does not lie in a cell
*/
-(UIView*)viewForPoint:(CGPoint)point;

/* animates the selected views in specified direction.  */
-(void)animateMoveOfViews:(NSArray*)views inDirection:(direction_t)direction;

/* Shows the 16th cell, removes the border around cells, making a whole image */
-(void)showFinalView;

@end
/*-------------------------------*/


@implementation ViewController
@synthesize bgImageView = _bgImageView;
@synthesize trackedViews = _trackedViews;

#pragma mark Class Housekeeping

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _trackingDirection = direction_t_none;
    _viewHeight = self.bgImageView.frame.size.height/4;
    _viewWidth= self.bgImageView.frame.size.width/4;
    
    NSArray *images = [self sliceImage:[UIImage imageNamed:@"TeeHeeNiceTry.jpg"]];
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < NUMBER_OF_VIEWS; i++){
        CGRect frame = CGRectMake(i%4 * _viewWidth, i/4 * _viewHeight, _viewWidth, _viewHeight);
        UIImageView *view = [[[UIImageView alloc] initWithFrame:frame] autorelease];
        
        view.image = [images objectAtIndex:i];
        view.userInteractionEnabled = YES;
        
        UIView *outline = [[[VCOutlineView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        outline.backgroundColor = [UIColor clearColor];
        outline.tag = OUTLINE_VIEW_TAG;
        [view addSubview:outline];
        
        [array addObject:view];
        
        if(i < 15){
            [self.bgImageView addSubview:view];
        }
        
    }
    
    _views = [[NSArray arrayWithArray:array] retain];
    _puzzle = [[VCPuzzleGrid alloc] initWithViews:[_views subarrayWithRange:NSMakeRange(0, 15)]];
    
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)] autorelease];
    [self.bgImageView addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanned:)] autorelease];
    [self.bgImageView addGestureRecognizer:panGesture];
    
    self.bgImageView.userInteractionEnabled = YES;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.bgImageView = nil;
    [_puzzle release];
    _puzzle = nil;
    
    [_views release];
    _views = nil;
}

-(void)dealloc
{
    [_bgImageView release];
    [_puzzle release];
    [_views release];
    [super dealloc];
}

#pragma mark Actions

-(IBAction)pressedNew:(id)sender
{
    [self newGame];
}

#pragma mark Gestures

-(BOOL)isInBounds:(CGPoint)point
{
    return point.x >= _minOrigin.x && point.x <= _maxOrigin.x && point.y >= _minOrigin.y && point.y <= _maxOrigin.y;
}


-(CGFloat)normalizedYTranslation:(CGPoint)translation forView:(UIView*)view
{
    
    CGRect newFrame = CGRectOffset(view.frame, 0, translation.y);
    CGFloat normalizedTranslation = translation.y;
    
    CGFloat sign = 1;
    if(normalizedTranslation < 0){
        sign = -1;
    }
    
    CGFloat quantity = fabs(normalizedTranslation);
    
    if(![self isInBounds:newFrame.origin]){
        if(newFrame.origin.y > _maxOrigin.y){
            quantity -= (newFrame.origin.y - _maxOrigin.y);
        }
        else if(newFrame.origin.y < _minOrigin.y){
            quantity -= (_minOrigin.y - newFrame.origin.y);
        }
    }

    return quantity*sign;
}

-(CGFloat)normalizedXTranslation:(CGPoint)translation forView:(UIView*)view
{
    CGRect newFrame = CGRectOffset(view.frame, translation.x, 0);
    CGFloat normalizedTranslation = translation.x;
    
    CGFloat quantity = fabs(normalizedTranslation);
    
    if(![self isInBounds:newFrame.origin]){
        if(newFrame.origin.x < _minOrigin.x){
            quantity -= _minOrigin.x - newFrame.origin.x;
        }
        else if(newFrame.origin.x > _maxOrigin.x){
            quantity -= newFrame.origin.x - _maxOrigin.x;
        }
    }
    
    CGFloat sign = normalizedTranslation < 0 ? -1 : 1;
    
    return quantity*sign;
}

-(CGFloat)normalizeTranslation:(CGPoint)translation forView:(UIView*)view forDirection:(direction_t)direction
{
    CGFloat normalizedTranslation;

    if(_trackingDirection == direction_t_up || _trackingDirection == direction_t_down){
        normalizedTranslation = [self normalizedYTranslation:translation forView:view];
    }
    else{
        normalizedTranslation = [self normalizedXTranslation:translation forView:view];
    }
    
    return normalizedTranslation;
}

/*
 The general idea behind pan gesture tracking:
    Find view where pan began, find direction of pan. 
 
    Since a view can move at most one cell, determine maximum and minumum possible
    locations for touched view. Ask VCPuzzleGrid for any views between touched view and the NULL view. These 
    views need to move the same distance as the touched view
 
    Move all the views by translation amount, normalizing translation value so that views do not go out of bounds.
 
    When gesture ends, animate the move if it was not finished.
*/
-(void)viewPanned:(UIGestureRecognizer*)gesture
{
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gesture;
    
    if(!_trackingPan && panGesture.state != UIGestureRecognizerStateBegan) return;
    
    if(panGesture.state == UIGestureRecognizerStateBegan){
        if(_trackingPan) return;
        
        UIView *view = [self viewForPoint:[gesture locationInView:self.view]];
        
        if(view){
            direction_t direction = [_puzzle openMoveDirectionForView:view];
            CGPoint velocity = [panGesture velocityInView:self.bgImageView];
            
            //determine min and max origin values, or quit if no possible move in direction of pan
            if(direction == direction_t_up && velocity.y < 0)
            {
                _maxOrigin = view.frame.origin;
                _minOrigin = CGPointMake(view.frame.origin.x, view.frame.origin.y - _viewHeight);
            }
            else if (direction == direction_t_down && velocity.y > 0){
                _minOrigin = view.frame.origin;
                _maxOrigin = CGPointMake(view.frame.origin.x, view.frame.origin.y + _viewHeight);
            } 
            else if(direction == direction_t_left && velocity.x < 0){
                _minOrigin = CGPointMake(view.frame.origin.x - _viewWidth, view.frame.origin.y);
                _maxOrigin = view.frame.origin;
            } 
            else if (direction == direction_t_right && velocity.x > 0){
                _minOrigin = view.frame.origin;
                _maxOrigin = CGPointMake(view.frame.origin.x + _viewWidth, view.frame.origin.y);
            }
            else{
                _trackingPan = NO;
                return;
            }
    
            _initialOrigin = view.frame.origin;
            _trackingPan = YES;
            _trackingDirection = direction;
            
            //find the views that need to be moved. 
            //NOTE that touched view is being added to end of array!
            self.trackedViews = [[_puzzle contiguousViewsForView:view forDirection:_trackingDirection] arrayByAddingObject:view];
        }
    }
    
    //set new frame values
    CGFloat translation = [self normalizeTranslation:[panGesture translationInView:self.bgImageView] 
                                             forView:[self.trackedViews lastObject] 
                                        forDirection:_trackingDirection];    
    
    
    for(UIView *view in self.trackedViews){
        CGRect newFrame;
        if(_trackingDirection == direction_t_up || _trackingDirection == direction_t_down){
            newFrame = CGRectOffset(view.frame, 0, translation);
        }
        else{
            newFrame = CGRectOffset(view.frame, translation, 0);
        }
        
        view.frame = newFrame;
    }
    
    [panGesture setTranslation:CGPointZero inView:self.bgImageView];
    
    if(panGesture.state == UIGestureRecognizerStateEnded){
        
        [self finishPanGesture:panGesture];
        
        if([_puzzle isSolved]){
            [self performSelector:@selector(showFinalView) withObject:nil afterDelay:ANIMATION_TIME];
        }
        
        _trackingDirection = direction_t_none;
        _trackingPan = NO;
        _maxOrigin = CGPointZero;
        _minOrigin = CGPointZero;
        _initialOrigin = CGPointZero;
        self.trackedViews = nil;
    }
}

-(void)finishPanGesture:(UIGestureRecognizer *)gesture
{
    //finish moves, inform _puzzle of move if move completed
    //
    UIView *view = [self.trackedViews lastObject];
    CGPoint origin = view.frame.origin;
    if(_trackingDirection == direction_t_right){
        if(origin.x > _initialOrigin.x && origin.x < _initialOrigin.x + _viewWidth/2.0){
            [self animateMoveOfViews:self.trackedViews inDirection:direction_t_left];
        }
        else if(origin.x >= _initialOrigin.x + _viewWidth/2.0)
        {
            if(origin.x < _initialOrigin.x + _viewWidth){
                [self animateMoveOfViews:self.trackedViews inDirection:direction_t_right];
            }
            [_puzzle didMoveView:view inDirection:_trackingDirection];
        }
    }
    else if(_trackingDirection == direction_t_down){
        if(origin.y > _initialOrigin.y && origin.y < _initialOrigin.y + _viewHeight/2.0){
            [self animateMoveOfViews:self.trackedViews inDirection:direction_t_up];
        }
        else if(origin.y >= _initialOrigin.y + _viewHeight/2.0)
        {
            if(origin.y < _initialOrigin.y + _viewHeight){
                [self animateMoveOfViews:self.trackedViews inDirection:direction_t_down];
            }
            
            [_puzzle didMoveView:view inDirection:_trackingDirection];
        }
    }
    else if(_trackingDirection == direction_t_left){
        if(origin.x < _initialOrigin.x && origin.x > _initialOrigin.x - _viewWidth/2.0){
            [self animateMoveOfViews:self.trackedViews inDirection:direction_t_right];
        }
        else if(origin.x <= _initialOrigin.x - _viewWidth/2.0){
            if(origin.x > _initialOrigin.x - _viewWidth){
                [self animateMoveOfViews:self.trackedViews inDirection:direction_t_left];
            }
            
            [_puzzle didMoveView:view inDirection:_trackingDirection];
        }
    }
    
    else if(_trackingDirection == direction_t_up){
        if(origin.y < _initialOrigin.y && origin.y > _initialOrigin.y - _viewHeight/2.0){
            [self animateMoveOfViews:self.trackedViews inDirection:direction_t_down];
        }
        else if(origin.y <= _initialOrigin.y - _viewHeight/2.0){
            if(origin.y > _initialOrigin.y - _viewHeight){
                [self animateMoveOfViews:self.trackedViews inDirection:direction_t_up];
            }
            [_puzzle didMoveView:view inDirection:_trackingDirection];
        }
    }

}

-(void)viewTapped:(UIGestureRecognizer*)gesture
{
    if(_trackingPan) return;
    
    UIView *view = [self viewForPoint:[gesture locationInView:self.view]];
    if(view){
        direction_t possibleMove = [_puzzle openMoveDirectionForView:view];
        
        if(possibleMove != direction_t_none){
            NSArray *viewsToMove = [[_puzzle contiguousViewsForView:view forDirection:possibleMove] arrayByAddingObject:view];
            
            [self animateMoveOfViews:viewsToMove inDirection:possibleMove];
            [_puzzle didMoveView:[viewsToMove lastObject] inDirection:possibleMove];
            
            if([_puzzle isSolved]){
                [self performSelector:@selector(showFinalView) withObject:nil afterDelay:ANIMATION_TIME];
            }
        }
    }
}

#pragma mark Private Methods

-(void)newGame
{
    BOOL wasSolved = [_puzzle isSolved];
    
    [_puzzle randomize];
    
    [_puzzle enumerateUsingBlock:^(id obj, NSUInteger row, NSUInteger col, BOOL *stop) {
        if([obj isKindOfClass:[UIView class]]){
            UIView *view = (UIView*)obj;
            view.frame = CGRectMake(col * _viewWidth, row * _viewHeight, view.frame.size.width, view.frame.size.height);
            
            if(wasSolved){
                [[view viewWithTag:OUTLINE_VIEW_TAG] setAlpha:1.0];
            }
        }
    }];
    
    if(wasSolved){
        UIView *last = [_views lastObject];
        [last removeFromSuperview];
        last.alpha = 0.0;
    }
}

-(UIView*)viewForPoint:(CGPoint)point
{
    UIView *view = [self.view hitTest:point withEvent:nil];
    
    if(view == self.view || view == self.bgImageView){
        view = nil;
    }
    else{
        view = [view superview];
    }
    return view;
}


-(void)animateMoveOfViews:(NSArray *)views inDirection:(direction_t)direction
{
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:ANIMATION_TIME 
                     animations:^(void){
                         for(UIView *view in views){
                             
                             if(direction == direction_t_up){
                                 NSUInteger len = floor(view.frame.origin.y / _viewHeight);
                                 
                                 if(len * _viewHeight == view.frame.origin.y){
                                     len -=1;
                                 }
                                 
                                 view.frame = CGRectMake(view.frame.origin.x, len * _viewHeight, view.frame.size.width, view.frame.size.height);
                             }
                             else if(direction == direction_t_down){
                                 NSUInteger len = floor(view.frame.origin.y / _viewHeight);
                                 view.frame = CGRectMake(view.frame.origin.x, len * _viewHeight + _viewHeight, view.frame.size.width, view.frame.size.height);
                             }
                             else if(direction == direction_t_right){
                                 NSUInteger len = floor(view.frame.origin.x / _viewWidth);
                                 view.frame = CGRectMake(len * _viewWidth + _viewWidth, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                             }
                             else if(direction == direction_t_left){
                                 NSUInteger len = floor(view.frame.origin.x / _viewWidth);
                                 
                                 if(len * _viewWidth == view.frame.origin.x){
                                     len -= 1;
                                 }
                                 view.frame = CGRectMake(len * _viewWidth, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                             }
                         }
                     } 
                     completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                     }];
}


-(void)showFinalView
{
    UIView *view = [_views lastObject];
    view.alpha = 0;
    [self.bgImageView addSubview:view];
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:ANIMATION_TIME * 4
                     animations:^{
                         view.alpha = 1.0;
                         
                         for(UIView *view in _views){
                             UIView *outline = [view viewWithTag:OUTLINE_VIEW_TAG];
                             outline.alpha = 0;
                         }
                     }
                     completion:^(BOOL finished) {
                        self.view.userInteractionEnabled = YES;
                    }];
}

-(NSArray*)sliceImage:(UIImage *)image
{
    if(image.size.height != image.size.width) return nil;
    
    NSMutableArray *images = [[[NSMutableArray alloc] init] autorelease];
    CGImageRef img = [image CGImage];
    CGFloat width = CGImageGetWidth(img)/4;
    CGFloat height = CGImageGetHeight(img)/4;
    
    for(int i = 0; i < 4; i++){
        for(int j = 0; j < 4; j++){
            CGRect rect = CGRectMake(j * width, i * height, width, height);
            CGImageRef subImg = CGImageCreateWithImageInRect(img, rect);
            
            [images addObject:[UIImage imageWithCGImage:subImg]];
            CGImageRelease(subImg);
        }
    }
    
    return [NSArray arrayWithArray:images];
}

@end
