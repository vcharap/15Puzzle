//
//  VCPuzzleGridTest.m
//

#import "VCPuzzleGridTest.h"


@implementation VCPuzzleGridTest
-(void)setUp
{
    [super setUp];
    
    _views = [[NSMutableArray alloc] init];
    for(int i = 0; i < 15; i++){
        [_views addObject:[[[UIView alloc] init] autorelease]];
    }
    
    _puzzle = [[VCPuzzleGrid alloc] initWithViews:_views];
}

-(void)tearDown
{
    [super tearDown];
    [_views release];
    [_puzzle release];
}



-(void)testPuzzleInit
{
    for(int i = 0; i < 4; i++){
        for(int j = 0; j < 4; j++){
            id fromGrid = [_puzzle objectForRow:i colum:j];
            
            if([fromGrid isKindOfClass:[NSNull class]]){
                STAssertEquals(i, 3, @"After init, row of Null must be 3");
                STAssertEquals(j, 3, @"After init, column of Null must be 3");
            }
            else{
                UIView *view = [_views objectAtIndex:i*4 + j];
                STAssertEquals(view, fromGrid, @"After init, views must have correct (row, column) value");
                STAssertEquals(((UIView*)fromGrid).tag, i*4 + j +1, @"After init, views must have correct tag values");
            }
        }
    }
}

-(void)testInBoundsGetter
{
    
    for(int i = 0; i < 20; i++){
        NSUInteger row = arc4random()%4;
        NSUInteger column = arc4random()%4;
        
        if(row == 3 && column == 3) continue;
        
        UIView *view = [_views objectAtIndex:row*4+column];
        UIView *fromGrid = [_puzzle objectForRow:row colum:column];
        
        STAssertEquals(view, fromGrid, @"Getter should return correct view");
    }

}

-(void)testOutOfBoundsGetter
{
    NSUInteger row = 10;
    NSUInteger column = 2;
    STAssertNil([_puzzle objectForRow:row colum:column], @"Out of bounds getter should return nil");
}

-(void)testOpenDirectionBeforeRearrange
{
    for(int i = 0; i < 3; i++){
        UIView *view = [_puzzle objectForRow:3 colum:i];
        direction_t direction = [_puzzle openMoveDirectionForView:view];
        
        STAssertEquals(direction, direction_t_right, @"Open move direction should be to the right");
    }
    
    for(int i = 0; i < 3; i++){
        UIView *view = [_puzzle objectForRow:i colum:3];
        direction_t direction = [_puzzle openMoveDirectionForView:view];
        
        STAssertEquals(direction, direction_t_down, @"Open move direction should be down");
    }
}

-(void)testNoOpenMoveDirectionBeforeRearrange
{
    for(int i = 0; i < 3; i++){
        for(int j = 0; j < 3; j++){
            UIView *view = [_puzzle objectForRow:i colum:j];
            direction_t direction = [_puzzle openMoveDirectionForView:view];
            
            STAssertEquals(direction, direction_t_none, @"There should not be an open move direction");
        }
    }
}

-(void)testContiguousViewsDownBeforeRearrange
{
    UIView *view = [_puzzle objectForRow:0 colum:3];
    NSArray *views = [_puzzle contiguousViewsForView:view forDirection:direction_t_down];
    
    STAssertEquals([views count], (NSUInteger)2, @"There should be 2 conitguous views for view at (0, 3)");
    
    STAssertEquals([views objectAtIndex:0], [_puzzle objectForRow:1 colum:3], @"Should have correct contiguous view");
    STAssertEquals([views objectAtIndex:1], [_puzzle objectForRow:2 colum:3], @"Should have correct contiguous view");
}

-(void)testContiguousViewsRightBeforeRearrange
{
    UIView *view = [_puzzle objectForRow:3 colum:0];
    NSArray *views = [_puzzle contiguousViewsForView:view forDirection:direction_t_right];
    
    STAssertEquals([views count], (NSUInteger)2, @"There should be 2 contiguous views for view at (3, 0)");
    
    STAssertEquals([views objectAtIndex:0], [_puzzle objectForRow:3 colum:1], @"Should have correct contiguous view");
    STAssertEquals([views objectAtIndex:1], [_puzzle objectForRow:3 colum:2], @"Should have correct contiguous view");
}

