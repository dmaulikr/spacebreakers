//
//  PauseMenuLayer.h
//  SpaceBreakers
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
        
    float windowWidth;
    float windowHeight;
}

+(id) scene: (int)level;
-(void) onExit;

@end
