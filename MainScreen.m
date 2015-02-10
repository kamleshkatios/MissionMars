//
//  MainScreen.m
//  MissionMars
//
//  Created by Kamlesh on 13/10/13.
//  Copyright 2013 Kamlesh. All rights reserved.
//

#import "MainScreen.h"
#import "CCParallaxNode-Extras.h"
#import "GameOverScene.h"
#import "SplashScreen.h"
#import "RemoveNode.h"

#define MM_BG_SPEED_DUR  0.5f //    ( IS_IPAD ? (6.0f) : (10.0f) )
#define ROATE_SPEED 7.0F

#define MM_BG_SPEED_DUR_IPADRET  1.0f //    ( IS_IPAD ? (6.0f) : (10.0f) )
#define ROATE_SPEED_IPADRET 14 .0F


#define LEVEL_1_METEOR @"met_1_%d.png"
#define LEVEL_1_METEOR_A @"met_1_%da.png"

#define LEVEL1_DISTANCE 1500

#define POINTS_METREOR 200

#define NOOFCHANCES 3

#define INT_DDAL1 2.5
#define INT_DDAL2 1.0
#define INT_DDAL3 0.75
#define INT_DDAL4 0.60

typedef enum {
	DDALevel1 = 0,
	DDALevel2,
	DDALevel3,
	DDALevel4
} DDALevel;

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

@interface MainScreen () {
	CCSprite *mBG1;
	CCSprite *mBG2;
	
	CCParallaxNode *_backgroundNode;
	CCSprite *_spacedust1;
	CCSprite *_spacedust2;
	
	CCSprite *spaceShip;
	
	NSMutableArray *bullets;
	
	CCLabelTTF *distanceLbl;
	CCLabelTTF *pointLbl;
	
  NSMutableArray *meteors;
	int _bulletsDestroyed;
	CMMotionManager *motionManager;

	float distanceTravelled;
	int currentScore;
	int totalScore;
	CCSprite *levelStatus;
	int numberOfChances;
	
	float nextMeteroidIn;
	
	int ddaCounter;
	
	DDALevel ddaLevel;
	
	CCMenu *menuLeft;
	CCMenu *menuRight;
	BOOL isIpadRetina;
	
	CCSprite *collidedMeteorite;
}

@end

@implementation MainScreen

@synthesize level;

+(CCScene *) sceneWithLevel:(Level) level_ {
	
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainScreen *layer = [MainScreen node];
	layer.level = Level2;
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
	
}
// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainScreen *layer = [MainScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


- (CMMotionManager *)motionManager
{
	CMMotionManager *motionManager_ = nil;
	
	id appDelegate = [UIApplication sharedApplication].delegate;
	
	if ([appDelegate respondsToSelector:@selector(motionManager)]) {
		motionManager_ = [appDelegate motionManager];
	}
	
	return motionManager_;
}

- (void)startMyMotionDetect
{
	[self.motionManager
	 startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
	 withHandler:^(CMAccelerometerData *data, NSError *error)
	 {
		 double accX = data.acceleration.x;

		 if (level != Level2) {
			 [self moveSpaceShipWithX:accX];
		 }
	 }];
}

