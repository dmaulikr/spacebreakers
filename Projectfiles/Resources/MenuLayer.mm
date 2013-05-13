//
//  Menu.m
//  FirstGame
//
//  Created by Katie Siegel on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuLayer.h"
#import "LevelSelectLayer.h"
#import "LevelLayer.h"
#import "HighScoreLayer.h"
#import <mgwuSDK/MGWU.h>

#define BUTTON_HEIGHT   50.0f
#define BUTTON_WIDTH    160.0f
#define PAUSEPLAYBUTTON_WIDTH   72.0f
#define PAUSEPLAYBUTTON_HEIGHT  63.0f

@interface MenuLayer (PrivateMethods)
@end

@implementation MenuLayer

+(id) scene
{
    CCScene *scene = [CCScene node];
    MenuLayer *layer = [MenuLayer node];
    [scene addChild:layer];
    return scene;
}

-(id) init
{
    if ((self = [super init]))
    {
    
    }
    return self;
}

-(void) cleanupSprites
{
    [ super onExit ];
    [ CCSpriteFrameCache purgeSharedSpriteFrameCache ];
    classicButtonFrames = nil;
    classicButtonAnimation = nil;
    endlessButtonAnimation = nil;
    endlessButtonFrames = nil;
    aboutButtonAnimation = nil;
    aboutButtonFrames = nil;
    highScoresButtonFrames = nil;
    highScoresButtonAnimation = nil;
    moreGamesButtonAnimation = nil;
    moreGamesButtonFrames = nil;
    buttons = nil;
}

-(void) onEnter
{
    [ super onEnter ];
    CGSize screenBound = [[UIScreen mainScreen] bounds].size;
    windowWidth = screenBound.height;
    windowHeight = screenBound.width;
    
    //background
    CCSprite *background;
    if (windowWidth > 500) {
        background = [CCSprite spriteWithFile:@"main_menu_screen-iphone5.png"];
    }
    else {
        background = [CCSprite spriteWithFile:@"mainmenu_background.png"];
    }

    background.anchorPoint = ccp(.5,.5);
    background.position = CGPointMake(windowWidth/2, windowHeight/2);
    [self addChild:background z:-10];
    
    buttons = [NSMutableArray array];
    
    //Load the plist
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"mainmenu_classicmode_button.plist"];
    //Load in the spritesheet
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"mainmenu_classicmode_button.png"];
    [self addChild:spriteSheet];
    classicButtonFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i)
    {
        [classicButtonFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"mainmenu_classicmode_button_%d.png", i]]];
    }
    //Initialize with the first frame loaded from the spritesheet
    CCSprite *button = [CCSprite spriteWithSpriteFrameName:@"mainmenu_classicmode_button_1.png"];
    button.anchorPoint = ccp(.5,.5);
    button.position = CGPointMake(windowWidth/2, 180.0f);
    //Create an animation from the set of frames you created earlier
    CCAnimation *flashingButton = [CCAnimation animationWithSpriteFrames: classicButtonFrames delay:0.2f];
    flashingButton.restoreOriginalFrame = NO;
    //Create an action with the animation that can then be assigned to a sprite
    classicButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton]];
    [button runAction:classicButtonAnimation];
    [self addChild:button z:0];
    [buttons addObject: button];

    //Load the plist
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"mainmenu_endlessmode_button.plist"];
    //Load in the spritesheet
    CCSpriteBatchNode *spriteSheet2 = [CCSpriteBatchNode batchNodeWithFile:@"mainmenu_endlessmode_button.png"];
    [self addChild:spriteSheet2];
    endlessButtonFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i)
    {
        [endlessButtonFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"mainmenu_endlessmode_button_%d.png", i]]];
    }
    //Initialize with the first frame loaded from the spritesheet
    CCSprite* button2 = [CCSprite spriteWithSpriteFrameName:@"mainmenu_endlessmode_button_1.png"];
    button2.anchorPoint = ccp(.5,.5);
    button2.position = CGPointMake(windowWidth/2, 145.0f);
    //Create an animation from the set of frames you created earlier
    CCAnimation* flashingButton2 = [CCAnimation animationWithSpriteFrames: endlessButtonFrames delay:0.2f];
    flashingButton2.restoreOriginalFrame = NO;
    //Create an action with the animation that can then be assigned to a sprite
    endlessButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton2]];
    [button2 runAction:endlessButtonAnimation];
    [self addChild:button2 z:0];
    [buttons addObject: button2];
    
    //Load the plist
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"mainmenu_about_button.plist"];
    //Load in the spritesheet
    CCSpriteBatchNode *spriteSheet3 = [CCSpriteBatchNode batchNodeWithFile:@"mainmenu_about_button.png"];
    [self addChild:spriteSheet3];
    aboutButtonFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i)
    {
        [aboutButtonFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"mainmenu_about_button_%d.png", i]]];
    }
    //Initialize with the first frame loaded from the spritesheet
    CCSprite* button3 = [CCSprite spriteWithSpriteFrameName:@"mainmenu_about_button_1.png"];
    button3.anchorPoint = ccp(.5,.5);
    button3.position = CGPointMake(windowWidth/2, 110.0f);
    //Create an animation from the set of frames you created earlier
    CCAnimation* flashingButton3 = [CCAnimation animationWithSpriteFrames: aboutButtonFrames delay:0.2f];
    flashingButton3.restoreOriginalFrame = NO;
    //Create an action with the animation that can then be assigned to a sprite
    aboutButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton3]];
    [button3 runAction:aboutButtonAnimation];
    [self addChild:button3 z:0];
    [buttons addObject: button3];
    
    //Load the plist
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"mainmenu_highscores_button.plist"];
    //Load in the spritesheet
    CCSpriteBatchNode *spriteSheet4 = [CCSpriteBatchNode batchNodeWithFile:@"mainmenu_highscores_button.png"];
    [self addChild:spriteSheet4];
    highScoresButtonFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i)
    {
        [highScoresButtonFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"mainmenu_highscores_button_%d.png", i]]];
    }
    //Initialize with the first frame loaded from the spritesheet
    CCSprite* button4 = [CCSprite spriteWithSpriteFrameName:@"mainmenu_highscores_button_1.png"];
    button4.anchorPoint = ccp(.5,.5);
    button4.position = CGPointMake(windowWidth/2, 75.0f);
    //Create an animation from the set of frames you created earlier
    CCAnimation* flashingButton4 = [CCAnimation animationWithSpriteFrames: highScoresButtonFrames delay:0.2f];
    //Create an action with the animation that can then be assigned to a sprite
    highScoresButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton4]];
    [button4 runAction:highScoresButtonAnimation];
    [self addChild:button4 z:0];
    [buttons addObject: button4];

    //Load the plist
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"mainmenu_moregames_button.plist"];
    //Load in the spritesheet
    CCSpriteBatchNode *spriteSheet5 = [CCSpriteBatchNode batchNodeWithFile:@"mainmenu_moregames_button.png"];
    [self addChild:spriteSheet5];
    moreGamesButtonFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i)
    {
        [moreGamesButtonFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"mainmenu_moregames_button_%d.png", i]]];
    }
    //Initialize with the first frame loaded from the spritesheet
    CCSprite* button5 = [CCSprite spriteWithSpriteFrameName:@"mainmenu_moregames_button_1.png"];
    button5.anchorPoint = ccp(.5,.5);
    button5.position = CGPointMake(windowWidth/2, 40.0f);
    //Create an animation from the set of frames you created earlier
    CCAnimation* flashingButton5 = [CCAnimation animationWithSpriteFrames: moreGamesButtonFrames delay:0.2f];
    //Create an action with the animation that can then be assigned to a sprite
    moreGamesButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton5]];
    [button5 runAction:moreGamesButtonAnimation];
    [self addChild:button5 z:0];
    [buttons addObject: button5];
    
    [self schedule:@selector(checkForClicks:)];
}

