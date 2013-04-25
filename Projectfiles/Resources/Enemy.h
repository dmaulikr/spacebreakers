//
//  Enemy.h
//  FirstGame
//
//  Created by Alice Chi on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HealthbarComponent.h"


typedef enum
{
	EnemyTypeUFO = 0,
    EnemyTypeRed,
    EnemyTypeBlue,
    EnemyTypeBoss,
	
	EnemyType_MAX,
} EnemyTypes;

@interface Enemy : CCSprite
{
    int width;
    int height;
    float secSpeed;
    float fireFreq;
    float nextFire;
    CGPoint destination;
    EnemyTypes type;
    float hitPoints;
    float initHitPoints;
    CGPoint velocity;
    bool lessX;
    bool lessY;
    
    float windowWidth;
    float windowHeight;
}

@property (readwrite, nonatomic) int width;
@property (readwrite, nonatomic) int height;
@property (readwrite, nonatomic) float secSpeed;
@property (readwrite, nonatomic) float fireFreq;
@property (readwrite, nonatomic) float nextFire;
@property (readwrite, nonatomic) CGPoint destination;
@property (readwrite, nonatomic) EnemyTypes type;
@property (readwrite, nonatomic) float hitPoints;
@property (readwrite, nonatomic) float initHitPoints;
@property (readwrite, nonatomic) CGPoint velocity;

+(id) makeEnemyOfType: (EnemyTypes) enemyType;

-(void) move;

-(void) gotHit;

@end
