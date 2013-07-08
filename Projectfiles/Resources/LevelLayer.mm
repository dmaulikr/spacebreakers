//
//  LevelLayer.m
//  SpaceBreakers
//
//  Created by Katie Siegel on 6/27/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "LevelLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverLayer.h"
#import "MenuLayer.h"
#import "LevelSelectLayer.h"
#import "PauseMenuLayer.h"
#import <mgwuSDK/MGWU.h>

#define PAUSEPLAYBUTTON_WIDTH   72.0f
#define PAUSEPLAYBUTTON_HEIGHT  63.0f
#define PLATFORM_WIDTH_ORIGINAL 120.0f
#define PLATFORM_HEIGHT 14.0f
#define PLATFORM_SPEED_ORIGINAL 20
#define NUM_LEVELS_PER_STAGE    12
#define FONT_SIZE_LEVEL_INFO   26


@interface LevelLayer (PrivateMethods)
-(void) preloadParticleEffects:(NSString*)particleFile;
@end

@implementation LevelLayer

int level;
int enemieskilled;

static LevelLayer* instanceOfLevelLayer;
+(LevelLayer*) sharedLevelLayer
{
	NSAssert(instanceOfLevelLayer != nil, @"GameLayer instance not yet initialized!");
	return instanceOfLevelLayer;
}

+(id) scene: (int) levelLayer
{
    level = levelLayer;
    
    CCScene *scene = [CCScene node];
    LevelLayer *layer = [LevelLayer node];
    [scene addChild:layer];
    
    //NSLog(@"This is level %i",levelLayer);

    return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CGSize screenBound = [[UIScreen mainScreen] bounds].size;
        windowWidth = screenBound.height;
        windowHeight = screenBound.width;
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        instanceOfLevelLayer = self;
            
		glClearColor(0.1f, 0.0f, 0.2f, 1.0f);
        
        [self initClassVariables];
        [self initPaddleShip];//The platform ship
        [self configureTopBar];
        
        //Detect accelerations
        theMotion = [[CMMotionManager alloc] init];
        [theMotion startAccelerometerUpdates];

		[self preloadSoundEffects];
        
        //Level-specific code
        if(level <= 99)
        {
            [self configureClassicModeLevel];
        }
        else
        {
            [self configureEndlessModeLevel];
        }
        
        [self updateNumLives];//Number of lives left

        //schedules a call to the update method every frame
        [self scheduleUpdate];
	}
    	return self;
}

-(void) initLevel
{
    NSString* fileName = [NSString stringWithFormat:@"Level%i.plist",level];
    NSDictionary *level1 = [NSDictionary dictionaryWithContentsOfFile:fileName];
    NSArray *myEnemies = [level1 objectForKey:@"enemies"];
    enemies = [[NSMutableArray alloc] init];
    for(int i=0; i<(int)[myEnemies count]; i++)
    {  
        [enemies addObject: [myEnemies objectAtIndex:i]];
    }
    introBallLevel = (Boolean)[[level1 objectForKey:@"introBallLevel"] boolValue];
    maxBallValue = [level1 objectForKey:@"maxBallValue"];
}

-(void) initPaddleShip
{
    //Load the plist
    CCSpriteFrameCache* spriteFrameCache = [ CCSpriteFrameCache sharedSpriteFrameCache ];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"ship_normal.plist"];
    //Load in the spritesheet
    CCSpriteBatchNode *shipNormalSheet = [CCSpriteBatchNode batchNodeWithFile:@"ship_normal.png"];
    [self addChild:shipNormalSheet];
    shipNormalFrames = [NSMutableArray array];
    for(int i = 1; i <= 3; ++i)
    {
        CCSpriteFrame* frame = [ spriteFrameCache spriteFrameByName: [ NSString stringWithFormat:@"paddleShip_normal%d.png", i ] ];
        [ shipNormalFrames addObject:frame ];
    }
    //Initialize with the first frame loaded from the spritesheet
    platform = [CCSprite spriteWithSpriteFrameName:@"paddleShip_normal1.png"];
    platform.anchorPoint = ccp(0.5,0);
    platform.position = CGPointMake(windowWidth/2,0);
    //Create an animation from the set of frames you created earlier
    CCAnimation* shipNormal = [CCAnimation animationWithSpriteFrames: shipNormalFrames delay:0.2f];
    shipNormal.restoreOriginalFrame = NO;
    //Create an action with the animation that can then be assigned to a sprite
    shipNormalAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:shipNormal]];
    [platform runAction:shipNormalAnimation];
    [self addChild:platform z:0];
    shipFrame = 1;
}

-(void) initClassVariables
{
    platformWidth = PLATFORM_WIDTH_ORIGINAL;
    paintballs = [[NSMutableArray alloc] init];
    shooters = [[NSMutableArray alloc] init];
    spawntime = [self getSpawnTime];
    paused = false;
    numLives = 3;
    points = 0;
    isMorphedWide = false;
    isMorphedSkinny = false;
    turnBack = 0.0f;
    laserIsActive = false;
    paintballCount = 0;
    enemyCount = 0;
    sticky = false;
    stickyBall = false;
    turnUnsticky = 0.0f;
    platformSpeed = PLATFORM_SPEED_ORIGINAL;
    normalSpeedTime = 0.0f;
    invincible = false;
    maxPListLevel = 40;
    realTime = 0.0f;
}

