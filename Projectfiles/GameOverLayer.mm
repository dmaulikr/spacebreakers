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
        if (windowWidth > 500) {
            background = [CCSprite spriteWithFile:@"gamescreen_gamespace-iphone5.png"];
        }
        else {
            background = [CCSprite spriteWithFile:@"game_space.png"];
        }

        background.anchorPoint = ccp(0,1);
        background.position = CGPointMake(0, 320);
        [self addChild:background z:-10];
        
        NSString* gameover = @"Game Over.";
        CCLabelTTF* gameOverLabel = [CCLabelTTF labelWithString:gameover 
                                                       fontName:@"Verdana" 
                                                       fontSize:30];
        gameOverLabel.position = ccp(240,190);
        gameOverLabel.color = ccWHITE;
        [self addChild:gameOverLabel];
        
        CCLabelTTF* startLabel = [CCLabelTTF labelWithString:@"Play Again" fontName:@"Verdana" fontSize:24];
        startLabel.position = ccp(240,133);
        startLabel.color = ccWHITE;
        [self addChild:startLabel];
        
        if(oldLevel == 100)
        {
            //global high scores
            startLabel = [CCLabelTTF labelWithString:@"See Global High Scores" fontName:@"Verdana" fontSize:20];
            startLabel.position = ccp(240,45);
            startLabel.color = ccWHITE;
            [self addChild:startLabel];
            
            //score
            NSString *myScore = [NSString stringWithFormat:@"Final Score: %i",score];
            CCLabelTTF* scoreLabel = [CCLabelTTF labelWithString:myScore 
                                                        fontName:@"Verdana" 
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
                                                fontName:@"Verdana" 
                                                fontSize:18];
                scoreLabel.anchorPoint = ccp(1,1);
                scoreLabel.position = ccp(windowWidth - 25.0f,windowHeight-60.0f);
                scoreLabel.color = ccWHITE;
                [self addChild:scoreLabel z:-1];
                
                [self promptUserToEnterName];
            }
            else
            {
                scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Personal Best: %i",currHigh] fontName:@"Verdana" fontSize:18];
                scoreLabel.anchorPoint = ccp(1,1);
                scoreLabel.position = ccp(windowWidth - 25.0f,windowHeight-60.0f);
                scoreLabel.color = ccWHITE;
                [self addChild:scoreLabel z:-1];
            }
        }
        CCSprite *backButton = [CCSprite spriteWithFile:@"back_button.png"];
        backButton.anchorPoint = ccp(0,1);
        backButton.position = CGPointMake(0, windowHeight);
        [self addChild:backButton z:-1];
        
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
    }
}

-(void) checkForClicks: (ccTime)dt
{
    KKInput* input = [KKInput sharedInput];
    if (input.anyTouchBeganThisFrame)
    {
        CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        if(pos.x > 150 && pos.x < 330 && pos.y > 106 && pos.y < 160) 
        {
            [[CCDirector sharedDirector] replaceScene: [LevelLayer scene:oldLevel]];
        }
        else if(oldLevel == 100 && pos.x > 100 && pos.x < 380 && pos.y > 20 && pos.y < 70)
        {
            [[CCDirector sharedDirector] replaceScene:[HighScoreLayer scene]];
        }
        else if(pos.x < PAUSEPLAYBUTTON_WIDTH && pos.y > windowHeight - (PAUSEPLAYBUTTON_HEIGHT))
        {
            if(oldLevel < 100)
            {
                [[CCDirector sharedDirector] replaceScene: [LevelSelectLayer scene:(oldLevel/21)]];
            }
            else
            {
                [[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
            }
        }
    }
}

@end