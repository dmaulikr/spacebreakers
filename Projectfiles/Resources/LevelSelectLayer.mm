//
//  LevelSelectLayer.m
//  FirstGame
//
//  Created by Katie Siegel on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "LevelLayer.h"
#import "MenuLayer.h"


@interface LevelSelectLayer (PrivateMethods)
@end

@implementation LevelSelectLayer

int myPage;

+(id) scene: (int) page
{
    myPage = page;
    CCScene *scene = [CCScene node];
    LevelSelectLayer *layer = [LevelSelectLayer node];
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
            background = [CCSprite spriteWithFile:@"level_select_background-iphone5.png"];
        }
        else {
            background = [CCSprite spriteWithFile:@"levelselect_background.png"];
        }

        background.anchorPoint = ccp(0,1);
        background.position = CGPointMake(0, windowHeight);
        [self addChild:background z:-10];
        
        selectedLevel = -1;
        numLevelsPerPage = 24;
        buttons = [[NSMutableArray alloc] initWithCapacity:24];
        
        backButton = [CCSprite spriteWithFile:@"butt_back_idle.png"];
        backButton.anchorPoint = ccp(0,0);
        backButton.position = CGPointMake(0,0);
        [self addChild:backButton z:-1];
        
        selectedButton = [CCSprite spriteWithFile: @"tile_pressed.png"];
        selectedButton.anchorPoint = ccp(.5,.5);
        
        int maxLevel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"levelProgress"] intValue];
        if (maxLevel < 2) 
        {
            currentLevelProgress = 1;
        }
        else
        {
            currentLevelProgress = maxLevel;
        }
        
        [self drawOther];
        
        [self schedule:@selector(checkForClicks:)];
    }
    return self;
}

-(void) drawLabel: (NSString*)labelText atPosition: (CGPoint) pos
{
    CCLabelTTF* theLabel = [CCLabelTTF labelWithString:labelText
                                              fontName:@"SquareFont" 
                                              fontSize:26];
    theLabel.position = pos;
    theLabel.position=pos;
    theLabel.color = ccWHITE;
    [self addChild:theLabel z:1];
}

-(void) drawOther
{
    int index = 1;
    int xmod = 30;
    if (windowWidth > 500) {
        xmod = 75;
    }
    
    for(int i=0; i<4; i++)
    {
        for(int j=0; j<6; j++)
        {
            int levelKey = (i*6) + (j+1);
            NSString *label = [NSString stringWithFormat:@"%i",index];
            CGPoint labelLoc = ccp((((j+1)*60)+xmod),(3-i+1)*60);
            
            CCSprite *tile = [CCSprite spriteWithFile:@"tile_idle.png"];
            tile.anchorPoint = ccp(.5,.5);
            tile.position = labelLoc;
            if(levelKey > currentLevelProgress)
            {
                CCSprite * lock = [CCSprite spriteWithFile:@"lock.png"];
                lock.position = labelLoc;
                lock.opacity = 200.0f;
                [self addChild:lock z:2];
            }
            else
            {
                [self drawLabel:label atPosition:labelLoc];
            }
            [self addChild: tile z:0];
            [buttons insertObject:tile atIndex:(levelKey-1)];
            index++;
        }
    }
}

-(void) checkForClicks: (ccTime)dt
{
    KKInput* input = [KKInput sharedInput];
    if (input.anyTouchBeganThisFrame)
    {
        CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        for (int i=0; i<(int)[buttons count]; i++)
        {
            if ([buttons objectAtIndex:i] != nil &&
                CGRectContainsPoint([[buttons objectAtIndex:i] boundingBox], pos) && selectedLevel != i+1 && (i+1) <= currentLevelProgress)
            {
                CCSprite *theButton = [buttons objectAtIndex:i];
                selectedButton.position = theButton.position;
                if(selectedLevel < 1)
                {
                    [self addChild:selectedButton z:1];
                }
                selectedLevel = i+1;
                [[CCDirector sharedDirector] replaceScene:[LevelLayer scene: selectedLevel]];
            }
        }
        
        //check back button
        if (CGRectContainsPoint([backButton boundingBox], pos))
        {
            [[CCDirector sharedDirector] replaceScene:[ MenuLayer scene ] ];
        }
    }
}

@end