-(void) createBackground
{
    //background
    CCSprite *background;
    if (windowWidth > 500) {
        background = [CCSprite spriteWithFile:@"gamescreen_gamespace-iphone5.png"];
    }
    else {
        background = [CCSprite spriteWithFile:@"game_space.png"];
    }
    background.anchorPoint = ccp(0,1);
    background.position = CGPointMake(0, windowHeight);
    [self addChild:background z:-10];
}

-(void) configureTopBar
{
    //Top bar alignment
    if (level == 100) {
        topBarHS = [CCSprite spriteWithFile:@"highscoreframe.png"];
        topBarHS.anchorPoint = ccp(1,1);
        topBarHS.position = CGPointMake(windowWidth, windowHeight);
        [self addChild:topBarHS z:-2];
    }
    
    topBarEnemies = [CCSprite spriteWithFile:@"enemyframe_solo.png"];
    topBarEnemies.anchorPoint = ccp(1,1);
    if (level == 100)
    {topBarEnemies.position = CGPointMake(windowWidth, windowHeight-[topBarHS boundingBox].size.height);}
    else
    {topBarEnemies.position = CGPointMake(windowWidth, windowHeight);}
    
    [self addChild:topBarEnemies z:-2];
    
    if (level == 100) {
        topBarLevel = [CCSprite spriteWithFile:@"emptylevel.png"];
    }
    else {
        topBarLevel = [CCSprite spriteWithFile:@"levelframe.png"];
    }
    topBarLevel.anchorPoint = ccp(0,1);
    topBarLevel.position = CGPointMake(0, windowHeight);
    [self addChild:topBarLevel z:-2];
    
    CCSprite *topBarLives = [CCSprite spriteWithFile:@"livesframe_solo.png"];
    topBarLives.anchorPoint = ccp(0,1);
    topBarLives.position = CGPointMake(0, windowHeight-[topBarLevel boundingBox].size.height);
    [self addChild:topBarLives z:-2];
    
    pauseplay = [CCSprite spriteWithFile:@"pause.png"];
    pauseplay.anchorPoint = ccp(0,1);
    pauseplay.position = CGPointMake(0,windowHeight-[topBarLevel boundingBox].size.height-
                                     [topBarLives boundingBox].size.height - 3.0f); //the extra 3 pixels evens the spacing
    [self addChild:pauseplay z:-2];
}

-(void) preloadSoundEffects
{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"explosion1.wav"]; //ship gets hit
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"explo2.wav"]; //boss explodes
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit1.wav"]; //spaceship gets hit
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"plus_life.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"shipexplosion.wav"]; //spaceship explodes
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"paddle_hit.mp3"]; //green ball hits paddle
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"LLS - Obsidian Mirror.mp3" loop:YES];
}

-(void) configureClassicModeLevel
{
    [self initLevel];
    ongoingInstructions = true;
    if(level <= NUM_LEVELS_PER_STAGE*2)
    {
        NSString* instructions;
        switch(level) {
            case 1:
                instructions = [NSString stringWithFormat:@"Tilt to move.\nBounce green balls back at enemies"];
                break;
            case 2:
                instructions = [NSString stringWithFormat:@"Avoid red balls or lose 1 life."];
                break;
            case 3:
                instructions = [NSString stringWithFormat:@"Health ball increases life count."];
                break;
            case 4:
                instructions = [NSString stringWithFormat:@"Some enemies must be hit twice."];
                break;
            case 5:
                instructions = [NSString stringWithFormat:@"Laser ball generates giant laser."];
                break;
            case 6:
                instructions = [NSString stringWithFormat:@"Hamburger ball makes ship wider."];
                break;
            case 7:
                instructions = [NSString stringWithFormat:@"Salad ball makes ship skinnier."];
                break;
            case 8:
                instructions = [NSString stringWithFormat:@"Honey ball makes paddle sticky.\nTap to launch stuck balls."];
                break;
            case 9:
                instructions = [NSString stringWithFormat:@"Turtle ball decreases ship speed."];
                break;
            case 10:
                instructions = [NSString stringWithFormat:@"Watch out for enemies with\nthree hit points!"];
                break;
            case 11:
                instructions = [NSString stringWithFormat:@"Blaster ball generates missile\nlauncher. Tap to shoot. Ammo: 3"];
                break;
            case 12:
                instructions = [NSString stringWithFormat:@"Boss level!"];
                break;
            default:
                instructions = [NSString stringWithFormat:@"Tap anywhere to start level."];
                break;
        }
        instructionsLabelBegin = [CCLabelTTF labelWithString:instructions fontName:@"SquareFont" fontSize:FONT_SIZE_LEVEL_INFO];
        tapToBeginLabel = [CCLabelTTF labelWithString:@"Tap anywhere to start level."
                                             fontName:@"SquareFont" fontSize:22];
        tapToBeginLabel.color = ccRED;
        tapToBeginLabel.position = ccp(windowWidth/2, windowHeight/3);
        [self addChild: tapToBeginLabel z:-1];
    }
    instructionsLabelBegin.color = ccWHITE;
    instructionsLabelBegin.position = ccp(windowWidth/2, windowHeight/2);
    [self addChild:instructionsLabelBegin z:-1];
    totalEnemies = level*2;
    [self updateNumEnemiesLeft];
        NSString *currLevel = [NSString stringWithFormat:@"%i",level];
    CCLabelTTF* levelLabel = [CCLabelTTF labelWithString:currLevel
                                                fontName:@"SquareFont"
                                                fontSize:21];
    levelLabel.anchorPoint = ccp(.5,.5);
    levelLabel.position = ccp([topBarLevel boundingBox].size.width*7/10,windowHeight-[topBarLevel boundingBox].size.height*.6);
    levelLabel.color = ccWHITE;
    [self addChild:levelLabel z:-1];
}

