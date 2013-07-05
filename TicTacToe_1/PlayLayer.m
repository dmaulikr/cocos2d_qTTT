//
//  PlayLayer.m
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-09.
//
//

#import "PlayLayer.h"


@implementation PlayLayer
@synthesize arrayGameObjs;
@synthesize touchPointBeganGameObject;

+(CCScene *) scene {
    CCScene *scene = [CCScene node];
    PlayLayer *layer = [PlayLayer node];
    [scene addChild:layer];
    return scene;
}

-(id)init{
    if ( (self = [super init]  )){
        CCLOG(@"-->playLayer");
        winSize = [[CCDirector sharedDirector] winSize];
        CCLOG(@"screenSize width:%.0f height:%.0f",winSize.width,winSize.height);
        self.isTouchEnabled = YES;
        
        //int r = arc4random() % 356;
        //int g = arc4random() % 256;
        //int b = arc4random() % 256;
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:colorLayer z:-1];
        
        CCLabelTTF *debugLabel = [CCLabelTTF labelWithString:@"testing" fontName:@"Helvetica" fontSize:20];
        debugLabel.color = ccc3(0, 0, 0);
        debugLabel.position = ccp(winSize.width/2, winSize.height*8/10);
        [self addChild:debugLabel];
    
        
        //create 9 objects
        arrayGameObjs = [[NSMutableArray alloc]init];
        for (int i=0; i<9;i++){
            GameObject *gameObj = [GameObject node];
            [gameObj setup:i+1];
            [arrayGameObjs addObject:gameObj];
            [arrayGameObjs addObject:gameObj];
        }
        int i=[arrayGameObjs count];
        NSLog(@"the array has %d objects in it",i);
        
        //sprite rotation test
        CCSprite *sprite = [CCSprite spriteWithFile:@"Icon-Small.png"];
        [self addChild:sprite];
        [sprite setPosition:ccp(winSize.width/2,winSize.height/2)];
        [sprite setAnchorPoint:ccp(1,1)];
        sprite.rotation = 45;
        
        CCRotateBy *rotate = [CCRotateBy actionWithDuration:1.0f angle:360];
        CCSequence *sequence = [CCSequence actionOne:rotate two:rotate];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:sequence];
        [sprite runAction:repeat];
        
    
        
        
        
    }
    return self;
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:[[CCDirector sharedDirector] openGLView]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    NSLog(@"ccTouchesBegan: (%.0f, %.0f)",touchPoint.x, touchPoint.y);
    
    touchPointBeganGameObject=nil;
    for (int i=0; i<9;i++){
        touchPointBeganGameObject = [arrayGameObjs objectAtIndex:i];
        if([touchPointBeganGameObject isPointInBounds:touchPoint]) {
            CCLOG(@"We found first obj %d",touchPointBeganGameObject.index);
            break;
        }
        touchPointBeganGameObject=nil;
    }
    
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:[[CCDirector sharedDirector] openGLView]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    NSLog(@"ccTouchesEnded: (%.0f, %.0f)",touchPoint.x, touchPoint.y);
    
    //find touched object
    GameObject *touchPointEndedGameObject=nil;
    for (int i=0; i<9;i++){
        touchPointEndedGameObject = [arrayGameObjs objectAtIndex:i];
        if([touchPointEndedGameObject isPointInBounds:touchPoint]) {
            CCLOG(@"We found second obj %d",touchPointEndedGameObject.index);
            break;
        }
        touchPointEndedGameObject=nil;
    }
    
    if (touchPointBeganGameObject==nil || touchPointEndedGameObject == nil){
        //invalid move, we do nothing
        return;
    } else if (touchPointBeganGameObject.index == touchPointEndedGameObject.index){
        //turn 1 or turn 2 happened
        if (turn1 && !turn2){ //if turn 1, we finish turn 1 and get ready for turn2
            turn1 = NO;
            turn2 = YES;
        } else if (turn2 && !turn1){ //if turn 2, we finish turn 2
            turn2 = NO;
        }
    } else { //they are different objects
        if (turn1 && !turn2 && YES) { //if turn 1, we update both objects, the && yes is for the state of the game
            
        } //else it's turn2 and we do nothing
    }
    
}

-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
// override this method
- (void)draw {
    
    CGFloat xLength = 0.9*winSize.width;
    CGFloat xMargin = (winSize.width - xLength)/2;
    CGFloat yLength = xLength;
    CGFloat yMargin = (winSize.height - yLength)/2;
    
    //some points
    //CGPoint p1 = ccp(xMargin, yMargin+yLength);
    CGPoint p2 = ccp(xMargin + xLength/3, yMargin+yLength);
    CGPoint p3 = ccp(xMargin + 2*xLength/3, yMargin+yLength);
    
    CGPoint p4 = ccp(xMargin, yMargin+2*yLength/3);
    //CGPoint p5 = ccp(xMargin + xLength/3, yMargin+2*yLength/3);
    //CGPoint p6 = ccp(xMargin + 2*xLength/3, yMargin+2*yLength/3);
    
    CGPoint p7 = ccp(xMargin, yMargin+yLength/3);
    //CGPoint p8 = ccp(xMargin + xLength/3, yMargin+yLength/3);
    //CGPoint p9 = ccp(xMargin + 2*xLength/3, yMargin+yLength/3);

    // set line smoothing
    glEnable(GL_LINE_SMOOTH);
    // set line width
    glLineWidth(4.0f);
    // set line color. i think 0 0 0 is black
    glColor4f(0, 0, 0, 1.0);
    
    //tic tac toe grid
    ccDrawLine(p4, ccp(xMargin+xLength,yMargin+2*yLength/3));
    ccDrawLine(p7, ccp(xMargin+xLength,yMargin+yLength/3));
    ccDrawLine(p2, ccp(xMargin+xLength/3,yMargin));
    ccDrawLine(p3, ccp(xMargin+2*xLength/3,yMargin));

    //full grid
    /*
    ccDrawLine(p1, ccp(xMargin+xLength,yMargin+yLength));
    ccDrawLine(ccp(xMargin,yMargin), ccp(xMargin+xLength,yMargin));
    ccDrawLine(p1, ccp(xMargin,yMargin));
    ccDrawLine(ccp(xMargin+xLength, yMargin+yLength), ccp(xMargin+xLength,yMargin));
    */
    
    
    
    
    
}

@end