- (void) moveSpaceShipWithX:(double) accX {
	
	__block float stepMoveFactor = 15;

	if (accX > 0.1  || accX < 0.1) {
		dispatch_async(dispatch_get_main_queue(),
									 ^{
										 CGSize winSize = [CCDirector sharedDirector].winSize;
										 
//										 float xPosition = data.acceleration.x;
//										 NSLog(@"Acceleration :%f",xPosition);
										 
										 CGPoint spaceShiptPosition = spaceShip.position;
										 
										 float offfset = spaceShip.contentSize.width;
										 float movetoX = spaceShiptPosition.x + (accX * stepMoveFactor);
										 float maxX = winSize.width - offfset;
										 
										 
										 if ( movetoX > offfset && movetoX < maxX ) {
											 spaceShiptPosition.x += (accX * stepMoveFactor);
											 
											 spaceShip.position = ccp(spaceShiptPosition.x ,20 + spaceShip.contentSize.height);
										 }
									 }
									 );
		
	} else {
		// Do nothing
	}

}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		int offset = 20;
		int xyPosition = 50;
		currentScore = 0;
		numberOfChances = 0;
		ddaLevel = DDALevel1;
		//level = Level1;
		
		if (IS_IPAD) {
			offset = 40;
			xyPosition = 100;
		}

		CGSize winSizePixel = [[CCDirector sharedDirector] winSizeInPixels];
		
		if (winSizePixel.height > 2000) {
			isIpadRetina = YES;
		} else {
			isIpadRetina = NO;
		}
		
		distanceTravelled = LEVEL1_DISTANCE;
		
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

		bullets = [[NSMutableArray alloc] init];
		meteors = [[NSMutableArray alloc] init];
		_bulletsDestroyed = 0;

		[self schedule:@selector(addMeteor:) interval:INT_DDAL1];
		
		[self schedule:@selector(updateDistance:) interval:0.1];

		[self schedule:@selector(ddaEngine:) interval:20];

		
		CGSize winSize = [CCDirector sharedDirector].winSize;

		CCSprite *bgLayer1 = [CCSprite spriteWithFile:@"002_star_layer_1_iPhone5.png"];
		if (IS_IPAD) {
			bgLayer1 = [CCSprite spriteWithFile:@"002_star_layer_1_iPad.png"];
		}
		
		bgLayer1.position = ccp(winSize.width/2,winSize.height/2);
		[self addChild:bgLayer1];

		
		spaceShip = [CCSprite spriteWithFile:@"spaceShip1_Phone.png" rect:CGRectMake(0, 0, 80/2, 64/2)];
		if (IS_IPAD) {
			spaceShip = [CCSprite spriteWithFile:@"spaceShip1.png" rect:CGRectMake(0, 0, 80, 64)];
		}

		spaceShip.position = ccp(winSize.width/2 + ((spaceShip.contentSize.width/2)/2)/2 ,20 + spaceShip.contentSize.height);
		[self addChild:spaceShip];
		[self startMyMotionDetect];

		CCSprite *bgLayer3 = [CCSprite spriteWithFile:@"004_lvl_1_iPhone5.png"];
		if (IS_IPAD) {
			bgLayer3 = [CCSprite spriteWithFile:@"004_lvl_1_iPad.png"];
		}
		
		bgLayer3.position = ccp(winSize.width/2,winSize.height/2);
		[self addChild:bgLayer3];
				
		//Score 
		//scorebg.png
		//_Phone

		CCSprite *scoreBG = [CCSprite spriteWithFile:@"scorebg.png"];

		if (!IS_IPAD) {
			scoreBG = [CCSprite spriteWithFile:@"scorebg_Phone.png"];
		}
		scoreBG.position = ccp(winSize.width/2,winSize.height - scoreBG.contentSize.height/2);
		[self addChild:scoreBG];
		
		CCSprite *scoreCenter = [CCSprite spriteWithFile:@"hp_0.png"];
		if (!IS_IPAD) {
			scoreCenter = [CCSprite spriteWithFile:@"hp_0_Phone.png"];
		}
		scoreCenter.position = ccp(winSize.width/2,winSize.height - scoreCenter.contentSize.height/2);
		[self addChild:scoreCenter];

		//hp_2.png
		
		CCSprite *levelStatusBG = [CCSprite spriteWithFile:@"hp_2.png"];
		if (!IS_IPAD) {
			levelStatusBG = [CCSprite spriteWithFile:@"hp_2_Phone.png"];
		}
		levelStatusBG.position = ccp(scoreCenter.contentSize.width/2, scoreCenter.contentSize.height/2);
		[scoreCenter addChild:levelStatusBG];

		//hp_1
		//189 * 30
		levelStatus = [CCSprite spriteWithFile:@"hp_1.png"];
		if (!IS_IPAD) {
			levelStatus = [CCSprite spriteWithFile:@"hp_1_Phone.png"];
		}
		//		[levelStatus setContentSize:CGSizeMake(10, 30)];
