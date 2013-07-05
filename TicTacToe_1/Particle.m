//
//  Particle.m
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-15.
//
//

#import "Particle.h"

@implementation Particle
@synthesize isTouchingBounds;
-(void) dealloc {
    [super dealloc];
}
-(id)init {
    if ((self=[super init])) {
        CCLOG(@"Particle init");
        isTouchingBounds =NO;
    }
    return self;
}

-(BOOL)isItTouching:(CGRect)bounds {
    int length = bounds.size.width;
    int xOrigin = bounds.origin.x;
    int yOrigin = bounds.origin.y;
    if(position_.x == xOrigin || position_.x == xOrigin+length || position_.y == yOrigin || position_.y == yOrigin+length){
        return true;
    }
    return false;

}
  
@end
