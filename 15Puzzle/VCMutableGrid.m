//
//  VCMutableGrid.m
//

#import "VCMutableGrid.h"
#import "NSMutableArray+Move.h"

@implementation VCMutableGrid
@synthesize rows = _rows, columns = _columns;

-(id)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns objects:(NSArray *)objects
{
    if(![objects count] || (rows * columns != [objects count]) ) return nil;
    
    self = [super init];
    if(self){
        _rows = rows;
        _columns = columns;
        _grid = [[NSMutableArray alloc] initWithCapacity:rows];
        
        for(int i = 0; i < rows; i++){
            NSMutableArray *column = [[[NSMutableArray alloc] initWithCapacity:columns] autorelease];
            
            for(int j = 0; j< columns; j++){
                [column addObject:[objects objectAtIndex:(i*columns + j)]];
            }
            [_grid addObject:column];
        }
    }
    return self;
}


-(void)dealloc
{
    [super dealloc];
    [_grid release];
}

-(id)objectForRow:(NSUInteger)row column:(NSUInteger)column
{
    id obj = nil;
    if(row < _rows && column < _columns){
        obj = [[_grid objectAtIndex:row] objectAtIndex:column];
    }
    return obj;
}

-(void)replaceObjectAtRow:(NSUInteger)row column:(NSUInteger)column withObject:(id)object
{ 
    if(row < _rows && column < _columns && object){
        [[_grid objectAtIndex:row] replaceObjectAtIndex:column withObject:object];
    }
}

-(void)replaceObjectsInRow:(NSUInteger)row withObjects:(NSArray *)objects
{
    if([objects count] == _columns && row < _rows){
        for(int i = 0; i < _columns; i++){
            [self replaceObjectAtRow:row column:i withObject:[objects objectAtIndex:i]];
        }
    }
}

-(void)replaceObjectsInColumn:(NSUInteger)column withObjects:(NSArray *)objects
{
    if([objects count] == _rows && column < _columns){
        for(int i = 0; i < _rows; i++){
            [self replaceObjectAtRow:i column:column withObject:[objects objectAtIndex:i]];
        }
    }
}

-(NSArray*)objectsInRow:(NSUInteger)row
{
    NSArray *objects = nil;
    if(row < _rows){
        objects = [NSArray arrayWithArray:[_grid objectAtIndex:row]];
    }
    return objects;
}

-(NSArray*)objectsInColumn:(NSUInteger)column
{
    NSArray *objects = nil;
    if(column < _columns){
        NSMutableArray *columnObjects = [[[NSMutableArray alloc] initWithCapacity:_rows] autorelease];
        [self enumerateColumn:column usingBlock:^(id obj, NSUInteger row, NSUInteger col, BOOL *stop){
            [columnObjects addObject:obj]; 
        }];
        
        objects = [NSArray arrayWithArray:columnObjects];
    }
    return objects;
}

-(void)enumerateUsingBlock:(void (^)(id, NSUInteger, NSUInteger, BOOL *))block
{
    BOOL stop = NO;
    for(int i = 0; i < _rows; i++){
        for(int j = 0; j < _columns; j++){
            block([self objectForRow:i column:j], i, j, &stop);
            
            if(stop) return;
        }
    }
}

-(void)enumerateColumn:(NSUInteger)column usingBlock:(void (^)(id, NSUInteger, NSUInteger, BOOL *))block
{
    BOOL stop = NO;
    for(int i = 0; i < _rows; i++){
        block([self objectForRow:i column:column], i, column, &stop);
        
        if(stop) return;
    }
}

-(void)enumerateRow:(NSUInteger)row usingBlock:(void (^)(id, NSUInteger, NSUInteger, BOOL *))block
{
    BOOL stop = NO;
    for(int i = 0; i < _columns; i++){
        block([self objectForRow:row column:i], row, i, &stop);
        if(stop) return;
    }
}

-(CGPoint)rowAndColumnOfObject:(id)object
{
    CGFloat row = -1;
    CGFloat column = -1;
    
    for(int i = 0; i < _rows; i++){
        NSUInteger idx = [[_grid objectAtIndex:i] indexOfObject:object];
        
        if(idx != NSNotFound){
            row = i;
            column = idx;
        }
    }
    return CGPointMake(row, column);
}


-(void)moveObjectInColumn:(NSUInteger)column fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow
{
    if(column < _columns){
        NSMutableArray *columnObjects = [NSMutableArray arrayWithArray:[self objectsInColumn:column]];
        [columnObjects moveObjectFromIndex:fromRow toIndex:toRow];
        
        [self replaceObjectsInColumn:column withObjects:columnObjects];
    }
}

-(void)moveObjectInRow:(NSUInteger)row fromColumn:(NSUInteger)fromColumn toColumn:(NSUInteger)toColumn
{
    if(row < _rows){
        NSMutableArray *rowObjects = [_grid objectAtIndex:row];
        [rowObjects moveObjectFromIndex:fromColumn toIndex:toColumn];
    }
}


@end