-(void) configureEndlessModeLevel
{
    maxBallValue = [NSNumber numberWithInt:8];
    introBallLevel = NO;
    ongoingInstructions = true;
    instructionsLabelBegin = [CCLabelTTF labelWithString:@"Forgot the rules?\nTip: try classic mode!"
                                                fontName:@"SquareFont" fontSize:FONT_SIZE_LEVEL_INFO];
    instructionsLabelBegin.color = ccWHITE;
    instructionsLabelBegin.position = ccp(windowWidth/2, windowHeight/2);
    enemieskilled = 0;
    
    tapToBeginLabel = [CCLabelTTF labelWithString:@"Tap anywhere to start."
                                         fontName:@"SquareFont" fontSize:22];
    tapToBeginLabel.color = ccRED;
    tapToBeginLabel.position = ccp(windowWidth/2, windowHeight/3);
    [self addChild: tapToBeginLabel z:-1];
    
    [self updateNumEnemiesLeft]; // this will display the # of enemies killed, 0 at start
    [self addChild:instructionsLabelBegin z:-1];
    
    //Number of points
    [self updatePointsLabel];
    
    //High Score
    NSNumber *currentHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
    currHigh = [currentHighScore intValue];
    NSString* score = [NSString stringWithFormat:@"Best: %i",currHigh];
    
    scoreLabel = [CCLabelTTF labelWithString:score
                                    fontName:@"SquareFont"
                                    fontSize:18];
    scoreLabel.anchorPoint = ccp(1,1);
    scoreLabel.position = ccp(windowWidth-10,windowHeight-8);
    scoreLabel.color = ccWHITE;
    [self addChild:scoreLabel z:-1];
}

-(void) preloadParticleEffects:(NSString*)particleFile
{
	[CCParticleSystem particleWithFile:particleFile];
}

-(float) getSpawnTime
{
    float time;
    if(level <= 99)
    {
        time = (((float)arc4random_uniform(1000))/500) + (26.0f - ((float)level));
    }
    else
    {
        time = (float)(50.0f*(0.6f - ((1.0f/(1.0f+ (pow(M_E,(-1.0f*totaltime/60.0f))) )) - 0.5f))) - 4.5f;
    }
    return time;
}

-(void) removePaintball: (int)index
{
    paintball.visible = NO;
    [paintball stopAllActions];
    [paintball unscheduleUpdate];
    [self removeChild:paintball cleanup:YES];
    [paintballs removeObjectAtIndex:index];
}

-(void) removeShooter: (int) index
{
    shooter.visible = NO;
    [shooter stopAllActions];
    [shooter unscheduleUpdate];
    [self removeChild:shooter cleanup:YES];
    [shooters removeObjectAtIndex:index];
    [self updateNumEnemiesLeft];
}

-(void) updateNumLives
{
    if (liveLabel != nil) 
    {
        [self removeChild:liveLabel cleanup:YES];
    }
    NSString *currLives = [NSString stringWithFormat:@"%i",numLives];
    liveLabel = [CCLabelTTF labelWithString:currLives 
                                   fontName:@"SquareFont"
                                   fontSize:18];
    liveLabel.anchorPoint = ccp(.5,.5);
    liveLabel.position = CGPointMake([topBarLevel boundingBox].size.width/2,windowHeight-[topBarLevel boundingBox].size.height*1.6);
    liveLabel.color = ccWHITE;
    [self addChild:liveLabel z:-1];
}

-(void) updatePointsLabel
{
    if (pointLabel != nil) 
    {
        [self removeChild:pointLabel cleanup:YES];
    }
    NSString *currPoints = [NSString stringWithFormat:@"Score: %i",points];
    pointLabel = [CCLabelTTF labelWithString:currPoints 
                                    fontName:@"SquareFont" 
                                    fontSize:18];
    pointLabel.anchorPoint = ccp(0,1);
    pointLabel.position = ccp(0+10,windowHeight-8);
    pointLabel.color = ccWHITE;
    [self addChild:pointLabel z:-1];
    
    if(points > currHigh)
    {
        [self removeChild:scoreLabel cleanup:YES];
        NSString *theNewHighScore = [NSString stringWithFormat:@"BEST: %i",points];
        scoreLabel = [CCLabelTTF labelWithString:theNewHighScore 
                                        fontName:@"SquareFont" 
                                        fontSize:18];
        scoreLabel.anchorPoint = ccp(1,1);
        scoreLabel.position = ccp(windowWidth-10,windowHeight-8);//director.screenCenter;
        scoreLabel.color = ccWHITE;
        [self addChild:scoreLabel z:-1];
    }
}

