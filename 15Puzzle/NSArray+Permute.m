//
//  NSArray+Permute.m
//

#include <stdlib.h>
#import "NSArray+Permute.h"


@implementation NSArray (Permute)
-(NSArray*)permutedArray
{
    NSMutableArray *permuted = [[[NSMutableArray alloc] initWithCapacity:[self count]] autorelease];
    NSMutableArray *old = [NSMutableArray arrayWithArray:self];
    
    for(int i = [self count]; i>0; i--){
        int rand = arc4random()%i;
        [permuted addObject:[old objectAtIndex:rand]];
        [old removeObjectAtIndex:rand];
    }
    
    return [NSArray arrayWithArray:permuted];
}
@end
