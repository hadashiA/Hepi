//
//  HelloWorldLayer.h
//  Hepi
//
//  Created by 久保田 竜自 on 12/10/24.
//  Copyright 久保田 竜自 2012年. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end