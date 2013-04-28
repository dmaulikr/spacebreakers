//
//  PauseMenuLayer.m
//  SpaceBounce
//
//  Created by Kathryn Siegel on 1/27/13.
//
//

#import "PauseMenuLayer.h"
#import "LevelLayer.h"
#import "MenuLayer.h"

#define BUTTON_HEIGHT   64.0f
#define BUTTON_WIDTH    160.0f

@interface PauseMenuLayer (PrivateMethods)
@end

@implementation PauseMenuLayer

int myLevel;

+(id) scene: (int)level
{
    myLevel = level;
    CCScene *scene = [CCScene node];
    PauseMenuLayer *layer = [PauseMenuLayer node];
    [scene addChild:layer];
    return scene;
}

-(id) init
{
    if ((self = [super init]))
    {
        CGSize screenBound = [[UIScreen mainScreen] bounds].size;
        windowWidth = screenBound.height;
        windowHeight = screenBound.width;
        
        //background
        CCSprite *background;
        if (windowWidth > 500) {
            background = [CCSprite spriteWithFile:@"pause_ip5.png"];
        }
        else {
            background = [CCSprite spriteWithFile:@"background_pause.png"];
        }

        background.anchorPoint = ccp(.5,.5);
        background.position = CGPointMake(windowWidth/2, windowHeight/2);
        [self addChild:background z:-10];
        
        
        buttons = [NSMutableArray array];
        
        //Load the plist
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"continue_button.plist"];
        //Load in the spritesheet
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"continue_button.png"];
        [self addChild:spriteSheet];
        continueButtonFrames = [NSMutableArray array];
        for(int i = 1; i <= 4; ++i)
        {
            [continueButtonFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"butt_frame_%d.png", i]]];
        }
        //Initialize with the first frame loaded from the spritesheet
        CCSprite *button = [CCSprite spriteWithSpriteFrameName:@"butt_frame_1.png"];
        button.anchorPoint = ccp(.5,.5);
        button.position = CGPointMake(windowWidth/2, 180.0f);
        //Create an animation from the set of frames you created earlier
        CCAnimation *flashingButton = [CCAnimation animationWithSpriteFrames: continueButtonFrames delay:0.2f];
        flashingButton.restoreOriginalFrame = NO;
        //Create an action with the animation that can then be assigned to a sprite
        continueButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton]];
        [button runAction:continueButtonAnimation];
        [self addChild:button z:0];
        [buttons addObject:button];
        
        //Load the plist
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"restart_button.plist"];
        //Load in the spritesheet
        CCSpriteBatchNode *spriteSheet2 = [CCSpriteBatchNode batchNodeWithFile:@"restart_button.png"];
        [self addChild:spriteSheet2];
        restartButtonFrames = [NSMutableArray array];
        for(int i = 1; i <= 4; ++i)
        {
            [restartButtonFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"butt_frame_%d.png", i]]];
        }
        //Initialize with the first frame loaded from the spritesheet
        CCSprite* button2 = [CCSprite spriteWithSpriteFrameName:@"butt_frame_1.png"];
        button2.anchorPoint = ccp(.5,.5);
        button2.position = CGPointMake(windowWidth/2, 145.0f);
        //Create an animation from the set of frames you created earlier
        CCAnimation* flashingButton2 = [CCAnimation animationWithSpriteFrames: restartButtonFrames delay:0.2f];
        flashingButton2.restoreOriginalFrame = NO;
        //Create an action with the animation that can then be assigned to a sprite
        restartButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton2]];
        [button2 runAction:restartButtonAnimation];
        [self addChild:button2 z:0];
        [buttons addObject: button2];
        //Load the plist
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"main_menu_button.plist"];
        //Load in the spritesheet
        CCSpriteBatchNode *spriteSheet3 = [CCSpriteBatchNode batchNodeWithFile:@"main_menu_button.png"];
        [self addChild:spriteSheet3];
        mainMenuButtonFrames = [NSMutableArray array];
        for(int i = 1; i <= 4; ++i)
        {
            [mainMenuButtonFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"butt_frame_%d.png", i]]];
        }
        //Initialize with the first frame loaded from the spritesheet
        CCSprite* button3 = [CCSprite spriteWithSpriteFrameName:@"butt_frame_1.png"];
        button3.anchorPoint = ccp(.5,.5);
        button3.position = CGPointMake(windowWidth/2, 110.0f);
        //Create an animation from the set of frames you created earlier
        CCAnimation* flashingButton3 = [CCAnimation animationWithSpriteFrames: mainMenuButtonFrames delay:0.2f];
        flashingButton3.restoreOriginalFrame = NO;
        //Create an action with the animation that can then be assigned to a sprite
        mainMenuButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton3]];
        [button3 runAction:mainMenuButtonAnimation];
        [self addChild:button3 z:0];
        [buttons addObject: button3];

        
                
        [self schedule:@selector(checkForClicks:)];
        
    }
    return self;
}

-(void) onExit
{
    [ super onExit ];
    [ CCSpriteFrameCache purgeSharedSpriteFrameCache ];
    continueButtonAnimation = nil;
    continueButtonFrames = nil;
    restartButtonAnimation = nil;
    restartButtonFrames = nil;
    mainMenuButtonAnimation = nil;
    mainMenuButtonFrames = nil;

    buttons = nil;
}

-(void) checkForClicks: (ccTime)dt
{
    
    KKInput* input = [KKInput sharedInput];
    if (input.anyTouchBeganThisFrame)
    {
        CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        for(int i=0; i<[buttons count]; i++)
        {
            if (CGRectContainsPoint([[buttons objectAtIndex:i] boundingBox], pos))
            {
                if (i==0)
                {
                    [[CCDirector sharedDirector] popScene];
                }
                else if (i==1)
                {
                    [[CCDirector sharedDirector] replaceScene: [LevelLayer scene:myLevel]];
                }
                else if (i==2)
                {
                    [[CCDirector sharedDirector] replaceScene: [MenuLayer scene]];
                }
            }
        }
    }
}


@end