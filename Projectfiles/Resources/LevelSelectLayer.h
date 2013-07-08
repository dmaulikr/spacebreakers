//
//  LevelSelectLayer.h
//  SpaceBreakers
//
//  Created by Katie Siegel on 6/27/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"


@interface LevelSelectLayer : CCLayer
{
    int currentLevelProgress;
    int numLevelsPerPage;
    
    CCSprite *backButton;
    CCSprite *startButton;
    CCSprite *selectedButton;
    
    int selectedLevel;
    NSMutableArray *buttons;
    
    float windowWidth;
    float windowHeight;
}

+(id) scene: (int) page;

-(void) drawOther;

-(void) checkForClicks: (ccTime)dt;

-(void) drawLabel: (NSString*) label atPosition: (CGPoint) pos;

@end