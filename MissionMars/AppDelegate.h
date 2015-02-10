//
//  AppDelegate.h
//  MissionMars
//
//  Created by Kamlesh on 04/10/13.
//  Copyright Kamlesh 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import <CoreMotion/CoreMotion.h>

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
	CMMotionManager *motionManager;
}

@property (readonly) CMMotionManager *motionManager;
@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