//		levelStatus.textureRect = CGRectMake(0, 0, 0, 15);
//		levelStatus.position = ccp(7, (levelStatusBG.contentSize.height/2));
		[levelStatusBG addChild:levelStatus];
		
		//km_distance_0.png
				
		CCSprite *distanceBG = [CCSprite spriteWithFile:@"km_distance_0.png"];
		if (!IS_IPAD) {
			distanceBG = [CCSprite spriteWithFile:@"km_distance_0_Phone.png"];
		}
		distanceBG.position = ccp(winSize.width/2 - scoreCenter.contentSize.width/2 - distanceBG.contentSize.width/2 + 10,winSize.height - distanceBG.contentSize.height/2);
		[self addChild:distanceBG];
		
		//km_distance_1.png
		
		CCSprite *distanceLblBg = [CCSprite spriteWithFile:@"km_distance_1.png"];
		if (!IS_IPAD) {
			distanceLblBg = [CCSprite spriteWithFile:@"km_distance_1_Phone.png"];
		}
		distanceLblBg.position = ccp((distanceBG.contentSize.width/ 2) - 3, distanceBG.contentSize.height/2);
		[distanceBG addChild:distanceLblBg];

		// create and initialize a Label
		distanceLbl = [CCLabelTTF labelWithString:@"1500KM" fontName:@"Marker Felt" fontSize:10.0];
		[distanceLbl setContentSize:distanceLblBg.contentSize];
    distanceLbl.horizontalAlignment = kCCTextAlignmentRight;
		distanceLbl.position =  ccp( distanceLblBg.contentSize.width /2 , distanceLblBg.contentSize.height/2 );
		[distanceLblBg addChild: distanceLbl];
		
		CCSprite *pointsBG = [CCSprite spriteWithFile:@"points_0.png"];
		if (!IS_IPAD) {
			pointsBG = [CCSprite spriteWithFile:@"points_0_Phone.png"];
		}
		
		pointsBG.position = ccp(scoreCenter.position.x + pointsBG.contentSize.width,winSize.height - pointsBG.contentSize.height/2);
		[self addChild:pointsBG];

		CCSprite *pointsLblBg = [CCSprite spriteWithFile:@"points_1.png"];
				if (!IS_IPAD) {
					pointsLblBg = [CCSprite spriteWithFile:@"points_1_Phone.png"];
				}
		pointsLblBg.position = ccp((pointsBG.contentSize.width/ 2), pointsBG.contentSize.height/2);
		[pointsBG addChild:pointsLblBg];

		pointLbl = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:10.0];
		[pointLbl setContentSize:pointsBG.contentSize];
    pointLbl.horizontalAlignment = kCCTextAlignmentRight;
		pointLbl.position =  ccp( pointsBG.contentSize.width /2 , pointsBG.contentSize.height/2 );
		[pointsBG addChild: pointLbl];
		
		[self reorderChild:scoreCenter z:3];
		//
		
		NSString *thumbImage = @"thumb_ctrl.png";
		if (!IS_IPAD) {
			thumbImage = @"thumb_ctrl_Phone.png";
		}
		

		
		if (level == Level1) {
			CCMenuItemImage *btnLeft = [CCMenuItemImage itemWithNormalImage:thumbImage selectedImage:thumbImage
																																block:^(id sender) {
																																	[self shootObject:sender];
																																}];
			menuLeft = [CCMenu menuWithItems:btnLeft, nil];
			
			[menuLeft alignItemsHorizontallyWithPadding:offset];
			[menuLeft alignItemsVerticallyWithPadding:offset];
			
			[menuLeft setPosition:ccp( xyPosition, xyPosition)];
			
			// Add the menu to the layer
			[self addChild:menuLeft];
			
			CCMenuItemImage *btnRight = [CCMenuItemImage itemWithNormalImage:thumbImage selectedImage:thumbImage
																																 block:^(id sender) {
																																	 [self shootObject:sender];
																																 }];
			
			
			menuRight = [CCMenu menuWithItems:btnRight, nil];
			//		[menuRight alignItemsHorizontallyWithPadding:20];
			[menuRight alignItemsVerticallyWithPadding:offset];
			[menuRight setPosition:ccp( winSize.width - btnRight.contentSize.width, xyPosition)];
			// Add the menu to the layer
			[self addChild:menuRight];

		}
		
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];


	}
	
	return self;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
	
	if (level == Level3) {
		[meteors enumerateObjectsUsingBlock:^(CCSprite *meteorite, NSUInteger idx, BOOL *stop) {
			if (CGRectContainsPoint(meteorite.boundingBox, touchLocation)) {
				[self destroyObject:meteorite];
			}
		}];
	}
}

