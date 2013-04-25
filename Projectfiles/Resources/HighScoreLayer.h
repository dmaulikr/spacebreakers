//
//  HighScoreLayer.h
//  FirstGame
//
//  Created by Katie Siegel on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"


@interface HighScoreLayer : CCLayer
{
    float windowWidth;
    float windowHeight;
}

+(id) scene;

- (void)receivedScores:(NSArray*)scoreArray;

-(void) checkForClicks: (ccTime)dt;


@end
