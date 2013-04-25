/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim, Andreas Loew 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com

#import "HealthbarComponent.h"
#import "Enemy.h"

@interface HealthbarComponent (PrivateMethods)
-(id) initHealthbar;
@end

@implementation HealthbarComponent

+(id) makeHealthbar
{
    id healthbar = [[self alloc] initHealthbar];
#ifndef KK_ARC_ENABLED
	[healthbar autorelease];
#endif // KK_ARC_ENABLED
	return healthbar;
}

-(id) initHealthbar
{
	if ((self = [super initWithFile: @"healthbar_small.png"]))
	{
		self.visible = NO;
        self.position = CGPointMake(self.parent.anchorPointInPoints.x, self.parent.anchorPointInPoints.y);
        self.anchorPoint = ccp(.42,.38);
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) update:(ccTime)delta
{
	if (self.parent.visible)
	{
		NSAssert([self.parent isKindOfClass:[Enemy class]], @"not a Enemy");
        self.visible = YES;
		Enemy* parentEntity = (Enemy*)self.parent;
        if(parentEntity.initHitPoints < 25)
        {
            self.scaleX = parentEntity.hitPoints / parentEntity.initHitPoints;
        }
		else
        {
            self.scaleX = parentEntity.hitPoints * 2 / parentEntity.initHitPoints;
        }
	}
	else if (self.visible)
	{
		self.visible = NO;
	}
}

@end
