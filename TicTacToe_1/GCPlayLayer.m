//
//  GCPlayLayer.m
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-10.
//
//

#import "GCPlayLayer.h"




@implementation GCPlayLayer
@synthesize arrayGameObjs;
@synthesize touchPointBeganGameObject;
@synthesize turn1Obj;
@synthesize touchPointBeganPoint;

#pragma mark animation
-(CGPoint)getRandomPointFrom:(CGRect)bounds{
    int length = bounds.size.width;
    int xOrigin = bounds.origin.x;
    int yOrigin = bounds.origin.y;
    int x = (arc4random()%length)+xOrigin;
    int y = (arc4random()%length)+yOrigin;
    int whichborder = arc4random()%4;
    switch (whichborder) {
        case 0:
            x=xOrigin;
            break;
        case 1:
            x=xOrigin+length;
            break;
        case 2:
            y=yOrigin;
            break;
        case 3:
            y=yOrigin+length;
            break;
        default:
            x=xOrigin;
            y=yOrigin;
            break;
    }
    return ccp(x,y);
}
-(void)addAnimation:(GameObject *)gameObj atPoint:(CGPoint)point{
    Particle *sprite = [Particle spriteWithFile:@"ball2.png"];
    [sprite setTag:gameObj.index];
    [self addChild:sprite];
    
    [sprite setPosition:ccp(point.x,point.y)];
    
    //move to a random point on the border of the game object
    CGPoint movetoPoint = [self getRandomPointFrom:gameObj.bounds];
    
        //[sprite setIncrementBy:ccp(y-point.y,x-point.x)];
    CCMoveTo *moveto = [CCMoveTo actionWithDuration:1.0f position:movetoPoint];
    [sprite runAction:moveto];
    
    //set animation to run forever rotating
    CCRotateBy *rotate = [CCRotateBy actionWithDuration:2.0f angle:-360];
    CCRepeatForever *repeatRotate = [CCRepeatForever actionWithAction:rotate];
    [sprite runAction:repeatRotate];
    
    
}


-(void) update:(ccTime)deltaTime {
    CCArray *arrayOfParticles = [self children];
    for (Particle *sprite in arrayOfParticles){
        
        if (sprite.tag >= kSpritesIn1 && sprite.tag <=kSpritesIn9){

            
            GameObject *gameObj = [arrayGameObjs objectAtIndex:sprite.tag-1];
            if (sprite.isTouchingBounds == YES) {
                CGPoint newPoint = [self getRandomPointFrom:gameObj.bounds];
                CCMoveTo *moveto = [CCMoveTo actionWithDuration:1.0f position:newPoint];
                [sprite runAction:moveto];
                sprite.isTouchingBounds = NO;
            } else if ([sprite isItTouching:gameObj.bounds]){
                sprite.isTouchingBounds = YES;
            } //one more else if it is touching another object
            
        }
    }
}

#pragma mark send

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    
    MessageRandomNumber message; //struct containing two variables
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
}

- (void)sendGameBegin {
    
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self sendData:data];
    
}
- (void)sendDoneTurns:(GameObject*)turn1obj and:(GameObject*)turn2obj{
    MessageDoneTurn message;
    message.message.messageType = kMessageTypeDoneTurn;
    message.turn1Index = turn1obj.index;
    message.turn2Index = turn2obj.index;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageDoneTurn)];
    [self sendData:data];
    
}
- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
        [debugLabel setString:@"Waiting for match"];
    } else if (gameState == kGameStateWaitingForRandomNumber) {
        [debugLabel setString:@"Waiting for rand #"];
    } else if (gameState == kGameStateWaitingForStart) {
        [debugLabel setString:@"Waiting for start"];
    } else if (gameState == kGameStatePlaying) {
        [debugLabel setString:@"Playing"];
        turn1=YES;
        turn2=NO;
    } else if (gameState == kGameStateWaiting) {
        [debugLabel setString:@"Waiting"];
    } else if (gameState == kGameStateDone) {
        [debugLabel setString:@"Done"];
    } else if (gameState == kGameStateObserving) {
        [debugLabel setString:@"Observing"];
    }
    
    
}