-(void) checkForClicks: (ccTime)dt
{
    
    KKInput* input = [KKInput sharedInput];
    if (input.anyTouchBeganThisFrame)
    {        
        CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        for(int i=0; i<(int)[buttons count]; i++)
        {
            if (CGRectContainsPoint([[buttons objectAtIndex:i] boundingBox], pos))
            {
                if (i==0)
                {
                    for(int i=0; i<(int)[buttons count]; i++) {
                        [self removeChild: [buttons objectAtIndex: i] cleanup: YES];
                    }
					
                    [MGWU logEvent:@"classicmodeplayed"];
                    [self cleanupSprites];
                    [[CCDirector sharedDirector] replaceScene: [LevelSelectLayer scene: 0]];
                }
                else if (i==1)
                {
                    for(int i=0; i<(int)[buttons count]; i++) {
                        [self removeChild: [buttons objectAtIndex: i] cleanup: YES];
                    }
					
                    [MGWU logEvent:@"endlessmodeplayed"];
                    [self cleanupSprites];
                    [[CCDirector sharedDirector] replaceScene: [LevelLayer scene:100]];
                }
                else if (i==2) {
                    [MGWU displayAboutPage];
                }
                else if (i==3)
                {
                    for(int i=0; i<(int)[buttons count]; i++) {
                        [self removeChild: [buttons objectAtIndex: i] cleanup: YES];
                    }
					
                    [self cleanupSprites];
                    [[CCDirector sharedDirector] replaceScene: [HighScoreLayer scene]];
                }
                else if (i==4) {
                    [MGWU displayCrossPromo];
                }
            }
        }
    }
}

@end