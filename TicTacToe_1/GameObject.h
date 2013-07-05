//
//  GameObject.h
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-10.
//
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameObject : CCSprite {
    int index; //index of object
    CGRect bounds; //area of object
    BOOL occupied;
    
    NSMutableArray *entangledObjs; //objs entangled with this one
    NSMutableArray *entangledPlayers; //whose entanglement the link belongs to
    
    BOOL observed; //holds the final value
}
@property (assign) int index;
@property (assign) CGRect bounds;
@property (assign) BOOL occupied;


@property (nonatomic,retain) NSMutableArray *entangledObjs;
@property (nonatomic,retain) NSMutableArray *entangledPlayers;


-(void)setup:(int)index;
-(BOOL) isPointInBounds:(CGPoint)touchedPoint;

-(BOOL) updateWithTurn1:(BOOL)isPlayer1;
-(BOOL) updateWithTurn2:(BOOL)isPlayer1 turn1gameobject:(GameObject *)turn1gameObj;

-(BOOL) checkForCycles;
@end
