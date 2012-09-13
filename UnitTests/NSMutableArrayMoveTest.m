//
//  NSMutableArrayMoveTest.m
//

#import "NSMutableArrayMoveTest.h"
#import "NSMutableArray+Move.h"

@implementation NSMutableArrayMoveTest
-(void)setUp
{
    [super setUp];
    _length = 10;
    _array = [[NSMutableArray alloc] initWithCapacity:_length];
    _originalArray = [[NSMutableArray alloc] initWithCapacity:_length];
    for(int i = 0; i < _length; i++){
        [_array addObject:[NSNumber numberWithInt:i]];
        [_originalArray addObject:[NSNumber numberWithInt:i]];
    }
}

-(void)tearDown
{
    [super tearDown];
    [_array release];
    [_originalArray release];
}

-(void)checkArrayEqualityOfArray1:(NSArray*)arr1 array2:(NSArray*)arr2 withString:(NSString*)string
{
    for(int i = 0; i < _length; i++){
        STAssertEqualObjects([arr1 objectAtIndex:i], [arr2 objectAtIndex:i], string);
    }
}

-(void)testOutOfBoundsMove
{
    [_array moveObjectFromIndex:3 toIndex:_length + 5];
    
    [self checkArrayEqualityOfArray1:_array array2:_originalArray withString:@"Moving to out of bounds index should not change array"];
}

-(void)testMoveInPlace
{
    [_array moveObjectFromIndex:5 toIndex:5];
    [self checkArrayEqualityOfArray1:_array array2:_originalArray withString:@"Moving in place should not change array"];
}

-(void)testMoveShouldNotChangeLength
{
    [_array moveObjectFromIndex:3 toIndex:_length - 2];
    
    STAssertEquals([_array count], _length, @"Moving object should not change array length");
}

-(void)testMoveToFront
{
    [_array moveObjectFromIndex:_length - 1 toIndex:0];
    
    NSMutableArray *checkArray = [NSMutableArray array];
    for(int i = 0; i < _length - 1; i++){
        [checkArray addObject:[NSNumber numberWithInt:i]];
    }
    
    [checkArray insertObject:[NSNumber numberWithInt:9] atIndex:0];
    
    [self checkArrayEqualityOfArray1:_array array2:checkArray withString:@"Moving object from back to front should make appropriate array"];

}

-(void)testMoveToBack
{
    [_array moveObjectFromIndex:0 toIndex:_length - 1];
    NSMutableArray *checkArray = [NSMutableArray array];
    
    for(int i = 1; i < _length; i++){
        [checkArray addObject:[NSNumber numberWithInt:i]];
    }
    
    [checkArray addObject:[NSNumber numberWithInt:0]];
    
    for(int i = 0; i < _length; i++){
        STAssertEqualObjects([_array objectAtIndex:i], [checkArray objectAtIndex:i], @"Moving object to back should not change array");
    }
}

-(void)testMoveAndInverse
{
    [_array moveObjectFromIndex:2 toIndex:8];
    [_array moveObjectFromIndex:8 toIndex:2];
    
    
    [_array moveObjectFromIndex:8 toIndex:1];
    [_array moveObjectFromIndex:1 toIndex:8];
    
    [_array moveObjectFromIndex:0 toIndex:_length - 1];
    [_array moveObjectFromIndex:_length - 1 toIndex:0];
    
    for(int i = 0; i < _length; i++){
        STAssertEqualObjects([_array objectAtIndex:i], [_originalArray objectAtIndex:i], @"Moving element then moving it back should make original array");
    }
}


-(void)testMove
{
    [_array moveObjectFromIndex:2 toIndex:8];
    
    NSMutableArray *checkArray = [NSMutableArray array];
    
    for(int i = 0; i < 2; i++){
        [checkArray addObject:[NSNumber numberWithInt:i]];
    }
    for(int i = 0; i < 6; i++){
        [checkArray addObject:[NSNumber numberWithInt:i + 3]];
    }
    
    [checkArray addObject:[NSNumber numberWithInt:2]];
    [checkArray addObject:[NSNumber numberWithInt:9]];
    
    [self checkArrayEqualityOfArray1:_array array2:checkArray withString:@"Moving element should produce appropriate array"];
}
@end
