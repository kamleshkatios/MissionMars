//
//  HelloWorldLayer.m
//  MissionMars
//
//  Created by Kamlesh on 04/10/13.
//  Copyright Kamlesh 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "MainScreen.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
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
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {

	
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

//		// create and initialize a Label
//		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Mission Mars" fontName:@"Marker Felt" fontSize:50];
//
//		// position the label on the center of the screen
//		label.position =  ccp( size.width /2 , size.height/2 );
//		
//		// add the label as a child to this Layer
//		[self addChild: label];
//
//				
//		// Default font size will be 28 points.
//		[CCMenuItemFont setFontSize:28];
		
		CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"startScreen.png"];
			background.rotation = 90;
		} else {
			background = [CCSprite spriteWithFile:@"startScreen.png"];
		}
		background.position = ccp(size.width/2, size.height/2);
		
		NSString *startStinrg = @"Start";
		if (IS_IPAD) {
			// add the label as a child to this Layer
			[self addChild: background];
			startStinrg = @"          ";
		}
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:startStinrg block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainScreen sceneWithLevel:Level1]]];
		}];
		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 135)];
		
		// Add the menu to the layer
		[self addChild:menu];
	}
	return self;
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
