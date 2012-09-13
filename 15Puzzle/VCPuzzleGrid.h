//
//  VCPuzzleGrid.h
//



#import <Foundation/Foundation.h>
#import "VCMutableGrid.h"

extern NSString *IllegalMoveException;
typedef enum
{
    direction_t_up,
    direction_t_right,
    direction_t_down,
    direction_t_left,
    
    direction_t_none = INT_MAX
    
} direction_t;

/*
    VCPuzzleGrid: An object representing the puzzle and puzzle state 
*/

@interface VCPuzzleGrid : NSObject
{
    VCMutableGrid *_grid;
    NSUInteger _rows;
    NSUInteger _columns;
    NSArray *_views;
    NSNull *_null;
}

@property (nonatomic, copy) NSArray *views;

/* Initialize a VCPuzzle Object
 @args
    An array of 15 UIView items in "finished" order. 
 @return
    An initialized puzzle object, or nil on failure
 */
-(id)initWithViews:(NSArray*)views;

/* Rearranges the cells in the puzzle to create a new puzzle state */
-(void)randomize;

/* Returns YES if puzzle is in solved state. NO otherwise */
-(BOOL)isSolved;

/*
 @args 
    - row must be in [0, 3]
    -  column mst be in [0, 3]
 @return
    Returns object at (row, column), or nil on out of bounds
 */
-(id)objectForRow:(NSUInteger)row colum:(NSUInteger)column;

/*
 @args
    - A view contained in the puzzle
    - The direction in which to look for contigous views
 @return
    - An array of views, not including the argument, that exist in the
    given direction from the argument, up to NULL view 
 */
-(NSArray*)contiguousViewsForView:(UIView*)view forDirection:(direction_t)direction;

/*
 @args 
    - A view contained in the puzzle
    - A direction
 @return
    - Returns YES if there is a NULL view in the specified direction from the argument
    - Returns NO if no such NULL present, or if the view is not in the puzzle
 */
-(BOOL)canMoveView:(UIView*)view inDirection:(direction_t)direction;

/*
 @args 
    - A view in the puzzle
 @return
    - The possible move direction, or direction_t_none if no move possible
 */
-(direction_t)openMoveDirectionForView:(UIView*)view;

/*
 Changes the puzzle state by moving the argument (AND ANY OTHER VIEWS BETWEEN argument view
 and the NULL VIEW) in the given direction. Throws an 'IllegalMoveException' exception if
 the argument view can't be moved in the given direction
 
 @args 
    - A view in the puzzle
    - A direction in which the view can move
 */
-(void)didMoveView:(UIView*)view inDirection:(direction_t)direction;

-(void)enumerateUsingBlock:(void (^)(id obj, NSUInteger row, NSUInteger col, BOOL *stop))block;
@end