- (void) destroyObject:(CCSprite *)meteorite {
	CCSprite *explosion = [CCSprite spriteWithFile:@"explosion1.png"];
	explosion.position = meteorite.position;
	[self addChild:explosion];
	
	
	[explosion runAction:[CCSequence actions:
												[CCFadeOut actionWithDuration:0.5], [RemoveNode action], nil]];
	
	// Points display
	NSString *pointsString = [NSString stringWithFormat:@"+%d",POINTS_METREOR];
	CCLabelTTF *pointDisLbl = [CCLabelTTF labelWithString:pointsString fontName:@"Marker Felt" fontSize:12.0];
	//			[pointLbl setContentSize:pointsBG.contentSize];
	pointDisLbl.horizontalAlignment = kCCTextAlignmentRight;
	CGPoint point = meteorite.position;
	point.y += 10;
	pointDisLbl.position = point;
	[self addChild:pointDisLbl];
	
	[pointDisLbl runAction:[CCSequence actions:
													[CCFadeOut actionWithDuration:1.0], [RemoveNode action], nil]];
	
	currentScore += POINTS_METREOR;
	[pointLbl setString:[NSString stringWithFormat:@"%d",currentScore]];
	
	[meteors removeObject:meteorite];
	[self removeChild:meteorite cleanup:YES];
}

//// Add this method
//- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	
//	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
//
//	
//	for (UITouch *touch in touches){
//		CGPoint location = [touch locationInView:[touch view]];
//		location = [[CCDirector sharedDirector] convertToGL:location];
//		//_endPoint = location;
//	}
//}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (level == Level2) {
		CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
		
		if (CGRectContainsPoint(spaceShip.boundingBox, touchLocation)) {
			[self shootObject:nil];
		}

		CGPoint spaceShipPosition = CGPointZero;
		if (touchLocation.x > spaceShip.position.x) {
			// Move Left
			//	[self moveSpaceShipWithX:0.9];
			//spaceShip.position
			spaceShipPosition = ccp(touchLocation.x ,20 + spaceShip.contentSize.height);
		} else if (touchLocation.x < spaceShip.position.x) {
			//[self moveSpaceShipWithX:-0.9];
			//spaceShip.position =
			spaceShipPosition = ccp(touchLocation.x ,20 + spaceShip.contentSize.height);
		}
		
		
		float realMoveDuration = 0.5;
				
		// Move bullet to actual endpoint
		[spaceShip runAction:[CCSequence actions:
											 [CCMoveTo actionWithDuration:realMoveDuration position:spaceShipPosition],
											 nil,
											 nil]];
		
	}
	return TRUE;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	if (level == Level2) {
		CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
		//	[self selectSpriteForTouch:touchLocation];
		
//		if (CGRectContainsPoint(spaceShip.boundingBox, touchLocation)) {
//			[self shootObject:nil];
//			return;
//		}
	}
}

