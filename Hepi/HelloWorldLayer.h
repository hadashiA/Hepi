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

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

enum {
    TagBathRoom,
    TagRoom,
    TagDoor,
    TagCandle,
    TagBatch,
    TagYuge,
    TagKotoba,
} TagsHelloWorldNode;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate> {
    CCSpriteBatchNode *batch_;

    AVAudioRecorder *recorder_;
    NSTimer *levelTimer_;
    double lowPassResults_;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;
@end
