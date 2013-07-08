//
//  GameOverLayer.h
//  SpaceBreakers
//
//  Created by Katie Siegel on 6/8/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"


@interface GameOverLayer : CCLayer
{
    int finalPoints;
    NSString* username;
    
    float windowWidth;
    float windowHeight;
    
    NSMutableArray* buttons;
    
    NSMutableArray* playAgainButtonFrames;
    CCAction* playAgainButtonAnimation;
    NSMutableArray* mainMenuButtonFrames;
    CCAction* mainMenuButtonAnimation;
    NSMutableArray* highScoresButtonFrames;
    CCAction* highScoresButtonAnimation;
}

+(id) scene: (int) pts: (int) level;

-(void) promptUserToEnterName;

-(void) checkForClicks: (ccTime)dt;

-(void) configureHighScore;
-(void) updateHighScore;
-(void) loadHighScoreButton;
-(void) loadButtons;
-(void) loadBackground;
-(void) addButtons;

@end
