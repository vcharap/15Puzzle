//
//  ArrayPermuteTest.m
//

#import "ArrayPermuteTest.h"
#import "NSArray+Permute.h"


@implementation ArrayPermuteTest
-(void)setUp
{
    [super setUp];
    _array = [[NSMutableArray alloc] init];
    for(int i = 0; i < 16; i++){
        [_array addObject:[NSNumber numberWithInt:i]];
    }

}

-(void)tearDown
{
    [super tearDown];
    [_array release];
}

-(void)testPermute
{
    NSArray *permuted = [_array permutedArray];
    
    STAssertEquals([permuted count], [_array count], @"Permuted array should have same count");
    
    BOOL isSame = YES;
    for(int i = 0; i < [_array count]; i++){
        if(![[_array objectAtIndex:i] isEqualToNumber:[permuted objectAtIndex:i]]){
            isSame = NO;
            break;
        }
    }
    
    STAssertFalse(isSame, @"Permuted array should (with 1 - 1/%d probability) be different", [_array count]);
}
@end
