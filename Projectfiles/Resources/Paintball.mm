//
//  Paintball.m
//  FirstGame
//
//  Created by Katie Siegel on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Paintball.h"
#import "LevelLayer.h"

@interface Paintball (PrivateMethods)
-(id) initWithType: (BallTypes) balltype;
@end


@implementation Paintball

@synthesize angle;
@synthesize velocity;
@synthesize code;
@synthesize isFalling;
@synthesize type;
@synthesize hasHitPaddle;

+(id) makePaintballOfType:(BallTypes)balltype
{
    id paintball = [[self alloc] initWithType: balltype];
#ifndef KK_ARC_ENABLED
	[paintball autorelease];
#endif // KK_ARC_ENABLED
	return paintball;
}

-(id) initWithType:(BallTypes)balltype
{
	type = balltype;
    angle = (float)arc4random_uniform(50)+65;
    velocity = 3.0f;
    isFalling = true;
    NSString* ballFrameName;
    hasHitPaddle = false;
    
	switch (type)
	{
		case BallTypeGreen: //bouncy balls
			ballFrameName = @"green_orb.png";
            code = 0;
			break;
		case BallTypeRed: //dangerous balls
            //			ballFrameName = @"red_orb_frame_1.png";
            //            code = 1;
            //            break;
        {
            
            ballFrameName = @"frame_1.png";
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"red_orb_new.plist"];
            CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"red_orb_new.png"];
            //
            [self.parent addChild:spriteSheet];
            redOrbFrames = [NSMutableArray array];
            //
            for(int i = 1; i <= 4; ++i)
            {
                [redOrbFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"frame_%d.png", i]]];
            }
            //
            
            code = 1;
            break;
        }
        case BallTypeLife: //add one life
            ballFrameName = @"cross_powerup.png";
            code = 2;
            break;
        case BallTypeLaser: //super laser powerup
            ballFrameName = @"laser_powerup.png";
            code = 3;
            break;
        case BallTypeFat: //make paddle wider
            ballFrameName = @"hamburger_powerup.png";
            code = 4;
            break;
        case BallTypeSkinny: //make paddle skinnier
            ballFrameName = @"salad.png";
            code = 5;
            break;
        case BallTypeSticky: //sticky paddle powerup
            ballFrameName = @"honey_powerup.png";
            code = 6;
            break;
        case BallTypeSlow: //slow paddle powerup
            ballFrameName = @"turtle_powerup.png";
            code = 7;
            break;
        case BallTypeGun: //ball gun powerup
            ballFrameName = @"ray_powerup.png";
            code = 8;
            break;
            
		default:
			[NSException exceptionWithName:@"BallType Exception" reason:@"unhandled ball type" userInfo:nil];
	}
    
	if (type != BallTypeRed)
	{
		self = [super initWithFile:ballFrameName];
	}
	else
	{
		self = [super initWithSpriteFrameName:ballFrameName];
		
		flaming = [CCAnimation animationWithSpriteFrames: redOrbFrames delay:0.1f];
		flaming.restoreOriginalFrame = NO;
		
		redOrbAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flaming]];
		[self runAction:redOrbAnimation];
	}
    
	return self;
}

-(void) move
{
    float radians = angle/180.0f*3.14159f;
    self.position = ccp(self.position.x + (velocity*cosf(radians)),self.position.y - (velocity*sinf(radians)));
}

-(void) bounce: (float) paddleAngle
{
    if(isFalling)
    {
        float reboundAngle = 360.0f-angle; //normal rebound angle
        reboundAngle+=((float)paddleAngle)*60; //rebound angle depending on where the ball hit the paddle
        angle = reboundAngle;
        isFalling = false;
        hasHitPaddle = true;
    }
}

-(void) sideBounce
{
    float reboundAngle = (270.0f - angle) + 270.0f;
    angle = reboundAngle;
}

-(void) topBounce
{
    if(!isFalling)
    {
        float reboundAngle = (270.0f - angle) + 90.0f;
        angle = reboundAngle;
        isFalling = true;
    }
}


@end