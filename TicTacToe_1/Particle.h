//
//  Particle.h
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-15.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Particle : CCSprite {
    BOOL isTouchingBounds;

}
@property (assign) BOOL isTouchingBounds;
-(BOOL)isItTouching:(CGRect)bounds;
@end