-(void) updateNumEnemiesLeft
{
    if(level == 100)
    {
        if (enemyLabel != nil)
        {
            [self removeChild:enemyLabel cleanup:YES];
        }
        NSString* numEnemiesLeft = [NSString stringWithFormat:@"%i",enemieskilled];
        enemyLabel = [CCLabelTTF labelWithString:numEnemiesLeft fontName:@"SquareFont" fontSize:18];
        enemyLabel.anchorPoint = ccp(0.5,0.5);
        enemyLabel.position = CGPointMake(windowWidth - [topBarHS boundingBox].size.width/6, windowHeight-[topBarHS boundingBox].size.height*1.6);
        [self addChild:enemyLabel z:-1];
        enemieskilled++;
    }
    else
    {
        if (enemyLabel != nil)
        {
            [self removeChild:enemyLabel cleanup:YES];
        }
        NSString* numEnemiesLeft = [NSString stringWithFormat:@"%i",([enemies count] + [shooters count])];
        enemyLabel = [CCLabelTTF labelWithString:numEnemiesLeft fontName:@"SquareFont" fontSize:18];
        enemyLabel.anchorPoint = ccp(0.5,0.5);
        enemyLabel.position = CGPointMake(windowWidth - [topBarEnemies boundingBox].size.width/5, windowHeight-[topBarEnemies boundingBox].size.height*0.6);
        //enemyLabel.position = CGPointMake(windowWidth - [topBarHS boundingBox].size.width/6, windowHeight - [topBarHS boundingBox].size.height*0.6);
        [self addChild:enemyLabel z:-1];
    }
    
}

-(void) initPaintball: (Enemy*)mySprite
{
    CGPoint pt = mySprite.position;
    //randomly decide whether it is a green ball (0) or a red ball (1) or a first aid ball (2) or a laserball (3) or a fatball (4) or a skinnyball (5)
    
    int green, red, firstAid, laserNum, fat, skinny, stickyNum, slow, gunNum;
    green = 80;
    red = 140;
    firstAid = 142;
    laserNum = 143;
    fat = 146;
    skinny = 149;
    stickyNum = 151;
    slow = 154;
    gunNum = 156;
    
    int key;
    int mbv = [maxBallValue intValue];
    int temp;
    int max;
    if(introBallLevel && paintballCount < 3)
    {
        key = mbv;
    }
    else
    {
        if(mbv == 0) { max = green;}
        else if(mbv == 1) { max = red;}
        else if(mbv == 2) { max = firstAid;}
        else if(mbv == 3) { max = laserNum;}
        else if(mbv == 4) { max = fat;}
        else if(mbv == 5) { max = skinny;}
        else if(mbv == 6) { max = stickyNum;}
        else if(mbv == 7) { max = slow;}
        else if(mbv == 8) { max = gunNum;}
        
        temp = arc4random_uniform(max);
        if(temp < green) { key = 0;}
        else if(temp < red) { key = 1;}
        else if(temp < firstAid) { key = 2;}
        else if(temp < laserNum) { key = 3;}
        else if (temp < fat) { key = 4;}
        else if (temp < skinny) { key = 5;}
        else if (temp < stickyNum) { key = 6;}
        else if (temp < slow) { key = 7;}
        else if (temp < gunNum) { key = 8;}
    }
    
    if ((level%NUM_LEVELS_PER_STAGE!=0 || key !=3))
    {
        Paintball *pball = [Paintball makePaintballOfType:(BallTypes)key];
        pball.anchorPoint = ccp(.5,1);
        pball.position = CGPointMake(pt.x,pt.y-(mySprite.height/2));
        [self addChild:pball z:2];
        [paintballs addObject:pball];
        
        paintballCount++;
    }
}

-(void) unmorphPaddle
{
    platform.scaleX = 1.0f;
    platformWidth = PLATFORM_WIDTH_ORIGINAL;
    isMorphedWide = false;
    isMorphedSkinny = false;
    turnBack = 0.0f;
}