-(void)updateDistance:(ccTime)dt {
	distanceTravelled--;
	
	float value = LEVEL1_DISTANCE - distanceTravelled;
	float statusIndValue = value / (LEVEL1_DISTANCE/95.0);
	
	float offset = 46;

	int valueTemp = LEVEL1_DISTANCE - distanceTravelled;
	int offsetTemp = valueTemp / (LEVEL1_DISTANCE/offset);

	CGPoint position = CGPointMake(0, 0);
	position.x = 8 + offsetTemp;
	position.y = 14;
	
	//levelStatus.position = position;

	levelStatus.textureRect = CGRectMake(0, 0, statusIndValue, 15);

	if (IS_IPAD) {
		offset = 92;
		offsetTemp = valueTemp / (LEVEL1_DISTANCE/offset);
		
		statusIndValue = value / (LEVEL1_DISTANCE/190.0);
		position.y = 28;
		position.x = 14 + offsetTemp;
		levelStatus.textureRect = CGRectMake(0, 0, statusIndValue, 26);
	}
	
	levelStatus.position = position;

	[distanceLbl setString:[NSString stringWithFormat:@"%dKM",(int)distanceTravelled]];
	
		
	if (distanceTravelled <= 0) {		
		NSString *nextLevelStr = @"Level 2";
		if (level == Level1 ) {
			nextLevelStr = @"Level 2";
			level = Level2;
						
			[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SplashScreen sceneWithLevel:level]]];
			
			[self removeChild:menuLeft cleanup:YES];
			[self removeChild:menuRight cleanup:YES];

			return;
			
		}
		else if (level == Level2) {
			nextLevelStr = @"Level 3";
			level = Level3;
			
			[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SplashScreen sceneWithLevel:level]]];
			return;
			
		} else {
			[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SplashScreen sceneWithLevel:LevelFinish]]];
			return;
			
			nextLevelStr = @"Level 3";
			level = Level3;

			GameOverScene *gameOverScene = [GameOverScene node];
			[gameOverScene.layer.label setString:@"You won!!!"];
			[[CCDirector sharedDirector] replaceScene:gameOverScene];

			
			return;
		}
		
		// Reset Distance travelled
		distanceTravelled = LEVEL1_DISTANCE;

		CCLabelTTF *nextLevelLbl = [CCLabelTTF labelWithString:nextLevelStr fontName:@"Marker Felt" fontSize:16.0];
		[nextLevelLbl setColor:ccWHITE];
		//			[pointLbl setContentSize:pointsBG.contentSize];
		nextLevelLbl.horizontalAlignment = kCCTextAlignmentRight;
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		nextLevelLbl.position = CGPointMake(winSize.width/2, winSize.height/2);
		[self addChild:nextLevelLbl];
		
		[nextLevelLbl runAction:[CCSequence actions:
														[CCFadeOut actionWithDuration:5.0], [RemoveNode action], nil]];

		//		[[CCDirector sharedDirector] stopAnimation];

	}
}

/*
 If user has targetted some X objects in some Y time, increase the DDA
 */
-(void) ddaEngine:(ccTime)dt {

	if (ddaCounter > 5) {
		if (ddaLevel == DDALevel1) {
			ddaLevel = DDALevel2;
		}else	if (ddaLevel == DDALevel2) {
			ddaLevel = DDALevel3;
		}else	if (ddaLevel == DDALevel3) {
			ddaLevel = DDALevel4;
		}else {
			ddaLevel = DDALevel4;
		}
	} else {
		if (ddaLevel == DDALevel4) {
			ddaLevel = DDALevel3;
		}else	if (ddaLevel == DDALevel3) {
			ddaLevel = DDALevel2;
		}else	if (ddaLevel == DDALevel2) {
			ddaLevel = DDALevel1;
		}else {
			ddaLevel = DDALevel1;
		}
	}
	
	ddaCounter = 0;
	
	[self changeDDA];
}

-(void) changeDDA {
	float intervalChange = 0;
	if (ddaLevel == DDALevel1) {
		intervalChange = INT_DDAL1;
	}else	if (ddaLevel == DDALevel2) {
		intervalChange = INT_DDAL2;
	}else	if (ddaLevel == DDALevel2) {
		intervalChange = INT_DDAL3;
	} else {
		intervalChange = INT_DDAL4;
	}
	
	[self unschedule:@selector(addMeteor:)];
	[self schedule:@selector(addMeteor:) interval:intervalChange];
}