- (void)tryStartGame {
    //player2 may call this but does nothing
    if (isPlayer1 && gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStatePlaying];
        [self sendGameBegin];
        //[self setupStringsWithOtherPlayerId:otherPlayerID];
    }
    
}


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	GCPlayLayer *layer = [GCPlayLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        //set touch events
        self.isTouchEnabled = YES;
        
        //set background to white
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:colorLayer z:-1];
        
        //add debug label
        // Add a debug label to the scene to display current game state
        debugLabel = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:20];
        debugLabel.color = ccc3(0, 0, 0);
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        debugLabel.position = ccp(winSize.width/2, winSize.height*8/10);
        [self addChild:debugLabel];
        
        //set the isPlayer1 variable for now, and a random number to send
        isPlayer1 = YES;
        ourRandom = arc4random();
        
        //create 9 objects
        arrayGameObjs = [[NSMutableArray alloc]init];
        for (int i=0; i<9;i++){
            [arrayGameObjs addObject:[GameObject node]];
        }
        for (int i=0; i<[arrayGameObjs count];i++){
            GameObject *obj = [arrayGameObjs objectAtIndex:i];
            [obj setup:i+1];
        }
        
        //set up
        CGFloat x = 0;
        CGFloat y = 0;
        touchPointBeganPoint = ccp (x,y);
        
        
        //find match and begin game
		AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController delegate:self];
        
        
        [self scheduleUpdate];
	}
	return self;
}

#pragma mark handleTouchEvents
-(void)handleTouchForPlaying:(CGPoint)touchPoint {

    
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
        NSLog(@"Touch: invalid touch");
        return;
    }
    else if (touchPointBeganGameObject.index == touchPointEndedGameObject.index){
        NSLog(@"Touch: touched one object");
        if (turn1 && !turn2){ //if turn 1, we finish turn 1 and get ready for turn2
            if([touchPointBeganGameObject updateWithTurn1:isPlayer1]) {
                turn1Obj = touchPointBeganGameObject;
                turn1 = NO; turn2 = YES;
                [self addAnimation:touchPointBeganGameObject atPoint:touchPointBeganPoint];
            }
        } else if (turn2 && !turn1){ //if turn 2, we finish turn 2
            if([touchPointBeganGameObject updateWithTurn2:isPlayer1 turn1gameobject:turn1Obj]){
                turn2 = NO;
                [self sendDoneTurns:turn1Obj and:touchPointBeganGameObject]; //send message
                [self setGameState:kGameStateWaiting]; //set game state to waiting
                [self addAnimation:touchPointBeganGameObject atPoint:touchPointBeganPoint];
            }
        }
    }
    else if (touchPointBeganGameObject.index != touchPointEndedGameObject.index){ //they are different objects
        NSLog(@"Touch: touched two objects");
        if (turn1 && !turn2) { //we only try if we are on turn 1
            
            if([touchPointBeganGameObject updateWithTurn1:isPlayer1]) {
                turn1=NO;
                turn2=YES;
                turn1Obj = touchPointBeganGameObject;
                [self addAnimation:touchPointBeganGameObject atPoint:touchPointBeganPoint];
                if ([touchPointEndedGameObject updateWithTurn2:isPlayer1 turn1gameobject:touchPointBeganGameObject]) {
                    turn2=NO;
                    int i = [touchPointEndedGameObject.entangledObjs count];
                    NSLog(@"number of entangled objs %d",i);
                    [self sendDoneTurns:turn1Obj and:touchPointEndedGameObject]; //send message
                    [self setGameState:kGameStateWaiting]; //set game state to waiting
                    [self addAnimation:touchPointEndedGameObject atPoint:touchPoint];
                }
            }
        }
    }

}

#pragma mark ccTouches
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:[[CCDirector sharedDirector] openGLView]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    NSLog(@"ccTouchesBegan: (%.0f, %.0f)",touchPoint.x, touchPoint.y);
    
    touchPointBeganGameObject=nil;
    for (int i=0; i<9;i++){
        touchPointBeganGameObject = [arrayGameObjs objectAtIndex:i];
        if([touchPointBeganGameObject isPointInBounds:touchPoint]) {
            //CCLOG(@"We found first obj %d",touchPointBeganGameObject.index);
            touchPointBeganPoint = touchPoint;
            break;
        }
        
        touchPointBeganGameObject=nil;
    }
    
    
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
    CGPoint touchPoint = [[touches anyObject] locationInView:[[CCDirector sharedDirector] openGLView]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    drawline = YES;
    drawlineAtPoint = touchPoint;
    NSLog(@"ccTouchesMoved: (%.0f, %.0f)",touchPoint.x, touchPoint.y);
    */
    
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:[[CCDirector sharedDirector] openGLView]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    //NSLog(@"ccTouchesEnded: (%.0f, %.0f)",touchPoint.x, touchPoint.y);
    
    //[self setGameState:kGameStatePlaying];//remove this
    if (gameState == kGameStatePlaying) {
        [self handleTouchForPlaying:touchPoint];
    }
}