-(void) detectCollisions
{
    //detect collisions with the laser, if active
    if(laserIsActive)
    {
        for(int p = [paintballs count]-1; p >= 0 ; p--)
        {
            NSInteger pp = p;
            paintball = [paintballs objectAtIndex:pp];
            if(paintball.position.x >= platform.position.x - 16.0f && paintball.position.x <= platform.position.x + 16.0f)
            {
                [self removePaintball:pp];
            }
        }
        for(int s = [shooters count]-1; s>=0; s--)
        {
            NSInteger ss = s;
            shooter = [shooters objectAtIndex:ss];
            if(shooter.position.x + (shooter.width/2) >= platform.position.x - 15.0f && shooter.position.x - (shooter.width/2) <= platform.position.x + 15.0f)
            {
                if(level == 100)
                {
                    [self updatePointsLabel];
                    points += shooter.initHitPoints*200;
                }
                shooter.hitPoints = 1;
                [shooter gotHit];
                [self removeShooter:ss];
            }
        }
        if([shooters count] == 0)
        {
            [self removePlatformChildren];
        }
    }
    
    
    for(int m = 0; m < (int)[paintballs count] ; m++)
    {
        NSInteger first = m;
        paintball = [paintballs objectAtIndex:first];
        
        //check if a paintball has collided with a wall
        int px = paintball.position.x;
        int py = paintball.position.y;
        if (px <= 18.0f || px >= windowWidth - 18.0f) //paintball has hit a wall
        {
            [paintball sideBounce];
        }
        else if(py >= windowHeight - 18.0f) //paintball has top wall
        {
            [paintball topBounce];
        }
        
        
        //check if a paintball has collided with the paddle
        if(py <= PLATFORM_HEIGHT+10.0f && py >= PLATFORM_HEIGHT-3.0f+10.0f)
        {
            //check if its x coordinates are within the width of the platform
            if(px < platform.position.x+(platformWidth/2) && px > platform.position.x-(platformWidth/2))
            {
                //if the paintball is green
                if(paintball.code == 0)
                {
                    if(level == 100)
                    {
                        //NOT SURE WHY THIS IS HERE, COMMENTED OUT
                        //points+=10; //points for bouncing the green ball
                        //[self updatePointsLabel];
                    }
                    if(!sticky || stickyBall)
                    {
                        [paintball bounce: ((paintball.position.x-platform.position.x))/(platformWidth/2)]; //normalized value from -1 to 1
                    }
                    else if(!stickyBall)
                    {
                        stuckBall = paintball;
                        stuckBall.velocity = 0.0f;
                        stickyBall = true;
                    }
                }
                //if the paintball is not green, then check for the other possibilities and remove the paintball from the screen
                else
                {
                    [self removePaintball: first];
                    //if the paintball is red
                    if(paintball.code == 1 && !invincible)
                    {
                        [[SimpleAudioEngine sharedEngine] playEffect:@"explosion1.wav" pitch:1.0f pan:0.0f gain:1.0f];
                        if (isMorphedWide || isMorphedSkinny)
                        {
                            [self unmorphPaddle];
                        }
                        if (platformSpeed < PLATFORM_SPEED_ORIGINAL) 
                        {
                            platformSpeed = PLATFORM_SPEED_ORIGINAL;
                            normalSpeedTime = 0.0f;
                        }
                        numLives--;
                        CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"explosion_small.plist"];
                        [[SimpleAudioEngine sharedEngine] playEffect:@"shipexplosion.wav" pitch:1.0f pan:0.0f gain:1.0f];
                        // Set some parameters that can't be set in Particle Designer
                        system.positionType = kCCPositionTypeFree;
                        system.autoRemoveOnFinish = YES;
                        system.position = platform.position;
                        [self addChild:system];
                        if (numLives==0)
                        {
                            [theMotion stopAccelerometerUpdates];
                            
							if (level == 100)
								[MGWU logEvent:@"endlessmodeplayed"];
							else
								[MGWU logEvent:@"levelfailed" withParams:@{@"level":[NSNumber numberWithInt:level]}];
							
                            [[CCDirector sharedDirector] replaceScene: [GameOverLayer scene: points: level]];
                        }
                        else
                        {
                            [self updateNumLives];
                        }
                    }
                    //If the paintball gives you a life
                    else if (paintball.code == 2)
                    {
                        numLives++;
                        [self updateNumLives];
                        [[SimpleAudioEngine sharedEngine] playEffect:@"plus_life.wav" pitch:1.0f pan:0.0f gain:1.0f];
                    }
                    //If the paintball gives the paddle a laser
                    else if (paintball.code == 3 && !laserIsActive)
                    {
                        [self removePlatformChildren];
                       
                        CGPoint pos = platform.position;
                        [self removeChild:platform];
                        platform = [CCSprite spriteWithFile:@"paddleShip_laserfinal.png"];
                        platform.anchorPoint = ccp(0.5,0);
                        platform.position = pos;
                        [self addChild:platform z:0];
                        
                        laser.position = CGPointMake(self.parent.anchorPointInPoints.x, self.parent.anchorPointInPoints.y+10.0f);
                        laserIsActive = true;
                    }
                    //If the paintball makes your paddle larger
                    else if (paintball.code == 4)
                    {
                        platform.scaleX = 3.0f/2.0f;
                        platformWidth = PLATFORM_WIDTH_ORIGINAL * 1.5;
                        isMorphedWide = true;
                        turnBack = totaltime + 15.0f;
                    }
                    //If the paintball makes your paddle smaller
                    else if (paintball.code == 5)
                    {
                        platform.scaleX = 1.0f/2.0f;
                        platformWidth = PLATFORM_WIDTH_ORIGINAL / 2.0;
                        isMorphedSkinny = true;
                        turnBack = totaltime + 15.0f;
                    }
                    else if (paintball.code == 6 && !sticky)
                    {
                        
                        //THE PLATFORM
                        CGPoint pos = platform.position;
                        [self removeChild:platform];
                        //Load the plist
                        CCSpriteFrameCache* spriteFrameCache = [ CCSpriteFrameCache sharedSpriteFrameCache ];
                        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"ship_sticky.plist"];
                        //Load in the spritesheet
                        CCSpriteBatchNode *shipNormalSheet = [CCSpriteBatchNode batchNodeWithFile:@"ship_sticky.png"];
                        [self addChild:shipNormalSheet];
                        shipNormalFrames = [NSMutableArray array];
                        for(int i = 1; i <= 3; ++i)
                        {
                            CCSpriteFrame* frame = [ spriteFrameCache spriteFrameByName: [ NSString stringWithFormat:@"paddleShip_stickyshield%d.png", i ] ];
                            [ shipNormalFrames addObject:frame ];
                        }
                        //Initialize with the first frame loaded from the spritesheet
                        platform = [CCSprite spriteWithSpriteFrameName:@"paddleShip_stickyshield1.png"];
                        platform.anchorPoint = ccp(0.5,0);
                        platform.position = pos;
                        //Create an animation from the set of frames you created earlier
                        CCAnimation* shipNormal = [CCAnimation animationWithSpriteFrames: shipNormalFrames delay:0.2f];
                        shipNormal.restoreOriginalFrame = NO;
                        //Create an action with the animation that can then be assigned to a sprite
                        shipNormalAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:shipNormal]];
                        [platform runAction:shipNormalAnimation];
                        [self addChild:platform z:0];
                        
                        sticky = true;
                        turnUnsticky = totaltime + 15.0f;
                        
                    }
                    else if (paintball.code == 7)
                    {
                        platformSpeed = PLATFORM_SPEED_ORIGINAL/2;
                        normalSpeedTime = totaltime + 15.0f;
                    }
                    else if (paintball.code == 8 && !hasGun)
                    {
                        [self removePlatformChildren];
                        CGPoint pos = platform.position;
                        [self removeChild:platform];
                        platform = [CCSprite spriteWithFile:@"paddleShip_laserfire.png"];
                        platform.anchorPoint = ccp(0.5,0);
                        platform.position = pos;
                        [self addChild:platform z:0];
                        
                        
                        if (level != 11)
                        {
                            CCLabelTTF * tapToShoot = [CCLabelTTF labelWithString:@"Gun Powerup Activated! Tap to Shoot!"
                                               fontName:@"SquareFont" fontSize:22];
                            tapToShoot.color = ccRED;
                            tapToShoot.position = ccp(windowWidth/2, windowHeight/3 + 20.0f);
                            [self addChild: tapToShoot z:3];
                            [tapToShoot runAction:[CCFadeOut actionWithDuration:5.0f]];
                        }
                        
                        hasGun = true;
                        numShot = 0;
                    }
                }
            }
        }
    }
    for(int n = [paintballs count]-1; n >=0 ; n--)
    {
        //check if a paintball has collided with an alien
        for(int j = [shooters count]-1; j >=0 ; j--)
        {
            if((int)[paintballs count] > n)
            {
                NSInteger first = n;
                NSInteger secondOne = j;
                shooter = [shooters objectAtIndex:secondOne];
                paintball = [paintballs objectAtIndex:first];
                CGRect shooterBound = [shooter boundingBox];
                
                
                //check if their y coordinates match
                if(paintball.hasHitPaddle && paintball.position.y < shooter.position.y + shooterBound.size.height/2
                                && paintball.position.y > shooter.position.y-shooterBound.size.height/2)
                {
                    //check if the paintball's x coordinate is within the width of the shooter
                    if(paintball.position.x < (shooter.position.x + (shooterBound.size.width/2)) && paintball.position.x > shooter.position.x - (shooterBound.size.width/2))
                    {
                        [shooter gotHit];
                        
                        [self removePaintball:first];
                        
                        if(shooter.hitPoints == 0)
                        {
                            if(level == 100)
                            {
                                //Increase number of points;
                                points+=shooter.initHitPoints*200;
                                [self updatePointsLabel];
                            }
                            
                            [self removeShooter: secondOne];
                        }
                    }
                }
            }
        } 
    }
    
    if([shooters count] == 0)
    {
        if(level <= 99)
        {
            if ([enemies count] == 0)
            {
                invincible = true;
                
                if (level != 24) {
                    int currentLevelProgress = [[[NSUserDefaults standardUserDefaults] objectForKey:@"levelProgress"] intValue];
                    if(level + 1 > currentLevelProgress)
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:(level + 1)] forKey:@"levelProgress"];
                    }
                    [self scheduleOnce:@selector(changeLevel) delay:0.5];
                }
                else
                {
                    if(youWon == nil)
                    {
                        youWon = [CCLabelTTF labelWithString:@"Congratulations!" 
                                                    fontName:@"SquareFont"
                                                    fontSize:FONT_SIZE_LEVEL_INFO];
                        youWon.position = ccp(windowWidth/2,windowHeight*3/4);
                        youWon.color = ccGREEN;
                        [self addChild:youWon z:20];
                        youWon = [CCLabelTTF labelWithString:@"You have completed all levels." fontName:@"SquareFont" fontSize:20];
                        youWon.position = ccp(windowWidth/2,windowHeight/2);
                        youWon.color = ccGREEN;
                        [self addChild:youWon z:20];
                        youWon = [CCLabelTTF labelWithString:@"Now try endless mode :)." fontName:@"SquareFont" fontSize:20];
                        youWon.position = ccp(windowWidth/2, windowHeight/3);
                        youWon.color = ccGREEN;
                        [self addChild:youWon z:20];
                    }
                }
            }
            else
            {
                NSDictionary *item = [enemies objectAtIndex:0];
                int spawnT = [[item objectForKey:@"spawnTime"] intValue];
                realTime = spawnT;
                //[self addEnemy: item];
            }
        }
        else
        {
            [self makeEnemies];
        }
    }
    else if ([shooters count] == 1 && [enemies count] == 0 && level%NUM_LEVELS_PER_STAGE!=0 && level != 100)
    {
        shooter = [shooters objectAtIndex:0];
        
        if ([[shooter children] count] < 2)
        {
            //Tap to explode mode
            CCLabelTTF* explodeLabel = [CCLabelTTF labelWithString:@"Last alien" fontName:@"SquareFont" fontSize:16];
            explodeLabel.anchorPoint = ccp(0,1);
            [shooter addChild:explodeLabel];
            CCLabelTTF* explodeLabel2 = [CCLabelTTF labelWithString:@"TAP TO EXPLODE!!" fontName:@"SquareFont" fontSize:16];
            explodeLabel2.anchorPoint = ccp(0.2,2.1);
            [explodeLabel2 setColor:ccc3(255,1,1)];
            [shooter addChild:explodeLabel2];
        }
    }
    else if([shooters count] == 1 && level%12 != 0)
    {
        NSDictionary *item = [enemies objectAtIndex:0];
        int spawnT = [[item objectForKey:@"spawnTime"] intValue];
        if (realTime < spawnT - 5)
        {
            realTime = spawnT - 5;
            shooter = [shooters objectAtIndex:0];
            shooter.nextFire = realTime;
        }
        if (level == 100 && totaltime < spawntime - 5)
        {
            spawntime = totaltime + 5.0f;
            shooter = [shooters objectAtIndex:0];
            shooter.nextFire = totaltime + 1.0f;
        }
    }
}

