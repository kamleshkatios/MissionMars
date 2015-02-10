//
//  SplashScreen.h
//  MissionMars
//
//  Created by Kamlesh on 05/01/14.
//  Copyright 2014 Kamlesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SplashScreen : CCLayer {
 	Level level;
}

@property (nonatomic) Level level;


+(CCScene *) sceneWithLevel:(Level) level_;

@end
