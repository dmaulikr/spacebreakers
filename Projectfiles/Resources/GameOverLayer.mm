//
//  GameOverLayer.m
//
//  Created by Katie Siegel on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameOverLayer.h"
#import "MenuLayer.h"
#import "LevelSelectLayer.h"
#import "LevelLayer.h"
#import <mgwuSDK/MGWU.h>
#import "HighScoreLayer.h"

#define PAUSEPLAYBUTTON_WIDTH   72.0f
#define PAUSEPLAYBUTTON_HEIGHT  63.0f

@interface GameOverLayer (PrivateMethods)
@end

@implementation GameOverLayer

int score;
int oldLevel;

+(id) scene: (int) pts: (int) level
{
    score = pts;
    oldLevel = level;
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [GameOverLayer node];
    [scene addChild:layer];
    return scene;
}

-(id) init
{
    if ((self = [super init]))
    {
        CGSize screenBound = [[UIScreen mainScreen] bounds].size;
        windowWidth = screenBound.width;
        windowHeight = screenBound.height;
        //background
        CCSprite *background;
        if (windowHeight > 500) {
            background = [CCSprite spriteWithFile:@"gameover_screen-iphone5.png"];
        }
        else {
            background = [CCSprite spriteWithFile:@"background_gameover.png"];
        }

        background.anchorPoint = ccp(0,1);
        background.position = CGPointMake(0, windowWidth);
        [self addChild:background z:-10];
        
        buttons = [NSMutableArray array];
        
        //Load the plist
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"playagainbutton.plist"];
        //Load in the spritesheet
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"playagainbutton.png"];
        [self addChild:spriteSheet];
        playAgainButtonFrames = [NSMutableArray array];
        for(int i = 1; i <= 4; ++i)
        {
            [playAgainButtonFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"play_again_%d.png", i]]];
        }
        //Initialize with the first frame loaded from the spritesheet
        CCSprite *button = [CCSprite spriteWithSpriteFrameName:@"play_again_1.png"];
        button.anchorPoint = ccp(.5,.5);
        button.position = CGPointMake(windowHeight/2, 180.0f);
        //Create an animation from the set of frames you created earlier
        CCAnimation *flashingButton = [CCAnimation animationWithSpriteFrames: playAgainButtonFrames delay:0.2f];
        flashingButton.restoreOriginalFrame = NO;
        //Create an action with the animation that can then be assigned to a sprite
        playAgainButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton]];
        [button runAction:playAgainButtonAnimation];
        [self addChild:button z:0];
        [buttons addObject:button];
        
        //Load the plist
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"main_menu_button.plist"];
        //Load in the spritesheet
        CCSpriteBatchNode *spriteSheet2 = [CCSpriteBatchNode batchNodeWithFile:@"main_menu_button.png"];
        [self addChild:spriteSheet2];
        mainMenuButtonFrames = [NSMutableArray array];
        for(int i = 1; i <= 4; ++i)
        {
            [mainMenuButtonFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"butt_frame_%d.png", i]]];
        }
        //Initialize with the first frame loaded from the spritesheet
        CCSprite* button2 = [CCSprite spriteWithSpriteFrameName:@"butt_frame_1.png"];
        button2.anchorPoint = ccp(.5,.5);
        button2.position = CGPointMake(windowHeight/2, 145.0f);
        //Create an animation from the set of frames you created earlier
        CCAnimation* flashingButton2 = [CCAnimation animationWithSpriteFrames: mainMenuButtonFrames delay:0.2f];
        flashingButton2.restoreOriginalFrame = NO;
        //Create an action with the animation that can then be assigned to a sprite
        mainMenuButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton2]];
        [button2 runAction:mainMenuButtonAnimation];
        [self addChild:button2 z:0];
        [buttons addObject: button2];
        
        if (oldLevel == 100) {
            //Load the plist
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"mainmenu_highscores_button.plist"];
            //Load in the spritesheet
            CCSpriteBatchNode *spriteSheet3 = [CCSpriteBatchNode batchNodeWithFile:@"mainmenu_highscores_button.png"];
            [self addChild:spriteSheet3];
            highScoresButtonFrames = [NSMutableArray array];
            for(int i = 1; i <= 4; ++i)
            {
                [highScoresButtonFrames addObject:
                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"butt_frame_%d.png", i]]];
            }
            //Initialize with the first frame loaded from the spritesheet
            CCSprite* button3 = [CCSprite spriteWithSpriteFrameName:@"butt_frame_1.png"];
            button3.anchorPoint = ccp(.5,.5);
            button3.position = CGPointMake(windowHeight/2, 110.0f);
            //Create an animation from the set of frames you created earlier
            CCAnimation* flashingButton3 = [CCAnimation animationWithSpriteFrames: highScoresButtonFrames delay:0.2f];
            flashingButton3.restoreOriginalFrame = NO;
            //Create an action with the animation that can then be assigned to a sprite
            highScoresButtonAnimation = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:flashingButton3]];
            [button3 runAction:highScoresButtonAnimation];
            [self addChild:button3 z:0];
            [buttons addObject: button3];
            
            //score
            NSString *myScore = [NSString stringWithFormat:@"Final Score: %i",score];
            CCLabelTTF* scoreLabel = [CCLabelTTF labelWithString:myScore
                                                        fontName:@"SquareFont"
                                                        fontSize:24];
            scoreLabel.anchorPoint = ccp(1,1);
            scoreLabel.position = ccp(windowWidth - 25.0f,windowHeight - 25.0f);
            scoreLabel.color = ccWHITE;
            [self addChild:scoreLabel z:-1];
            
            //high score
            NSNumber *currentHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
            int currHigh = [currentHighScore intValue];
            if(score > currHigh)
            {
                NSNumber *myScore = [NSNumber numberWithInteger:score];
                [[NSUserDefaults standardUserDefaults] setObject:myScore forKey:@"highScore"];
                
                scoreLabel = [CCLabelTTF labelWithString:@"New high score!"
                                                fontName:@"SquareFont"
                                                fontSize:18];
                scoreLabel.anchorPoint = ccp(1,1);
                scoreLabel.position = ccp(windowWidth - 25.0f,windowHeight-60.0f);
                scoreLabel.color = ccWHITE;
                [self addChild:scoreLabel z:-1];
                
                NSString * name = [[NSUserDefaults standardUserDefaults] objectForKey:@"playerName"];
                if(name != nil)
                {
                    
                    [MGWU submitHighScore:score byPlayer:name forLeaderboard:@"endless"];

                }
                else
                {
                    [self promptUserToEnterName];
                }
            }
            else
            {
                scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Personal Best: %i",currHigh] fontName:@"SquareFont" fontSize:18];
                scoreLabel.anchorPoint = ccp(1,1);
                scoreLabel.position = ccp(windowWidth - 25.0f,windowHeight-60.0f);
                scoreLabel.color = ccWHITE;
                [self addChild:scoreLabel z:-1];
            }

        }
        
        [self schedule:@selector(checkForClicks:)];
    }
    return self;
}

-(void) promptUserToEnterName
{
    UIAlertView *nameAlert = [[UIAlertView alloc] initWithTitle:@"Enter Name" message:@"\n\n" delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    
    UIImageView *nameImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"passwordfield" ofType:@"png"]]];
    nameImage.frame = CGRectMake(11,79,262,31);
    [nameAlert addSubview:nameImage];
    
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,45,252,25)];
    passwordField.font = [UIFont systemFontOfSize:18];
    passwordField.backgroundColor = [UIColor whiteColor];
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.delegate = (id) self;
    [passwordField becomeFirstResponder];
    [nameAlert addSubview:passwordField];
    
    [nameAlert show];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    username = textField.text;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 1) {
        [MGWU submitHighScore:score byPlayer:username forLeaderboard:@"endless"];
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"playerName"];
    }
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
                    [[CCDirector sharedDirector] replaceScene: [LevelLayer scene:oldLevel]];
                }
                else if (i==1)
                {
                    [[CCDirector sharedDirector] replaceScene: [MenuLayer scene]];
                }
                else if (i==2)
                {
                    [[CCDirector sharedDirector] replaceScene: [HighScoreLayer scene]];
                }
            }
        }
    }
}

@end