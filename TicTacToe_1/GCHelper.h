//
//  GCHelper.h
//  CatRace
//
//  Created by Michael Law on 13-03-05.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

//you define a protocol that you'll use to notify another object of when important events happen
//such as match starting, ending, receiving data from other party
//cocos2d layer will be implementing this protocol
@protocol GCHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID;
@end



//----------VARIABLES----------//
//this GCHelper object will implemnt two protocols.
//notify this object when a match is found or not
//Game Center can notify this object when data is received or the connection status changes

//we adopt the two protocols that contain callback methods:
    //GKMMVCD contains call back from the view controller
    //GKMatchDelegate contains calls when.. player sends data, player state changed, errors
@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> {
    BOOL gameCenterAvailable; //keeps track if gc is available on device
    BOOL userAuthenticated; //is user currently authenticated?
    UIViewController *presentingViewController;
    GKMatch *match;
    BOOL matchStarted;
    id <GCHelperDelegate> delegate;
    
    NSMutableDictionary *playersDict;
}


 
//a property so the game can tell if gc is available
@property (assign, readonly) BOOL gameCenterAvailable;
//static method to retrieve the singleton instance of this class
+ (GCHelper *)sharedInstance;
//method to authenticate the local user
- (void)authenticateLocalUser;

@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (assign) id <GCHelperDelegate> delegate;

//the cocos2d layer will call this to look for someone to play ith
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)theDelegate;

@property (retain) NSMutableDictionary *playersDict;

@end
