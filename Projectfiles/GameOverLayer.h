//
//  GameOverLayer.h
//
//  Created by Katie Siegel on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"


@interface GameOverLayer : CCLayer
{
    int finalPoints;
    NSString* username;
    
    float windowWidth;
    float windowHeight;
}

+(id) scene: (int) pts: (int) level;

-(void) promptUserToEnterName;

-(void) checkForClicks: (ccTime)dt;

@end