-(void) changeLevel
{
    [MGWU logEvent:@"levelpassed" withParams:@{@"level":[NSNumber numberWithInt:level]}];
    [[CCDirector sharedDirector] replaceScene: [LevelLayer scene: (level+1)]];
}

-(void) removePlatformChildren
{
    if(sticky || laserIsActive || hasGun)
    {
        if (stickyBall)
        {
            stuckBall.velocity = 3.0f;
            [stuckBall bounce:((paintball.position.x-platform.position.x))/(platformWidth/2+60.0f)];
            stickyBall = false;
        }
        //THE PLATFORM
        
        //Load the plist
        CGPoint pos = platform.position;
        [self removeChild:platform];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"ship_normal.plist"];
        //Load in the spritesheet
        CCSpriteBatchNode *shipNormalSheet = [CCSpriteBatchNode batchNodeWithFile:@"ship_normal.png"];
        [self addChild:shipNormalSheet];
        shipNormalFrames = [NSMutableArray array];
        for(int i = 1; i <= 3; ++i)
        {
            [shipNormalFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"paddleShip_normal%d.png", i]]];
        }
        //Initialize with the first frame loaded from the spritesheet
        platform = [CCSprite spriteWithSpriteFrameName:@"paddleShip_normal1.png"];
        platform.anchorPoint = ccp(0.5,0);
        platform.position = pos;
        //Create an animation from the set of frames you created earlier
        CCAnimation* shipNormal = [CCAnimation animationWithSpriteFrames: shipNormalFrames delay:0.2f];
        shipNormal.restoreOriginalFrame = NO;
        //Create an action with the animation that can then be assigned to a sprite
        shipNormalAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:shipNormal]];
        [platform runAction:shipNormalAnimation];
        [self addChild:platform z:0];
        shipFrame = 1;
        
        turnUnsticky = 0.0f;
        sticky = false;
        laserIsActive = false;
        hasGun = false;
    }
}

