//
//  VCPuzzleGrid.m
//

#import "VCPuzzleGrid.h"
#import "NSArray+Permute.h"

NSString *IllegalMoveException = @"IllegalMoveException";

@interface VCPuzzleGrid ()
/* Initializes the backing VCMutableGrid object. Adds a tag number to ever view */
-(void)initGrid;

/*  */
-(void)populateGridWithObjects:(NSArray*)objects;
-(BOOL)isSolvable:(NSArray*)array;
@end

@implementation VCPuzzleGrid
@synthesize views = _views;

-(id)initWithViews:(NSArray *)views
{
    if([views count] != 15) return nil;
    
    self = [super init];
    if(self){
        _null = [[NSNull null] retain];
        _views = [[views arrayByAddingObject:_null] retain];
        [self initGrid];
    }
    return self;
}


-(void)dealloc
{
    [_views release];
    [_grid release];
    [_null release];
    [super dealloc];
}

#pragma mark public methods

-(void)randomize
{
    NSArray *permutation = [_views permutedArray];
    while(![self isSolvable:permutation]){
        permutation = [_views permutedArray];
    }
    
    [self populateGridWithObjects:permutation];
}

-(BOOL)isSolved
{
    __block BOOL solved = YES;
    [_grid enumerateUsingBlock:^(id obj, NSUInteger row, NSUInteger column, BOOL *stop) {
        if([obj isKindOfClass:[UIView class]] && ((UIView*)obj).tag != (row * 4 + column) + 1){
            solved = NO;
            *stop = YES;
        }
    }];
    
    return solved;
}

-(id)objectForRow:(NSUInteger)row colum:(NSUInteger)column
{
    return [_grid objectForRow:row column:column];
}

-(BOOL)canMoveView:(UIView *)view inDirection:(direction_t)direction
{
    CGPoint viewLocation = [_grid rowAndColumnOfObject:view];
    CGPoint nullLocation = [_grid rowAndColumnOfObject:_null];
    
    if(viewLocation.x < 0 || nullLocation.x < 0) return NO;
    
    BOOL canMove = NO;
    
    if(direction == direction_t_up || direction == direction_t_down){
        if(viewLocation.y == nullLocation.y) canMove = YES;
    }
    else if (direction == direction_t_left || direction == direction_t_right){
        if(viewLocation.x == nullLocation.x) canMove = YES;
    }
    
    return canMove;
}

-(NSArray*)contiguousViewsForView:(UIView *)view forDirection:(direction_t)direction
{
    CGPoint viewLocation = [_grid rowAndColumnOfObject:view];
    if(viewLocation.x < 0) return nil;

    NSArray *objects = nil;
    NSUInteger viewIndex;
    
    if(direction == direction_t_up || direction == direction_t_down){
        objects = [_grid objectsInColumn:viewLocation.y];
        viewIndex = viewLocation.x;
    }
    else if(direction == direction_t_left || direction == direction_t_right){
        objects = [_grid objectsInRow:viewLocation.x];
        viewIndex = viewLocation.y;
    }
    
    NSUInteger nullIndex = [objects indexOfObject:_null];
    if(nullIndex == NSNotFound) return nil;
    
    NSRange subRange;
    if(nullIndex < viewIndex){
        subRange = NSMakeRange(nullIndex + 1, viewIndex - nullIndex - 1);
    }
    else{
        subRange = NSMakeRange(viewIndex + 1, nullIndex - viewIndex - 1);
    }
    
    return [objects subarrayWithRange:subRange];
}

-(direction_t)openMoveDirectionForView:(UIView *)view
{
    CGPoint viewLocation = [_grid rowAndColumnOfObject:view];
    CGPoint nullLocation = [_grid rowAndColumnOfObject:_null];
    
    direction_t moveDirection = direction_t_none;
    
    if(viewLocation.x == nullLocation.x){
        if(viewLocation.y < nullLocation.y){
            moveDirection = direction_t_right;
        }
        else{
            moveDirection = direction_t_left;
        }
    }
    else if(viewLocation.y == nullLocation.y){
        if(viewLocation.x < nullLocation.x){
            moveDirection = direction_t_down;
        }
        else{
            moveDirection = direction_t_up;
        }
    }
    return moveDirection;
}

-(void)didMoveView:(UIView *)view inDirection:(direction_t)direction
{
    
    direction_t possibleDirection = [self openMoveDirectionForView:view];
    if(direction != possibleDirection){
        NSException *exception = [NSException exceptionWithName:IllegalMoveException 
                                                         reason:[NSString stringWithFormat:@"Moved view in illegal direction %d. Allowed move is in %d direction", direction, possibleDirection] 
                                                       userInfo:nil];
        
        @throw exception;
        return;
    }
    
    CGPoint viewLocation = [_grid rowAndColumnOfObject:view];
    CGPoint nullLocation = [_grid rowAndColumnOfObject:_null];
    

    if(direction == direction_t_down || direction == direction_t_up){
        [_grid moveObjectInColumn:viewLocation.y fromRow:nullLocation.x toRow:viewLocation.x];
    }
    else if(direction == direction_t_right || direction == direction_t_left){
        [_grid moveObjectInRow:viewLocation.x fromColumn:nullLocation.y toColumn:viewLocation.y];
    }
    
}

-(void)enumerateUsingBlock:(void (^)(id, NSUInteger, NSUInteger, BOOL *))block
{
    [_grid enumerateUsingBlock:block];
}

#pragma mark Private Methods

-(BOOL)isInBoundsRow:(NSInteger)row column:(NSInteger)column
{
    return row >= 0 && row <4 && column >=0 && column <4;
}


-(void)initGrid
{
    NSUInteger count = 1;
    for(id obj in _views){
        if([obj isKindOfClass:[UIView class]]){
            ((UIView*)obj).tag = count;
        }
        count++;
    }
    
    _grid = [[VCMutableGrid alloc] initWithRows:4 columns:4 objects:_views];
}

-(void)populateGridWithObjects:(NSArray *)objects
{
    [_grid release];
    _grid = [[VCMutableGrid alloc] initWithRows:4 columns:4 objects:objects];
}


-(BOOL)isSolvable:(NSArray*)array
{
    NSUInteger len = [_views count];
    NSUInteger inversion = 0;
    
    for(int i = 0; i < len; i++){
        id obj = [array objectAtIndex:i];
        
        //find inversions for each value
        if([obj isKindOfClass:[UIView class]] && ((UIView*)obj).tag != 1){
            for(int j = i + 1; j < len; j++){
                id obj2 = [array objectAtIndex:j];
                
                if([obj2 isKindOfClass:[UIView class]] && ((UIView*)obj2).tag < ((UIView*)obj).tag){
                    inversion++;
                }
            }
        }
        else if([obj isKindOfClass:[NSNull class]]){
            NSUInteger row = (NSUInteger)(i/4);
            inversion += row + 1;
        }
    }
    
    return inversion%2 == 0;
}
@end
