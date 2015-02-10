//
//  MainScreen.h
//  MissionMars
//
//  Created by Kamlesh on 13/10/13.
//  Copyright 2013 Kamlesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#include <CoreMotion/CoreMotion.h>


@interface MainScreen : CCLayer {
	Level level;
}

@property (nonatomic) Level level;
//+(CCScene *) scene;
+(CCScene *) sceneWithLevel:(Level) level_;
@end