-(void) addMeteor:(ccTime)dt {
	
	int randNumber = rand() % 4;
	
	if (randNumber == 0) {
		randNumber = 1;
	}
	NSString *randMeteor = [NSString stringWithFormat:LEVEL_1_METEOR,randNumber];
	CCSprite *target =[CCSprite spriteWithFile:randMeteor];
	//[CCSprite spriteWithFile:@"Target.png" rect:CGRectMake(0, 0, 27, 40)];
	
	[self reorderChild:target z:1];

	// Determine where to spawn the target along the Y axis
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minX = target.contentSize.width;
	int maxX = winSize.width - target.contentSize.width;
	int rangeX = maxX - minX;
	int actualX = (rand() % rangeX) + minX;
	
	// Create the target slightly off-screen along the right edge,
	// and along a random position along the Y axis as calculated above
	target.position = ccp(actualX, winSize.height);
	[self addChild:target];
	
	// Determine speed of the target
	int minDuration = 4.0;
	int maxDuration = 6.0;
	int rangeDuration = maxDuration - minDuration;
	int actualDuration = (arc4random() % rangeDuration) + minDuration;
	
	// Create the actions
	id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(actualX, -target.contentSize.height/2)];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];

	[target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
	
	id rot = [CCRotateBy actionWithDuration:ROATE_SPEED angle:360];
	
	id action2 = [CCRepeatForever actionWithAction:
								[CCSequence actions:rot, nil]];
	[target runAction:action2];
	
	// Add to targets array
	target.tag = 1;
	[meteors addObject:target];
	
}


-(void) shootObject:(id) sender {
	
	// Set up initial location of bullet
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCSprite *bullet = [CCSprite spriteWithFile:@"bullet1.png" rect:CGRectMake(0, 0, 78, 100)];
	
	float bulletX = spaceShip.position.x + bullet.contentSize.width/4;
	bullet.position = ccp(bulletX, spaceShip.position.y - bullet.contentSize.height/4);
		
	// Ok to add now - we've double checked position
	[self addChild:bullet];
	
	CGPoint realDest = ccp(bulletX, winSize.height);
	
	float realMoveDuration = 2.24;//2.24;//length/velocity;
	
	if (isIpadRetina) {
		realMoveDuration = 2.24/2.0;
	}
	
	// Move bullet to actual endpoint
	[bullet runAction:[CCSequence actions:
												 [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
												 [CCCallFuncN actionWithTarget:self selector:@selector(bulletMoveFinished:)],
												 nil]];
	
	// Add to bullets array
	bullet.tag = 2;
	[bullets addObject:bullet];

}

- (void) bulletMoveFinished:(id) sender {
	CCSprite *sprite = (CCSprite *)sender;
	[self removeChild:sprite cleanup:YES];
	[bullets removeObject:sprite];
}
-(void)spriteMoveFinished:(id)sender {
	
	CCSprite *sprite = (CCSprite *)sender;
	[self removeChild:sprite cleanup:YES];
	
	[meteors removeObject:sprite];
	
//	if (sprite.tag == 1) { // target
//		[_targets removeObject:sprite];
//		
//		GameOverScene *gameOverScene = [GameOverScene node];
//		[gameOverScene.layer.label setString:@"You Lose :["];
//		[[CCDirector sharedDirector] replaceScene:gameOverScene];
//
//		_missedTargets++;
//		
//	} else if (sprite.tag == 2) { // bullet
//		[_bullets removeObject:sprite];
//	}
}
-(void)onEnter
{
	[super onEnter];
	[self initBackground];
	
	[self schedule: @selector(tick:)];
}


-(void)initBackground
{
	CGSize winSize = [CCDirector sharedDirector].winSize;

	NSString *tex = @"003_star_layer_2_iPhone5.png";
	if (IS_IPAD) {
		tex = @"003_star_layer_2_iPad.png";
	}
	
	mBG1 = [CCSprite spriteWithFile:tex];
	mBG1.position = ccp(winSize.width*0.5f,winSize.height*0.5f);
	[self addChild:mBG1 z:0];
	
	mBG2 = [CCSprite spriteWithFile:tex];
	mBG2.position = ccp(winSize.width*0.5f,winSize.height+winSize.height*0.5f);
	
	mBG2.flipX = true;
	[self addChild:mBG2 z:0];
}


-(void)scrollBackground:(ccTime)dt
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CGPoint pos1 = mBG1.position;
	CGPoint pos2 = mBG2.position;
	
	pos1.y -= MM_BG_SPEED_DUR;
	pos2.y -= MM_BG_SPEED_DUR;
	
	
	if(pos1.y <=-(s.height*0.5f) )
	{
		pos1.y = pos2.y + s.height;
	}
	
	if(pos2.y <=-(s.height*0.5f) )
	{
		pos2.y = pos1.y + s.height;
	}
	
	mBG1.position = pos1;
	mBG2.position = pos2;
	
}

