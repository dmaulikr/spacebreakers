//
//  Menu.h
//  SpaceBreakers
//
//  Created by Katie Siegel on 6/27/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"


@interface MenuLayer : CCLayer
{
    CCAction *classicButtonAnimation;
    NSMutableArray *classicButtonFrames;
    CCAction *endlessButtonAnimation;
    NSMutableArray *endlessButtonFrames;
    CCAction *aboutButtonAnimation;
    NSMutableArray *aboutButtonFrames;
    CCAction *highScoresButtonAnimation;
    NSMutableArray *highScoresButtonFrames;
    CCAction *moreGamesButtonAnimation;
    NSMutableArray *moreGamesButtonFrames;
    
    NSMutableArray *buttons;
    
    float windowWidth;
    float windowHeight;
}

+(id) scene;

//-(void) drawLabel: (NSString*) label: (CGPoint) pos;

-(void) checkForClicks: (ccTime)dt;
-(void) onEnter;
-(void) cleanupSprites;

-(void) loadMoreGamesButton;
-(void) loadHighScoresButton;
-(void) loadAboutButton;
-(void) loadEndlessModeButton;
-(void) loadClassicModeButton;
-(void) loadBackground;

@end
