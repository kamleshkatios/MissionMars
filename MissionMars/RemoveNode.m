//
//  RemoveNode.m
//  MissionMars
//
//  Created by Kamlesh on 05/01/14.
//  Copyright 2014 Kamlesh. All rights reserved.
//

#import "RemoveNode.h"


@implementation RemoveNode
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[((CCNode *)aTarget) removeFromParentAndCleanup:YES];
}

@end
