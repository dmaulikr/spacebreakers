//
//  PauseMenuLayer.h
//  SpaceBounce
//
//  Created by Kathryn Siegel on 1/27/13.
//
//

#import "cocos2d.h"
#import "Box2D.h"
#import <Foundation/Foundation.h>

@interface PauseMenuLayer : CCLayer
{
    CCAction *continueButtonAnimation;
    NSMutableArray *continueButtonFrames;
    CCAction *restartButtonAnimation;
    NSMutableArray *restartButtonFrames;
    CCAction *mainMenuButtonAnimation;
    NSMutableArray *mainMenuButtonFrames;
    
    NSMutableArray *buttons;
    
    int myLevel;
    
    float windowWidth;
    float windowHeight;
    
}

@property (readwrite, nonatomic) int myLevel;

+(id) scene: (int)level;
-(void) onExit;

@end