-(void)tick:(ccTime)dt
{
	NSLog(@"Time : %f",dt);
	[self scrollBackground:dt];
	
	// Detect if the meteriod is stricking on space ship
	[meteors enumerateObjectsUsingBlock:^(CCSprite *meteorite, NSUInteger idx, BOOL *stop) {
		if (CGRectIntersectsRect(spaceShip.boundingBox, meteorite.boundingBox)) {
			
			if (collidedMeteorite == meteorite) {
				return ;
			}
			collidedMeteorite = meteorite;
			
			NSString *pointsString = [NSString stringWithFormat:@"-%d",POINTS_METREOR];
			CCLabelTTF *pointDisLbl = [CCLabelTTF labelWithString:pointsString fontName:@"Marker Felt" fontSize:12.0];
			//			[pointLbl setContentSize:pointsBG.contentSize];
			pointDisLbl.horizontalAlignment = kCCTextAlignmentRight;
			CGPoint point = spaceShip.position;
			point.y += 10;
			pointDisLbl.position = point;
			[self addChild:pointDisLbl];
			
			[pointDisLbl runAction:[CCSequence actions:
															[CCFadeOut actionWithDuration:1.0], [RemoveNode action], nil]];
			
			currentScore -= POINTS_METREOR;
			[pointLbl setString:[NSString stringWithFormat:@"%d",currentScore]];
			
			numberOfChances ++;
			
			if (numberOfChances > NOOFCHANCES) {
				[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SplashScreen sceneWithLevel:LevelLost]]];
			}
			
			*stop = YES;
		}
	}];

	
	NSMutableArray *bulletsToDelete = [[NSMutableArray alloc] init];
	
	[bullets enumerateObjectsUsingBlock:^(CCSprite *bullet, NSUInteger idx, BOOL *stop) {
		
		NSMutableArray *meteoritesToDelete = [[NSMutableArray alloc] init];
		[meteors enumerateObjectsUsingBlock:^(CCSprite *meteorite, NSUInteger idx, BOOL *stop) {
			if (CGRectIntersectsRect(bullet.boundingBox, meteorite.boundingBox)) {
				[meteoritesToDelete addObject:meteorite];
				ddaCounter++;
			}
		}];
		
		
		[meteoritesToDelete enumerateObjectsUsingBlock:^(CCSprite *meteorite, NSUInteger idx, BOOL *stop) {
			[self destroyObject:meteorite];
		}];

		if (meteoritesToDelete.count > 0) {
			[bulletsToDelete addObject:bullet];
		}
		[meteoritesToDelete release];
	}];
	
	for (CCSprite *bullet in bulletsToDelete) {
		[bullets removeObject:bullet];
		[self removeChild:bullet cleanup:YES];
	}
	[bulletsToDelete release];
}


@end
