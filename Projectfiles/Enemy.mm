//
//  Enemy.m
//  FirstGame
//
//  Created by Katie Siegel on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define PLATFORM_WIDTH  110.0f
#define UFO_WIDTH   100.0f
#define FRAMES_PER_SECOND   60.0f

#import "Enemy.h"
#import "LevelLayer.h"
#import "SimpleAudioEngine.h"

@interface Enemy (PrivateMethods)
-(id) initWithType: (EnemyTypes) enemytype;
@end


@implementation Enemy

@synthesize width;
@synthesize height;
@synthesize secSpeed;
@synthesize fireFreq;
@synthesize nextFire;
@synthesize destination;
@synthesize type;
@synthesize hitPoints;
@synthesize initHitPoints;
@synthesize velocity;

+(id) makeEnemyOfType:(EnemyTypes)enemyType
{
    id enemy = [[self alloc] initWithType: enemyType];
#ifndef KK_ARC_ENABLED
	[enemy autorelease];
#endif // KK_ARC_ENABLED
	return enemy;
}

-(id) initWithType:(EnemyTypes)enemytype
{
    CGSize screenBound = [[UIScreen mainScreen] bounds].size;
    windowWidth = screenBound.height;
    windowHeight = screenBound.width;
    
    NSString* enemyFileName;

    if (enemytype == EnemyTypeRed)
        enemyFileName = @"medium.png";
    else if (enemytype == EnemyTypeUFO)
        enemyFileName = @"weak.png";
    else if (enemytype == EnemyTypeBlue)
        enemyFileName = @"strong.png";
    else if (enemytype == EnemyTypeBoss)
        enemyFileName = @"boss.png";
    
    if ((self = [super initWithFile:enemyFileName]))
	{
        type = enemytype;
        nextFire = ((float)arc4random_uniform(1500))/1000.0;
        HealthbarComponent *healthbar;
        
        switch (type)
        {
            case EnemyTypeUFO:
                height = 37;
                width = 72;
                secSpeed = 2.5f;
                fireFreq = (((float)arc4random_uniform(1000))/1000.0) + 2.0f;
                hitPoints = 1.0f;
                initHitPoints = 1.0f;
                break;
                
            case EnemyTypeRed:
                height = 46;
                width = 72;
                secSpeed = 2.0f;
                fireFreq = (((float)arc4random_uniform(1000))/1000.0) + 1.5f;
                hitPoints = 2.0f;
                initHitPoints = 2.0f;
                healthbar = [HealthbarComponent makeHealthbar];
                [self addChild:healthbar];
                break;
            
            case EnemyTypeBlue:
                height = 72;
                width = 72;
                secSpeed = 2.0f;
                fireFreq = (((float)arc4random_uniform(1000))/1000.0) + 1.4f;
                hitPoints = 3.0f;
                initHitPoints = 3.0f;
                healthbar = [HealthbarComponent makeHealthbar];
                healthbar.anchorPoint = ccp(.42,.34);
                [self addChild:healthbar];
                break;
                
            case EnemyTypeBoss:
                height = 32;
                width = 108;
                secSpeed = 1.0f;
                fireFreq = 0.5f;
                hitPoints = 25.0f;
                initHitPoints = 25.0f;
                healthbar = [HealthbarComponent makeHealthbar];
                healthbar.anchorPoint = ccp(.44,.4);
                [self addChild:healthbar];
                break;

                
            default:
                [NSException exceptionWithName:@"EnemyType Exception" reason:@"unhandled enemy type" userInfo:nil];
        }
            
        self.visible = YES;
        self.anchorPoint = ccp(.5,1);
        self.position = CGPointMake(windowWidth/2,windowHeight);
        destination = self.position;
	}
	
	return self;
}

-(void) move
{
    if(( ((lessX && self.position.x <= destination.x) || (!lessX && self.position.x >= destination.x)) &&
        ((lessY && self.position.y <= destination.y) || (!lessY && self.position.y >= destination.y)) ) ||
       self.position.x < 0 || self.position.x > windowWidth || self.position.y > windowHeight || self.position.y < 150.0f)
    {
        destination = ccp(arc4random_uniform(windowWidth-UFO_WIDTH)+(UFO_WIDTH/2),arc4random_uniform(windowHeight/2)+windowHeight/2);
        if(destination.x < self.position.x)
        {
            lessX = true;
        }
        else
        {
            lessX = false;
        }
        if(destination.y < self.position.y)
        {
            lessY = true;
        }
        else
        {
            lessY = false;
        }
        velocity = ccp((destination.x-self.position.x)/FRAMES_PER_SECOND/secSpeed, (destination.y-self.position.y)/FRAMES_PER_SECOND/secSpeed);
    }
    self.position = ccpAdd(self.position, velocity);
}

-(void) gotHit
{
	hitPoints = hitPoints - 1.0f;
	if (hitPoints <= 0)
	{
		self.visible = NO;
        // Play a particle effect when the enemy was destroyed
		CCParticleSystem* system;
		if (type == EnemyTypeBoss)
		{
			system = [CCParticleSystemQuad particleWithFile:@"fx-explosion2.plist"];
			[[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav" pitch:1.0f pan:0.0f gain:1.0f];
		}
		else
		{
			system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
			[[SimpleAudioEngine sharedEngine] playEffect:@"shipexplosion.wav" pitch:1.0f pan:0.0f gain:1.0f];
		}
		
		// Set some parameters that can't be set in Particle Designer
		system.positionType = kCCPositionTypeFree;
		system.autoRemoveOnFinish = YES;
		system.position = self.position;
		
		// Add the particle effect to the GameScene, for these reasons:
		// - self is a sprite added to a spritebatch and will only allow CCSprite nodes (it crashes if you try)
		// - self is now invisible which might affect rendering of the particle effect
		// - since the particle effects are short lived, there is no harm done by adding them directly to the GameScene
		[[LevelLayer sharedLevelLayer] addChild:system];
	}
	else
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"hit1.wav" pitch:1.0f pan:0.0f gain:1.0f];
	}
}

@end
