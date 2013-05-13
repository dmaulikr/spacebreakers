//
//  LevelLayer.h
//  FirstGame
//
//  Created by Katie Siegel on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GameOverLayer.h"
#import "Paintball.h"
#import "Enemy.h"

@interface LevelLayer : CCLayer <UIAccelerometerDelegate>
{
	
    
    
    float windowWidth;
    float windowHeight;
    
    b2World* world;
    
    CMMotionManager* theMotion;
    
    CCSprite *platform;
    CCSprite *pauseplay;
    CCSprite *backButton;
    CCSprite *laser;
    Paintball *paintball;
    Enemy *shooter;
    NSMutableArray *paintballs;
    NSMutableArray *shooters;
        
    ccTime totaltime;
    ccTime realTime;
    float second;
    float balltime;
    float spawntime;
    bool paused;
    int numLives;
    CCLabelTTF* liveLabel;
    int points;
    CCLabelTTF* pointLabel;
    CCLabelTTF* enemyLabel;
    bool isMorphedWide;
    bool isMorphedSkinny;
    ccTime turnBack;
    float platformWidth;
    bool laserIsActive;
    CCLabelTTF* instructionsLabel;
    CCLabelTTF* instructionsLabelBegin;
    CCLabelTTF* tapToBeginLabel;
    CCSprite *topBarLevel;
    CCSprite *topBarEnemies;
    
    int paintballCount;
    bool ongoingInstructions;
    
    Boolean introBallLevel;
    NSNumber *maxBallValue;
    NSMutableArray *enemies;
    
    int enemyCount;
    int totalEnemies;
    
    int currHigh;
    CCLabelTTF* scoreLabel;
    
    bool sticky;
    bool stickyBall;
    Paintball* stuckBall;
    CCSprite* honey;
    ccTime turnUnsticky;
    
    int maxPListLevel;
    
    int platformSpeed;
    ccTime normalSpeedTime;
    
    bool hasGun;
    CCSprite* gun;
    int numShot;
    
    CCLabelTTF* youWon;
    bool invincible;
    
    
    NSMutableArray *shipNormalFrames;
    CCAction *shipNormalAnimation;
    int shipFrame;

    CCSprite *topBarHS;
}

+(LevelLayer*) sharedLevelLayer;
+(id) scene: (int) levelLayer;
-(void) changeLevel;
-(void) updateNumLives;
-(void) updatePointsLabel;
-(void) updateNumEnemiesLeft;

-(void) initLevel;
-(float) getSpawnTime;
-(void) removePlatformChildren;

-(void) addEnemy: (NSDictionary*) item;
-(void) makeEnemies;
-(void) makeEnemy;

-(void) removePaintball: (int)index;
-(void) removeShooter: (int) index;

-(void) unmorphPaddle;

-(void) initPaintball: (Enemy*)mySprite;

-(void) movePlatform;

-(bool) isRetina;

@end
