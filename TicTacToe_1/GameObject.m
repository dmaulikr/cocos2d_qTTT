//
//  GameObject.m
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-10.
//
//

#import "GameObject.h"

@implementation GameObject
@synthesize index;
@synthesize bounds;
@synthesize occupied;
@synthesize entangledObjs;
@synthesize entangledPlayers;


-(void) dealloc {
    [super dealloc];
}
-(id)init {
    if ((self=[super init])) {
        CCLOG(@"GameObject init");
        observed = NO;
        entangledObjs = [[NSMutableArray alloc] init];
        entangledPlayers = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setup:(int)indexOfObj{
    index = indexOfObj;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat xLength = 0.9*winSize.width;
    CGFloat z = xLength/3; //the length of one side of the squares
    CGFloat x = (winSize.width - xLength)/2; //xMargin
    CGFloat yLength = xLength;
    CGFloat y = (winSize.height - yLength)/2; //yMargin


    switch (index) {
        case 1:
            bounds = CGRectMake(x, y+2*z, z, z);
            break;
        case 2:
            bounds = CGRectMake(x+z, y+2*z, z, z);
            break;
        case 3:
            bounds = CGRectMake(x+2*z,y+2*z, z, z);
            break;
        case 4:
            bounds = CGRectMake(x, y+z, z, z);
            break;
        case 5:
            bounds = CGRectMake(x+z, y+z, z, z);
            break;
        case 6:
            bounds = CGRectMake(x+2*z, y+z, z, z);
            break;
        case 7:
            bounds = CGRectMake(x, y, z, z);
            break;
        case 8:
            bounds = CGRectMake(x+z, y, z, z);
            break;
        case 9:
            bounds = CGRectMake(x+2*z, y, z, z);
            break;
        default:
            NSLog(@"Object not set up properly");
            break;
    }
}
-(BOOL) isPointInBounds:(CGPoint)touchedPoint {
    return CGRectContainsPoint(bounds, touchedPoint);
    
}

-(BOOL) updateWithTurn1:(BOOL)isPlayer1 {
    if(observed){
        return NO;
    } else {
        NSLog(@"updateWithTurn1 complete");
        
        return YES;
    }
}
-(BOOL) updateWithTurn2:(BOOL)isPlayer1 turn1gameobject:(GameObject *)turn1gameObj{
    if(!observed && index!=turn1gameObj.index){
        [entangledObjs addObject:turn1gameObj];
        [entangledPlayers addObject:[NSNumber numberWithBool:isPlayer1]];
        [turn1gameObj.entangledObjs addObject:self];
        [turn1gameObj.entangledPlayers addObject:[NSNumber numberWithBool:isPlayer1]];
        //NSLog(@"updatewithTurn2 complete  %d and %d", [turn1gameObj.entangledObjs count],[self.entangledObjs count] );
        return YES;
    } else {
        return NO;
    }
}
-(BOOL)containsLinkToContinue:(int)index withCallerIndex:(int)callerIndex{
    BOOL containLink = NO;
    for (int i=0; i<[self.entangledObjs count];i++){
        GameObject *entangledObj = [entangledObjs objectAtIndex:i];
        if (entangledObj.index == index){
            containLink = YES;
        } else if (entangledObj.index != callerIndex) {
            containLink = [entangledObj containsLinkToContinue:index withCallerIndex:self.index];
        }
    }
    return containLink; //there are no links, and we return false cuz we didn't find anything
    //there will always be a link...
}
-(BOOL)containsLinkTo:(int)index{
    
    BOOL cycle = NO;
    BOOL findOurselfFirst = NO;
    //we have to find index. there will always be the first one
    //look at each entangled object this guy has
    for (int i=0; i<[self.entangledObjs count]; i++){
        GameObject *entangledObj = [entangledObjs objectAtIndex:i];
        if (entangledObj.index == index && !findOurselfFirst){
            NSLog(@"of course we found ourselves %d",entangledObj.index);
            findOurselfFirst = YES;
        } else if (entangledObj.index == index) {
            NSLog(@"we found ourselves again! this must mean the simple collapse case");
            return YES;
        } else {
            return [entangledObj containsLinkToContinue:index withCallerIndex:self.index];
        }
    }
    return NO;
    
}
-(BOOL) checkForCycles{
    //take a look at all the objects that this object links to
    //each of these objects will have a link back to this object so we have to skip the first occurnece.
        //the first function call returns what the second function call returns..
        //the second function returns once true then we're done and we found a cycle
    NSLog(@"checkForCycles");
    
    //for each object that it has a link to
    //we check if it contains a link to itself, then there's a cycle
    for (int i=0; i<[entangledObjs count];i++ ) {
        GameObject *entangledObj = [entangledObjs objectAtIndex:i];
        NSLog(@"entangledObj index %d",entangledObj.index);
        if([entangledObj containsLinkTo:self.index]){
            NSLog(@"there's a cycle");
        } else
        {
            NSLog(@"there's no cycle");
        }
    }
    
}
@end
