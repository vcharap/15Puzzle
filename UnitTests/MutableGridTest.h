//
//  MutableGridTest.h
//

#import <SenTestingKit/SenTestingKit.h>
#import "VCMutableGrid.h"

@interface MutableGridTest : SenTestCase
{
    VCMutableGrid *_grid;
    NSMutableArray *_arr;
    
    NSUInteger rowLen;
    NSUInteger colLen;
    
    BOOL testCounter;
}
@end