-(void) addEnemy: (NSDictionary*) item //for level <= 99
{
    EnemyTypes type = (EnemyTypes)[[item objectForKey:@"enemyType"] intValue];
    
    //[shooters makeEnemyOfType: (EnemyTypes) type]
    
    shooter = [Enemy makeEnemyOfType:(EnemyTypes)type];
    shooter.nextFire = realTime + shooter.nextFire;
    [enemies removeObjectAtIndex:0];
    [shooters addObject:shooter];
    [self addChild:shooter z:5];
}

-(void) makeEnemies
{
    int num; //number of enemies to create
    if(totaltime < 20.0f)
    {
        num = 1;
    }
    else if(totaltime < 60.0f)
    {
        num = arc4random_uniform(2) + 1;
    }
    else if(totaltime < 100.0f)
    {
        num = arc4random_uniform(3) + 1;
    }
    else
    {
        num = arc4random_uniform(4) + 1;
    }    
    for(int i=0; i<num; i++)
    {
        [self makeEnemy];
    }
}

-(void) makeEnemy
{
    spawntime += [self getSpawnTime];
    EnemyTypes type = (EnemyTypes)(arc4random_uniform(5)/2);
    
    //[shooters makeEnemyOfType: (EnemyTypes) type];
    
    shooter = [Enemy makeEnemyOfType:(EnemyTypes)type];
    shooter.nextFire = totaltime;
    [shooters addObject:shooter];
    [self addChild:shooter z:5];
    
    enemyCount++;
}

