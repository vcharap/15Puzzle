//
//  MutableGridTest.m
//

#define R_LEN 4
#define C_LEN 4

#import "MutableGridTest.h"
#import "NSMutableArray+Move.h"

@implementation MutableGridTest
-(void)setUp
{
    [super setUp];
    
    rowLen = 4;
    colLen = 4;
    _arr = [[NSMutableArray alloc] init];
    for(int i = 0; i < rowLen * colLen; i++){
        [_arr addObject:[NSNumber numberWithInt:i]];
    }
    _grid = [[VCMutableGrid alloc] initWithRows:rowLen columns:colLen objects:_arr];
}

-(void)tearDown
{
    [super tearDown];
    [_grid release];
}

-(NSMutableArray*)numbersArrayWithLength:(NSUInteger)len startingValue:(NSInteger)value;
{
    NSMutableArray *arr = [[[NSMutableArray alloc] initWithCapacity:len] autorelease];
    for(int i = 0; i < len; i++, value++){
        [arr addObject:[NSNumber numberWithInt:value]];
    }
    return arr;
}

#pragma mark Tests!

-(void)testCorrectInitialization
{
    STAssertEquals([_arr count], _grid.rows * _grid.columns, @"Grid and array should have same num elems");
    
    for(int i = 0; i < rowLen; i++){
        for(int j = 0; j < colLen; j++){
            STAssertEquals([_grid objectForRow:i column:j], [_arr objectAtIndex:4*i + j], @"After init, grid and array should have same objects in same order ");
        }
    }
    
}

-(void)testOutOfBoundsGetter
{
    id obj = [_grid objectForRow:2 column:colLen + 1];
    STAssertNil(obj, @"Getter for out of bounds column should return nil");
    
    obj = [_grid objectForRow:rowLen + 10 column:2];
    STAssertNil(obj, @"Getter for out of bounds row should return nil");
    
    obj = [_grid objectForRow:rowLen + 5 column:colLen +10];
    STAssertNil(obj, @"Getter for ouf of bounds row, column should return nil");
}

-(void)testColumnGetter
{
    NSMutableArray *arr = [NSMutableArray array];
    for(int i = 0; i < colLen; i++){
        [arr addObject:[NSNumber numberWithInt:i * 4]];
    }
    
    NSArray *column = [_grid objectsInColumn:0];
    
    for(int i = 0; i < colLen; i++){
        STAssertEquals([arr objectAtIndex:i], [column objectAtIndex:i], @"Column getter should return values of column");
    }
}

-(void)testRowGetter
{
    NSMutableArray *arr = [self numbersArrayWithLength:rowLen startingValue:0];
    NSArray *rows = [_grid objectsInRow:0];
    
    for(int i = 0; i < rowLen; i++){
        STAssertEquals([arr objectAtIndex:i], [rows objectAtIndex:i], @"Row getter should return appropriate row values");
    }
}

-(void)testObjectSetter
{
    NSNumber *num = [NSNumber numberWithInt:100];
    [_grid replaceObjectAtRow:20 column:3 withObject:num];
    
    for(int i = 0; i < rowLen; i++){
        for(int j = 0; j < colLen; j++){
            STAssertEquals([_grid objectForRow:i column:j], [_arr objectAtIndex:4*i + j], @"Grid and array should have same objects after setter set out of bounds item");
        }
    }
    
    NSUInteger row = 3;
    NSUInteger col = 2;
    
    [_grid replaceObjectAtRow:row column:col withObject:num];
    
    STAssertEquals(num, [_grid objectForRow:row column:col], @"Setter should return set object");
}

-(void)testRowSetter
{
    NSMutableArray *arr = [self numbersArrayWithLength:rowLen startingValue:10];
    [_grid replaceObjectsInRow:2 withObjects:arr];
    
    NSArray *replaced = [_grid objectsInRow:2];
    
    for(int i = 0; i < rowLen; i++){
        STAssertEquals([arr objectAtIndex:i], [replaced objectAtIndex:i], @"Row should equal replaced row");
    }
}

-(void)testColumnSetter
{
    NSMutableArray *arr = [self numbersArrayWithLength:rowLen startingValue:10];
    [_grid replaceObjectsInColumn:1 withObjects:arr];
    
    NSArray *replaced = [_grid objectsInColumn:1];
    
    for(int i = 0; i < colLen; i++){
        STAssertEquals([arr objectAtIndex:i], [replaced objectAtIndex:i], @"Column should equal replaced column");
    }
    
}
             
-(void)testRowObjectMove
{
    for(int i = 0; i < colLen; i++){
        NSMutableArray *oldRow = [NSMutableArray arrayWithArray:[_grid objectsInRow:i]];
        
        for(int j = 0; j < 10; j++){
            NSUInteger idx1 = arc4random()%4;
            NSUInteger idx2 = arc4random()%4;
            
            [_grid moveObjectInRow:i fromColumn:idx1 toColumn:idx2];
            
            [oldRow moveObjectFromIndex:idx1 toIndex:idx2];
            
            NSArray *newArray = [_grid objectsInRow:i];
            
            for(int k = 0; k < rowLen; k++){
                STAssertEquals([newArray objectAtIndex:k], [oldRow objectAtIndex:k], @"Moving row objects in grid should mimic movement of objects in an array");
            }
        }
    }
}


-(void)testColumnObjectMove
{
    for(int i = 0; i < rowLen; i++){
        NSMutableArray *oldColumn = [NSMutableArray arrayWithArray:[_grid objectsInColumn:i]];
        
        for(int j = 0; j < 10; j++){
            NSUInteger idx1 = arc4random()%4;
            NSUInteger idx2 = arc4random()%4;
            
            [_grid moveObjectInColumn:i fromRow:idx1 toRow:idx2];
            [oldColumn moveObjectFromIndex:idx1 toIndex:idx2];
            
            NSArray *newColumn = [_grid objectsInColumn:i];
            for(int k = 0; k < colLen; k++){
                STAssertEquals([newColumn objectAtIndex:k], [oldColumn objectAtIndex:k], @"Moving column objects should mimic movement of objects in an array");
            }
        }
    }
}
@end
