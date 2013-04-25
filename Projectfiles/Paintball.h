//
//  Paintball.h
//  FirstGame
//
//  Created by Katie Siegel on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
	BallTypeGreen = 0,
	BallTypeRed,
    BallTypeLife,
    BallTypeLaser,
    BallTypeFat,
    BallTypeSkinny,
    BallTypeSticky,
    BallTypeSlow,
    BallTypeGun,
	
	BallType_MAX,
} BallTypes;

@interface Paintball : CCSprite
{
    float angle;
    float velocity;
    int code;
    bool isFalling;
    BallTypes type;
    bool hasHitPaddle;
    
    CCAction *redOrbAnimation;
    NSMutableArray *redOrbFrames;
    CCAnimation *flaming;
}

@property (readwrite, nonatomic) float angle;
@property (readwrite, nonatomic) float velocity;
@property (readwrite, nonatomic) int code;
@property (readwrite, nonatomic) bool isFalling;
@property (readwrite, nonatomic) BallTypes type;
@property (readwrite, nonatomic) bool hasHitPaddle;

+(id) makePaintballOfType: (BallTypes)balltype;

-(void) move;

-(void) bounce: (float) paddleAngle;
-(void) sideBounce;
-(void) topBounce;

@end