-(void) dealloc
{
	delete world;
    
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

-(void) movePlatform
{
    if (!paused && theMotion.accelerometerActive == YES)
    {
        float ya = theMotion.accelerometerData.acceleration.y;
        CGPoint velocity = CGPointMake(platformSpeed*ya, 0);
        NSLog(@"%g",ya);
        
        // Move the platform according to the acceleration of the device.
        if ((platform.position.x > 0.5*platformWidth || ya > 0) && (platform.position.x < windowWidth-(0.5*platformWidth) || ya < 0))
        {
            CGPoint currPos = platform.position;
            platform.position = ccpAdd(platform.position, velocity);
            //Move the ball with the platform if there is a ball stuck
            if (stickyBall) {
                stuckBall.position = ccpAdd(stuckBall.position, velocity);
            }
        }
    }
}

-(void) update:(ccTime)delta
{
    [self movePlatform];
    
    if (paused) {
        paused = false;
        CGPoint pos = pauseplay.position;
        [self removeChild:pauseplay cleanup:YES];
        pauseplay = [CCSprite spriteWithFile:@"pause.png"];
        pauseplay.anchorPoint = ccp(0,1);
        pauseplay.position = pos;
        [self addChild:pauseplay z:-1];
    }
    
    //See whether play/pause button was pressed or if the instructions should go away
    KKInput* input = [KKInput sharedInput];
    if(input.anyTouchEndedThisFrame)
    {
        CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        if(CGRectContainsPoint([pauseplay boundingBox], pos))
        {
            CGPoint pos = pauseplay.position;
            if(!paused)
            {
                paused = true;
                [self removeChild:pauseplay cleanup:YES];
                pauseplay = [CCSprite spriteWithFile:@"pause_pressed.png"];
                pauseplay.anchorPoint = ccp(0,1);
                pauseplay.position = pos;
                [self addChild:pauseplay z:-1];
                [[CCDirector sharedDirector] pushScene: [PauseMenuLayer scene: level]];
            }
        }
        else if(ongoingInstructions)
        {
            [self removeChild:instructionsLabelBegin cleanup:YES];
            if (tapToBeginLabel != NULL) {
                [self removeChild: tapToBeginLabel cleanup:YES];
            }
            ongoingInstructions = false;
        }
        else if(!paused && stickyBall)
        {
            float diffX = pos.x - stuckBall.position.x;
            float diffY = pos.y - stuckBall.position.y;
            stuckBall.isFalling = false;
            if(diffX > 0)
            {
                stuckBall.angle = 360.0f - tanhf(diffY/diffX)*180.0f/3.14159f;
            }
            else if(diffX < 0)
            {
                stuckBall.angle = 180.0f + tanhf(-1.0f*diffY/diffX)*180.0f/3.14159f;
            }
            else
            {
                stuckBall.angle = 270.0f;
            }
            
            stuckBall.velocity = 3.0f;
            stickyBall = false;
        }
        else if(!paused && hasGun)
        {
            Paintball *pball = [Paintball makePaintballOfType:(BallTypes)0];
            pball.angle = 270.0f;
            pball.anchorPoint = ccp(.5,1);
            pball.position = CGPointMake(platform.position.x, platform.position.y+50.0f);
            pball.isFalling = false;
            pball.hasHitPaddle = true;
            [self addChild:pball z:2];
            [paintballs addObject:pball];
            
            numShot ++;
            if (numShot == 3) {
                [self removePlatformChildren];
            }
        }
        else if(!paused && [shooters count] == 1 && [enemies count] == 0 && level%12!=0 && level != 100)
        {
            //"Tap to kill"
            shooter = [shooters objectAtIndex:0];
            CGRect shooterBound = [shooter boundingBox];
            //increasing bounding box size to make tapping to kill easier
            shooterBound = CGRectMake(shooterBound.origin.x, shooterBound.origin.y, shooterBound.size.width + 40.0f, shooterBound.size.height + 40.0f);
            if (pos.x > shooter.position.x - (shooterBound.size.width/2) && pos.x < shooter.position.x + (shooterBound.size.width/2) &&
                pos.y > shooter.position.y - (shooterBound.size.height/2) && pos.y < shooter.position.y + (shooterBound.size.height/2))
            {
                shooter.hitPoints = 1;
                [shooter gotHit];
                [self removeShooter:0];
                //[self unscheduleUpdate];
                [self scheduleOnce:@selector(changeLevel) delay:0.5];
            }
        }
    }
    
    
    if (!paused && !ongoingInstructions)
    {
        totaltime+=delta;
        realTime+=delta;
        
        //if it is time to make the paddle turn back to normal size
        if(turnBack > 0.0f && totaltime > turnBack && (isMorphedWide || isMorphedSkinny))
        {
            [self unmorphPaddle];
        }
        
        if(turnUnsticky > 0.0f && totaltime > turnUnsticky && sticky)
        {
            [self removePlatformChildren];
        }
        
        if(normalSpeedTime > 0.0f && totaltime > normalSpeedTime)
        {
            platformSpeed = PLATFORM_SPEED_ORIGINAL;
            normalSpeedTime = 0.0f;
        }
        
        
        
        //Begin level-specific code
        
        //Add shooters when appropriate in the levels
        if(level <=99 && [enemies count] > 0)
        {
            NSDictionary *item = [enemies objectAtIndex:0];
            //NSLog(@"Spawn time is %i",[[item  objectForKey:@"spawnTime"] intValue]);
            if(realTime > (float)[[item  objectForKey:@"spawnTime"] intValue])
            {
                //a UFO
                [self addEnemy: item];
            }
            
        }
        
        if(level == 100)
        {
            //Create a new alien; change frequency depending on the level
            if(totaltime > spawntime)
            {
                [self makeEnemies];
            }
        }
        
        //End level-specific code
        
        
        
        
        //Move the shooters.
        for(int i=0; i<(int)[shooters count]; i++)
        {
            NSInteger j = i;
            shooter = [shooters objectAtIndex:j];
            [shooter move];
            
            if (shooter.position.x < -100.0f || shooter.position.x > windowWidth + 100.0f || 
                shooter.position.y < -100.0f || shooter.position.y > windowHeight + 100.0f)
            {
                [self removeShooter:j];
            }
            
            //shoot paintballs
            if( (level == 100 && totaltime > shooter.nextFire) || (level <= 99 && realTime > shooter.nextFire))
            {
                [self initPaintball:shooter];
                shooter.nextFire+= shooter.fireFreq;
                
                //NSLog(@"fired at %p",totaltime);
            }
        }
        
        //Move all of the paintballs.
        for(int m = [paintballs count]-1; m >= 0 ; m--)
        {
            int n = m;
            paintball = [paintballs objectAtIndex:n];
            if(paintball.position.y < -100 || paintball.position.y > windowHeight + 100)
            {
                if(paintball.position.y < -100 && paintball.code == 1) //points for dodging a red ball
                {
                    if(level == 100)
                    {
                        points+=10;
                        [self updatePointsLabel];
                    }
                }
                [self removeChild:paintball cleanup:YES];
                [paintballs removeObjectAtIndex:n];
            }
            [paintball move];
        }
        
        [self detectCollisions];
    }
}

-(bool) isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00);
}

@end