-(void)testNoContigousView
{
    UIView *view = [_puzzle objectForRow:3 colum:2];
    NSArray *views = [_puzzle contiguousViewsForView:view forDirection:direction_t_right];
    
    STAssertEquals([views count], (NSUInteger)0, @"Object at (3, 2) should have no contigous views");
    
    view = [_puzzle objectForRow:2 colum:3];
    views = [_puzzle contiguousViewsForView:view forDirection:direction_t_down];

    STAssertEquals([views count], (NSUInteger)0, @"Object at (2, 3) should have no contiguous views");
}

-(void)testIllegalMoveDirection
{
    for(int i = 0; i < 3; i++){
        for(int j = 0; j < 3; j++){
            STAssertThrows([_puzzle didMoveView:[_puzzle objectForRow:i colum:j] inDirection:direction_t_up], @"Should throw exception on illegal move");
        }
    }
}

-(void)testViewMoveDown
{
    [_puzzle didMoveView:[_puzzle objectForRow:0 colum:3] inDirection:direction_t_down];
    
    STAssertTrue([[_puzzle objectForRow:0 colum:3] isKindOfClass:[NSNull class]], @"NULL should be at (0, 3) after move");
    
    for(int i = 1; i < 4; i++){
        UIView* obj = [_puzzle objectForRow:i colum:3];
        
        STAssertEquals(obj.tag, i * 4, @"After move down, views should be in correct rows");
    }
    
}

-(void)testViewMoveRight
{
    [_puzzle didMoveView:[_puzzle objectForRow:3 colum:1] inDirection:direction_t_right];
    
    STAssertTrue([[_puzzle objectForRow:3 colum:1] isKindOfClass:[NSNull class]], @"NULL shold be at (3, 1) after move");
    
    for(int i = 2; i < 4; i++){
        UIView *obj = [_puzzle objectForRow:3 colum:i];
        STAssertEquals(obj.tag, 12 + i, @"After move to right, views should be in correct columns");
    }
}

-(void)testMultipleMoves
{
    [_puzzle didMoveView:[_puzzle objectForRow:3 colum:2] inDirection:direction_t_right];
    [_puzzle didMoveView:[_puzzle objectForRow:2 colum:2] inDirection:direction_t_down];
    [_puzzle didMoveView:[_puzzle objectForRow:2 colum:0] inDirection:direction_t_right];
    
    STAssertTrue([[_puzzle objectForRow:2 colum:0] isKindOfClass:[NSNull class]], @"NULL shold be at (2, 0) after the 3 moves");
    
    UIView *obj = [_puzzle objectForRow:2 colum:1];
    STAssertEquals(obj.tag, 9, @"After move view should be in correct column");
    
    obj = [_puzzle objectForRow:2 colum:2];
    STAssertEquals(obj.tag, 10, @"After move view should be in correct column");
    
    obj = [_puzzle objectForRow:2 colum:3];
    STAssertEquals(obj.tag, 12, @"After move view should be in correct column");
    
    obj = [_puzzle objectForRow:3 colum:2];
    STAssertEquals(obj.tag, 11, @"After move view should be in correct column");
    
    obj = [_puzzle objectForRow:3 colum:3];
    STAssertEquals(obj.tag, 15, @"After move view should be in correct column");
    
    [_puzzle didMoveView:[_puzzle objectForRow:2 colum:3] inDirection:direction_t_left];
    
    STAssertTrue([[_puzzle objectForRow:2 colum:3] isKindOfClass:[NSNull class]], @"NULL shold be at (2, 3) after subsequent move");
    
    
}

-(void)testInitialStateShouldBeSolved
{
    STAssertTrue([_puzzle isSolved], @"initial state should be solved");
}

-(void)testShouldNotBeSolvedAfterMoves
{
    [_puzzle didMoveView:[_puzzle objectForRow:3 colum:1] inDirection:direction_t_right];
    [_puzzle didMoveView:[_puzzle objectForRow:0 colum:1] inDirection:direction_t_down];
    
    STAssertFalse([_puzzle isSolved], @"Should not be solved after given moves");
}

-(void)testShouldBeSolvableAfterInit
{
    NSMutableArray *puzzleObjs = [NSMutableArray array];
    [_puzzle enumerateUsingBlock:^(id obj, NSUInteger row, NSUInteger col, BOOL *stop) {
        [puzzleObjs addObject:obj];
    }];
    
    STAssertTrue([_puzzle isSolvable:puzzleObjs], @"Initial puzzle state should be solvable");
}
@end
