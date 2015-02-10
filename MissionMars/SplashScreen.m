//
//  SplashScreen.m
//  MissionMars
//
//  Created by Kamlesh on 05/01/14.
//  Copyright 2014 Kamlesh. All rights reserved.
//

#import "SplashScreen.h"
#import "MainScreen.h"
#import "CCParallaxNode-Extras.h"
#import "RemoveNode.h"

///** Remove the node from parent and cleanup
// */
//@interface RemoveNode : CCActionInstant
//{}
//@end
//
//@implementation RemoveNode
//-(void) startWithTarget:(id)aTarget
//{
//	[super startWithTarget:aTarget];
//	[((CCNode *)aTarget) removeFromParentAndCleanup:YES];
//}
//
//@end

@implementation SplashScreen

@synthesize level;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) sceneWithLevel:(Level) level_
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SplashScreen *layer = [SplashScreen node];
	layer.level = level_;	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		

	}
	return self;
}

-(void) onEnter
{
	[super onEnter];
	
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	NSString *startSplash = nil;
	NSString *overSplash = nil;
	
	if (level == Level2) {
		startSplash = @"level2_start.png";
		overSplash = @"level1_over.png";
	} else if (level == Level3) {
		startSplash = @"level3_start.png";
		overSplash = @"level2_over.png";
	} else if (level == LevelFinish) {
		
	} else {
		startSplash = @"level3_GameOver.png";
		overSplash = @"level3_over.png";
	}
	
	CCSprite *background1 = [CCSprite spriteWithFile:startSplash];
	background1.position = ccp(size.width/2, size.height/2);
	[self addChild: background1];
	
	if (level != LevelLost) {
		CCSprite *background = [CCSprite spriteWithFile:overSplash];
		background.position = ccp(size.width/2, size.height/2);
		[self addChild: background];
		
		[background runAction:[CCSequence actions:
													 [CCFadeOut actionWithDuration:5.0], [RemoveNode action], nil]];
	}
	
	
	NSString *startStinrg = @"Start";
	if (IS_IPAD) {
		// add the label as a child to this Layer
		startStinrg = @"          ";
	}
	
	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:startStinrg block:^(id sender) {
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainScreen sceneWithLevel:level] ]];
	}];
	
	
	CCMenu *menu = [CCMenu menuWithItems:itemAchievement, nil];
	
	[menu alignItemsHorizontallyWithPadding:20];
	[menu setPosition:ccp( size.width/2, size.height/2 - 135)];
	
	// Add the menu to the layer
	[self addChild:menu];
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
