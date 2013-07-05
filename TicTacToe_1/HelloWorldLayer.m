//
//  HelloWorldLayer.m
//  TicTacToe_1
//
//  Created by Michael Law on 13-03-09.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"


// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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
		
        //set up a menu, label for play button, play button, add to menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Play!" fontName:@"Helvetica" fontSize:30];
        CGSize size = [[CCDirector sharedDirector] winSize];
        CCMenuItemLabel *playButton = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(playScene:)];
        [menu addChild:playButton];
        
        
        CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"GameCenter" fontName:@"Helvetica" fontSize:30];
        CCMenuItemLabel *GCButton = [CCMenuItemLabel itemWithLabel:label2 target:self selector:@selector(GCScene:)];
        [menu addChild:GCButton];
        
        [menu alignItemsInColumns:
         [NSNumber numberWithInt:1],
         [NSNumber numberWithInt:1],
         nil];
        
        [menu setPosition:ccp(size.width/2, size.height/2)];
        [self addChild:menu];
	}
	return self;
}

//called when we click on the play button
-(void) playScene:(id)sender {
    CCLOG(@"->playScene");
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.65f scene:[PlayLayer scene]]];
}

//called when we click on gc match making
-(void) GCScene:(id)sender {
    CCLOG(@"->GCScene");
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.65f scene:[GCPlayLayer scene]]];
}
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