-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark draw
// override this method
- (void)draw {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
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
    
    
    
    GameObject *gameObj;
    for (int i=0; i<9;i++){
        gameObj = [arrayGameObjs objectAtIndex:i];
        if(gameObj.occupied){
            CGPoint from = ccp(CGRectGetMidX(gameObj.bounds),CGRectGetMidY(gameObj.bounds));
            for (int j=0; j<[gameObj.entangledObjs count]; j++) {
                GameObject *tempObj = [gameObj.entangledObjs objectAtIndex:j];
                CGPoint to = ccp(CGRectGetMidX(tempObj.bounds),CGRectGetMidY(tempObj.bounds));
                ccDrawLine(from, to);
            }
        }
        
        
    }
    
    /*
    if(drawline) {
        NSLog(@"drawline");
        glColor4f(0, 0, 0, 1);
        ccDrawPoint(drawlineAtPoint);
    }
    */
    
}


#pragma mark GCHelperDelegate

//protocol GCHelperDelegate

- (void)matchStarted {
    CCLOG(@"Match started");
    
    if (receivedRandom){
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    
    [self sendRandomNumber];
    [self tryStartGame];
     
}

- (void)matchEnded {
    CCLOG(@"Match ended");
    // Disconnects match and ends level
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    //[self endScene:kEndReasonDisconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = [playerID retain];
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        CCLOG(@"Receiver: RandomNumber");
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        CCLOG(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            CCLOG(@"TIE!");
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {
            CCLOG(@"We are player 1 and we start");
            isPlayer1 = YES;
        } else {
            CCLOG(@"We are player 2 and we're waiting");
            isPlayer1 = NO;
        }
        
        if (!tie) {
            receivedRandom = YES;
            if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            }
            [self tryStartGame];
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {
        //only player 2 will get this message
        CCLOG(@"Receiver: GameBegin from player1. We are waiting");
        [self setGameState:kGameStateWaiting];
        //[self setupStringsWithOtherPlayerId:otherPlayerID];
        
    } else if (message->messageType == kMessageTypeMove) {
        
        CCLOG(@"Received move");
        /*
        if (isPlayer1) {
            [player2 moveForward];
        } else {
            [player1 moveForward];
        } */
    } else if (message->messageType == kMessageTypeGameOver) {
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        /*
        if (messageGameOver->player1Won) {
            [self endScene:kEndReasonLose];
        } else {
            [self endScene:kEndReasonWin];
        }
         */
        
    } else if (message->messageType == kMessageTypeDoneTurn) {
        
        MessageDoneTurn *messageDoneTurn = (MessageDoneTurn *)[data bytes];
        CCLOG(@"Received Turns at %d and %d",messageDoneTurn->turn1Index,messageDoneTurn->turn2Index);
        GameObject *turn1obj = [arrayGameObjs objectAtIndex:messageDoneTurn->turn1Index-1];
        GameObject *turn2obj = [arrayGameObjs objectAtIndex:messageDoneTurn->turn2Index-1];
        
        //update turn2object which will updated both objects
        [turn2obj updateWithTurn2:!isPlayer1 turn1gameobject:turn1obj];
        
        //add some animation
        [self addAnimation:turn1obj atPoint:ccp(CGRectGetMidX(turn1obj.bounds),CGRectGetMidY(turn1obj.bounds))];
        [self addAnimation:turn2obj atPoint:ccp(CGRectGetMidX(turn2obj.bounds),CGRectGetMidY(turn2obj.bounds))];
        
        //check array for cyclics
        [turn1obj checkForCycles];
            //check the objects and try to find a cycle..
            //cheeck if the cycle is a collapse
                //if it was then.. stop the animations in that frame, remove them, add the approate ones
                //set the game objects data to "collapsed to isplayer1"
                //send a message to say it was collapse at which objects for which players
            //if cyclic, then set state to another, in this state
                //handle the touch events differently, for example..
                //only allow touches on TWO game gameobjs that should be touched.. (also the two received)
                //

        //start turn
        [self setGameState:kGameStatePlaying];
        
    }
}
@end
