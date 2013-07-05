//
//  GCHelper.m
//  CatRace
//
//  Created by Michael Law on 13-03-05.
//
//

#import "GCHelper.h"

@implementation GCHelper
@synthesize gameCenterAvailable; //synthesize the property
@synthesize presentingViewController;
@synthesize match;
@synthesize delegate;

@synthesize playersDict;

#pragma mark Initialization
static GCHelper *sharedHelper = nil;

//#1
+ (GCHelper *) sharedInstance {
    if (!sharedHelper){
        sharedHelper = [[GCHelper alloc] init]; //create the singleton object and authenticates
    }
    return sharedHelper;
}

//#3
//this is from apple's game kit programming guide...
//http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/GameKit_Guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008304-CH1-SW1
-(BOOL)isGameCeneterAvailable {
    //check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    //check if the device is running ios 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

//#2
- (id) init {
    if ((self = [super init])){
        //check if gc is available
        gameCenterAvailable = [self isGameCeneterAvailable];
        //register for authentication changed notification
        //important so that it gets called when authntication completes
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    return self;
}

//#4
//this is a callback.. checks to see whether the change was due to the user being
//authenticated or un-authenticaed and updates a status flag
- (void) authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed:player authenticated");
        userAuthenticated = true;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
}

//look up info for all the players in the match
-(void)lookupPlayers {
    NSLog(@"Looking up %d players...", match.playerIDs.count); //GKmatch object
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            matchStarted = NO;
            [delegate matchEnded];
        } else {
            
            // Populate players dict
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [playersDict setObject:player forKey:player.playerID];
            }
            
            // Notify delegate match can begin
            matchStarted = YES;
            [delegate matchStarted];
            
        }
    }];
}

#pragma mark User functions
//#5
-(void) authenticateLocalUser {
    if(!gameCenterAvailable)return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated==NO){
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
}

//#6
-(void) findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GCHelperDelegate>)theDelegate {
    if (!gameCenterAvailable) return;
    
    //init
    matchStarted = NO; //BOOL
    self.match = nil; //GKMatch
    
    //store away view controler and delegate
    self.presentingViewController = viewController; //UIViewController
    delegate = theDelegate; //GCHelperDelegate
    
    //dismiss any previously existing modal view controllers
    [presentingViewController dismissModalViewControllerAnimated:NO];
    
    //configure the type of match you're looking for
    GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
    request.minPlayers = minPlayers; //such as min
    request.maxPlayers = maxPlayers; //and max (2 and 2)
    
    //new instance with the given request, set delegate to the GCHelper object
    GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
    mmvc.matchmakerDelegate = self;
    
    //uses the passed in view controller to show it on the screen
    [presentingViewController presentModalViewController:mmvc animated:YES];
}

#pragma mark GKMatchmakerViewControllerDelegate
//#7 the three callback methods from the GKMatchmakerViewController...

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    NSLog(@"User cancelled matchmaking");
    [presentingViewController dismissModalViewControllerAnimated:YES];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    
    //close view controller
    [presentingViewController dismissModalViewControllerAnimated:YES];
    
    //set the GKMatch object
    self.match = theMatch;
    //set the delegate of the match to this object.. so it can be notified of incoming data and connection status
    match.delegate = self;

    if (!matchStarted && match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
//called when another player sends data to u
//forwards the data onto the delegate
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (match != theMatch) return;
    [delegate match:theMatch didReceiveData:data fromPlayer:playerID]; //delegate is of the protocol GCHelperDelegate
}

// The player state changed (eg. connected or disconnected)
// if a player disconnects it sets the match as ended and notifies the delegate
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            matchStarted = NO;
            [delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (match != theMatch) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}


@end



















