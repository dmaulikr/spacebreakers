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
        background.position = CGPointMake(0, windowHeight);
        [self addChild:background z:-10];
                
        [MGWU getHighScoresForLeaderboard:@"endless" withCallback:@selector(receivedScores:) onTarget:self]; 
        
        CCLabelTTF* tapLabel = [CCLabelTTF labelWithString:@"Tap anywhere to return to menu." fontName:@"SquareFont" fontSize:18];
        tapLabel.position = ccp(windowWidth/2,15);
        tapLabel.color = ccWHITE;
        [self addChild:tapLabel];
        
        [self schedule:@selector(checkForClicks:)];
    }
    return self;
}

- (void)receivedScores:(NSDictionary*)scores
{
    if (scores == nil) //Could not load high scores board
    {
        [self displayMissingHighScoresView];
    }
    else
    {
        [self displayHighScoresTable: scores];
    }
}

-(void) displayHighScoresTable: (NSDictionary*) scores
{
    CCLabelTTF* scoreLabel = [CCLabelTTF labelWithString:@"High Scores"
                                    fontName:@"SquareFont"
                                    fontSize:24];
    scoreLabel.position = ccp(windowWidth/2,280);
    scoreLabel.color = ccWHITE;
    [self addChild:scoreLabel];
    
    NSArray* scoreArray = [scores objectForKey: @"all"];
    
    CCLabelTTF* aScore;
    for (int i = 0; i < 10; i++)
    {
        if (i < (int)[scoreArray count])
        {
            NSDictionary *player = [scoreArray objectAtIndex:i];
            NSString *name = [player objectForKey:@"name"];
            NSNumber *s = [player objectForKey:@"score"];
            int score = [s intValue];
            
            //Do something with name and score
            aScore = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"%i.  %@             %i",i+1,name,score] fontName: @"Verdana" fontSize: 18];
            aScore.position = ccp(240,275 - (20*(i+1)));
            aScore.color = ccWHITE;
            [self addChild:aScore];
        }
    }
    
    NSDictionary *user = [scores objectForKey:@"user"];
    NSString *name = [user objectForKey:@"name"];
    NSNumber *s = [user objectForKey:@"score"];
    int score = [s intValue];
    
    NSNumber *r = [user objectForKey:@"rank"];
    int rank = [r intValue];
    
    //Do something with name and score
    aScore = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"# %i.  %@ (you)         %i",rank,name,score] fontName: @"Verdana" fontSize: 18];
    aScore.position = ccp(windowWidth/2,40);
    aScore.color = ccWHITE;
    [self addChild:aScore];

}

-(void) displayMissingHighScoresView
{
    CCLabelTTF* noConnection = [CCLabelTTF labelWithString: @"No internet connection." fontName: @"SquareFont" fontSize: 18];
    noConnection.position = ccp(windowWidth/2,300);
    noConnection.color = ccWHITE;
    [self addChild: noConnection];
    noConnection = [CCLabelTTF labelWithString: @"Cannot display leaderboard." fontName: @"SquareFont" fontSize: 18];
    noConnection.position = ccp(windowWidth/2, 260);
    noConnection.color = ccWHITE;
    [self addChild: noConnection];
    
    NSNumber *currentHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
    int currHigh = [currentHighScore intValue];
    NSString* score = [NSString stringWithFormat:@"Personal High Score: %i",currHigh];
    
    CCLabelTTF* scoreLabel = [CCLabelTTF labelWithString:score
                                    fontName:@"SquareFont"
                                    fontSize:24];
    scoreLabel.position = ccp(windowWidth/2,160);//director.screenCenter;
    scoreLabel.color = ccWHITE;
    [self addChild:scoreLabel];
}

-(void) checkForClicks: (ccTime)dt
{
    
    KKInput* input = [KKInput sharedInput];
    if (input.anyTouchBeganThisFrame)
    {
        {
            [[CCDirector sharedDirector] replaceScene: [MenuLayer scene]];
        }
    }
}

@end