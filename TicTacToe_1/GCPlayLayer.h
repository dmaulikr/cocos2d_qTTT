//
//  GCPlayLayer.h
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-10.
//
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLayer.h"
#import "GameObject.h"
#import "GCHelper.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "Constants.h";
#import "Particle.h";

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeGameOver,
    kMessageTypeDoneTurn
} MessageType;

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message; //each Message has a message type
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
} MessageMove;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

typedef struct {
    Message message;
    int turn1Index;
    int turn2Index;
} MessageDoneTurn;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect
} EndReason;

typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone,
    kGameStatePlaying,
    kGameStateWaiting,
    kGameStateObserving
} GameState;

@interface GCPlayLayer : CCLayer <GCHelperDelegate> {
    uint32_t ourRandom;
    BOOL receivedRandom;
    NSString *otherPlayerID;
    
    GameState gameState;
    CCLabelTTF *debugLabel;
    
    BOOL isPlayer1;
    
    NSMutableArray *arrayGameObjs;
    GameObject *touchPointBeganGameObject;
    CGPoint touchPointBeganPoint;
    
    BOOL turn1;
    BOOL turn2;
    
    GameObject *turn1Obj;
    
    BOOL drawline;
    CGPoint drawlineAtPoint;
    
    //AppDelegate * delegate;
    
}

@property (nonatomic,retain) NSMutableArray *arrayGameObjs;
@property (nonatomic,retain) GameObject *touchPointBeganGameObject;
@property (assign) CGPoint touchPointBeganPoint;

@property (nonatomic,retain) GameObject *turn1Obj;

+(CCScene *) scene;

@end
