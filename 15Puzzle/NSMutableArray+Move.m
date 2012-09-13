//
//  NSMutableArray+Move.m
//

#import "NSMutableArray+Move.h"

@implementation NSMutableArray (Move)
-(void)moveObjectFromIndex:(NSUInteger)fromIdx toIndex:(NSUInteger)toIdx
{
    if(fromIdx < [self count] && toIdx < [self count] && fromIdx != toIdx){
        id tmp = [self objectAtIndex:fromIdx];
        [self removeObjectAtIndex:fromIdx];
        [self insertObject:tmp atIndex:toIdx];
    }
}
@end
