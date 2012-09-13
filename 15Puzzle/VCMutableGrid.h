//
//  VCMutableGrid.h
//



#import <Foundation/Foundation.h>


/*
    VCMutableGrid: A mutable collection class representing an M by N grid.
*/

@interface VCMutableGrid : NSObject
{
    NSMutableArray *_grid;
    NSUInteger _rows;
    NSUInteger _columns;
}

@property (nonatomic, readonly) NSUInteger rows;
@property (nonatomic, readonly) NSUInteger columns;

/*
    Initializes a grid object. 
 @args
    rows, columns can't be zero, 
    objects can't be nil
    [objects count] must == rows * columns
 
 @return 
    returns a grid on succes, nil on failure (eg if above conditions are not met)
    
*/
-(id)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns objects:(NSArray*)objects;

/*
    Fetches an object at (row, column)
 @args
    row must be in range [0, rows - 1]
    col must be in range [0, columns - 1]
 @return
    returns object at (row, column), or nil if not in range
*/
-(id)objectForRow:(NSUInteger)row column:(NSUInteger)column;

/*
    Replaces object at (row, column) with the object. Does nothing if @args are not correct
 @args
    row must be in range [0, rows - 1]
    column must be in range [0, columns - 1]
    object can't be nil
*/
-(void)replaceObjectAtRow:(NSUInteger)row column:(NSUInteger)colum withObject:(id)object;

/*
    Replaces a row of the grid with a new row. Does nothing if @args are not correct
 @args
    row must be in range [0, rows - 1]
    [objects count] must == rows
*/
-(void)replaceObjectsInRow:(NSUInteger)row withObjects:(NSArray*)objects;

/*
    Replaces a column of the gird with new objects. Does nothing if @args are not correct
 @args
    column must be in range [0, columns - 1]
    [objects count] must == columns
 
*/
-(void)replaceObjectsInColumn:(NSUInteger)column withObjects:(NSArray*)column;

/*
    Gets row of grid
 @args
    row must be in range [0, rows - 1]
 @return
    - An array of objects in requested row, ordered by lowest to highest column value.
    - nil on out of bounds
*/
-(NSArray*)objectsInRow:(NSUInteger)row;

/*
    Gets column of grid
 @args
    column must be in range [0, columns - 1]
 @return
    - An array of objects in requested column, ordered by lowest to highest row value.
    - nil on out of bounds
 */
-(NSArray*)objectsInColumn:(NSUInteger)column;

/*
    Enumerates whole grid, from left to right, top left corner (0, 0) to bottom right corner (rows - 1, columns - 1)
*/
-(void)enumerateUsingBlock:(void (^)(id obj, NSUInteger row, NSUInteger column, BOOL *stop))block;
-(void)enumerateRow:(NSUInteger)row usingBlock:(void (^)(id obj, NSUInteger row, NSUInteger column, BOOL *stop))block;
-(void)enumerateColumn:(NSUInteger)column usingBlock:(void (^)(id obj, NSUInteger row, NSUInteger column, BOOL *stop))block;

/*
    Fetches row, column of requested object
 @args
    Requested object, must not be nil
 @return
    - If object found, returns CGPoint with .x == row, .y == column
    - If object is not found, both .x and .y will == -1
*/
-(CGPoint)rowAndColumnOfObject:(id)object;


/*
    Moves object within a row, shifting other objects as necessary.
    EX: 
        given [A, B, C, D] as the row, moving from column 2 to column 0 => [C, A, B, D]
        given [A, B, C, D], moving column 1 to column 2 => [A, C, B, D]
 @args
    row must be in range [0, rows - 1]
    columns must be in range [0, columns - 1]
*/
-(void)moveObjectInRow:(NSUInteger)row fromColumn:(NSUInteger)column toColumn:(NSUInteger)column;


/*
    Moves object within a column, shifting other objects as necessary. See moveObjectInRow:fromColum:toColumn:
 @args
    row must be in range [0, rows - 1]
    columns must be in range [0, columns - 1]
*/
-(void)moveObjectInColumn:(NSUInteger)column fromRow:(NSUInteger)row toRow:(NSUInteger)row;

@end