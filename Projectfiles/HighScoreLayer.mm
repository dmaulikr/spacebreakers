//
//  HighScoreLayer.m
//  FirstGame
//
//  Created by Katie Siegel on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HighScoreLayer.h"
#import "MenuLayer.h"
#import <mgwuSDK/MGWU.h>

@interface HighScoreLayer (PrivateMethods)
@end

@implementation HighScoreLayer

+(id) scene
{
    CCScene *scene = [CCScene node];
    HighScoreLayer *layer = [HighScoreLayer node];
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
            background = [CCSprite spriteWithFile:@"gamescreen_gamespace-iphone5.png"];
        }
        else {
            background = [CCSprite spriteWithFile:@"game_space.png"];
        }

        background.anchorPoint = ccp(0,1);
        background.position = CGPointMake(0, 320);
        [self addChild:background z:-10];
        
        
        [MGWU getHighScoresForLeaderboard:@"endless" withCallback:@selector(receivedScores:) onTarget:self]; 
        
        
        
        CCLabelTTF* tapLabel = [CCLabelTTF labelWithString:@"Tap anywhere to return to menu." fontName:@"Verdana" fontSize:18];
        tapLabel.position = ccp(240,30);
        tapLabel.color = ccWHITE;
        [self addChild:tapLabel];
        
        [self schedule:@selector(checkForClicks:)];
    }
    return self;
}

- (void)receivedScores:(NSArray*)scoreArray
{
	CCLabelTTF* scoreLabel;
    if (scoreArray == nil)
    {
        CCLabelTTF* noConnection = [CCLabelTTF labelWithString: @"No internet connection." fontName: @"Verdana" fontSize: 18];
        noConnection.position = ccp(240,300);
        noConnection.color = ccWHITE;
        [self addChild: noConnection];
        noConnection = [CCLabelTTF labelWithString: @"Cannot display leaderboard." fontName: @"Verdana" fontSize: 18];
        noConnection.position = ccp(240, 260);
        noConnection.color = ccWHITE;
        [self addChild: noConnection];
        
        NSNumber *currentHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
        int currHigh = [currentHighScore intValue];
        NSString* score = [NSString stringWithFormat:@"Personal High Score: %i",currHigh];
        
        scoreLabel = [CCLabelTTF labelWithString:score 
                                                    fontName:@"Verdana" 
                                                    fontSize:24];
        scoreLabel.position = ccp(240,160);//director.screenCenter;
        scoreLabel.color = ccWHITE;
        [self addChild:scoreLabel];
    }
    else
    {
        scoreLabel = [CCLabelTTF labelWithString:@"High Scores" 
                                        fontName:@"Verdana" 
                                        fontSize:24];
        scoreLabel.position = ccp(240,280);
        scoreLabel.color = ccWHITE;
        [self addChild:scoreLabel];
        
        CCSprite* theBoard = [CCSprite spriteWithFile: @"highscores.png"];
        theBoard.position = ccp(240,180);
        [self addChild:theBoard z:-1];
        
        CCLabelTTF* aScore;
        for (int i = 1; i <= 10; i++)
        {
            if (i < (int)[scoreArray count])
            {
                NSDictionary *player = [scoreArray objectAtIndex:i];
                NSString *name = [player objectForKey:@"name"];
                NSNumber *s = [player objectForKey:@"score"];
                int score = [s intValue];
                
                //Do something with name and score
                aScore = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"%i.  %@             %i",i,name,score] fontName: @"Verdana" fontSize: 18];
                aScore.position = ccp(240,275 - (20*i));
                aScore.color = ccWHITE;
                [self addChild:aScore];
            }
        }
    }
    
}

-(void) checkForClicks: (ccTime)dt
{
    
    KKInput* input = [KKInput sharedInput];
    if (input.anyTouchBeganThisFrame)
    {
        //CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        //if(pos.x > x1 && pos.x < x2 && pos.y > y1 && pos.y < y2) 
        {
            [[CCDirector sharedDirector] replaceScene: [MenuLayer scene]];
        }
    }
}

@end