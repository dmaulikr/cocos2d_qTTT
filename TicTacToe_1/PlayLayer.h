//
//  PlayLayer.h
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-09.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameObject.h"
@interface PlayLayer : CCLayer {
    CGSize winSize;
    NSMutableArray *arrayGameObjs;
    CGPoint touchPointBegan;
    CGPoint touchPointEnded;
    
    GameObject *touchPointBeganGameObject;
    
    BOOL turn1;
    BOOL turn2;
    
}

@property (nonatomic,retain) NSMutableArray *arrayGameObjs;
@property (nonatomic,retain) GameObject *touchPointBeganGameObject;
+(CCScene *) scene;
-(id)init;
@end
