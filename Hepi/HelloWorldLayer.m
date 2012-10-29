//
//  HelloWorldLayer.m
//  Hepi
//
//  Created by 久保田 竜自 on 12/10/24.
//  Copyright 久保田 竜自 2012年. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer (PrivateMethods)
- (void)throughYuge:(CCNode *)sender;
- (void)throughKotoba;
- (void)disableKotoba;

- (void)candleOn;
- (void)candleOff;

- (void)setupRecorder;
- (void)levelTimerCallback:(NSTimer *)timer;
@end

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+ (CCScene *) scene {
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
	
    // 'layer' is an autorelease object.
    HelloWorldLayer *layer = [HelloWorldLayer node];
	
    // add layer as a child to scene
    [scene addChild: layer];
	
    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
- (id) init {
    // always call "super" init
    // Apple recommends to re-assign "self" with the "super's" return value
    if (self = [super init]) {
        CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frames addSpriteFramesWithFile:@"Hepi.plist"];

        batch_ = [CCSpriteBatchNode batchNodeWithFile:@"Hepi.png"];
        batch_.anchorPoint = ccp(0, 0);
        batch_.position = ccp(0, 0);
        [self addChild:batch_ z:0 tag:TagBatch];

        // bathroom
        CCSprite *bathroom = [CCSprite spriteWithSpriteFrameName:@"bathroom.png"];
        bathroom.anchorPoint = ccp(0, 0);
        bathroom.position = ccp(111, 157);
        [batch_ addChild:bathroom z:0 tag:TagBathRoom];

        // room
        CCSprite *room = [CCSprite spriteWithSpriteFrameName:@"room.png"];
        room.anchorPoint = ccp(0, 0);
        room.position = ccp(0, 0);
        [batch_ addChild:room z:10 tag:TagRoom];

        // door
        CCSprite *door = [CCSprite spriteWithSpriteFrameName:@"door.png"];
        door.anchorPoint = ccp(0, 0);
        door.position = ccp(110, 156);
        [batch_ addChild:door z:20 tag:TagDoor];

        // candlle
        CCSprite *candle = [CCSprite spriteWithSpriteFrameName:@"candle_1.png"];
        candle.anchorPoint = ccp(0.5, 0);
        candle.position = ccp(165, 279);
        [batch_ addChild:candle z:5 tag:TagCandle];

        [self candleOn];

        // yuge
        for (int i = 0; i < 3; ++i) {
            CCSprite *yuge = [CCSprite spriteWithSpriteFrameName:@"yuge_M.png"];
            [batch_ addChild:yuge z:5 tag:TagYuge];
            [self throughYuge:yuge];
        }

        self.isTouchEnabled = YES;
    }
    return self;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                     priority:0
                                              swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
   // CGPoint location = [touch locationInView:touch.view];
   // location = [[CCDirector sharedDirector] convertToGL:location];

   // caughtKid_ = [self.kidTeam movableMemberAtPoint:location];
   // if (caughtKid_) {
   //     caughtKid_.state = KarateKidCaught;
   // }
    CCNode *door = [batch_ getChildByTag:TagDoor];
    if (door.visible) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"door_b_open.mp3"];
        [self candleOn];
        [self throughKotoba];
        lowPassResults_ = 0;
    } else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"door_b_close.mp3"];
        [self disableKotoba];
    }
    door.visible = !door.visible;
    
    return YES;
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - private methods

- (void)throughYuge:(CCSprite *)yuge {
    NSString *size = @"M";
    float r = CCRANDOM_0_1();
    if (r < 0.33) {
        size = @"S";
    } else if (r > 0.66) {
        size = @"L";
    }

    yuge.visible = NO;
    [yuge setDisplayFrame:
              [[CCSpriteFrameCache sharedSpriteFrameCache]
                              spriteFrameByName:
                     [NSString stringWithFormat:@"yuge_%@.png", size]]];

    CCNode *bathroom = [batch_ getChildByTag:TagBathRoom];
    CGRect rect = bathroom.boundingBox;
    yuge.position = ccp(CCRANDOM_0_1() * CGRectGetWidth(rect) + CGRectGetMinX(rect),
                        CGRectGetMidY(rect) + 20.0f);

    // [yuge runAction:
    //           [CCSpawn actions:move,
    //                    [CCSequence actions:[CCDelayTime actionWithDuration:0.5f],
    //                                [CCFadeOut actionWithDuration:0.5f],
    //                                [CCCallFuncN actionWithTarget:self
    //                                                     selector:_cmd],
    //                     nil],
    //                    nil]];
    [yuge runAction:
              [CCSequence actions:
                              [CCDelayTime actionWithDuration:1.5f * CCRANDOM_0_1()],
                          [CCToggleVisibility action],
                          [CCMoveBy actionWithDuration:3.0f
                                              position:ccp(CCRANDOM_0_1() * 20.0f,
                                                           40.0f)],
                          [CCMoveBy actionWithDuration:3.0f * CCRANDOM_0_1() + 0.5f
                                              position:ccp(CCRANDOM_0_1() * -20.0f,
                                                           40.0f)],
                          [CCCallFuncN actionWithTarget:self
                                               selector:_cmd],
                          nil]];
}

- (void)throughKotoba {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint center = ccp(winSize.width / 2, winSize.height / 2);

    NSString *message = @"広奈さんお誕生日おめでとう";
    for (int i = 0; i < message.length; ++i) {
        unsigned char line = floor(i / (message.length - 5)) + 1;
        unsigned char ch = i % (message.length - 5);
        unsigned int offset = 0;
        if (line == 2) {
            offset = 1.5 * 30;
        }

        NSString *spriteFrameName =
            [NSString stringWithFormat:@"%@.png",
                      [message substringWithRange:NSMakeRange(i, 1)]];
        CCSprite *sprite = (CCSprite *)[batch_ getChildByTag:TagKotoba + i];
        if (!sprite) {
            sprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
            // if (line <= 1) {
                sprite.color = ccc3(114, 197, 117);
            // } else {
            //     sprite.color = ccc3(222, 118, 15);
            // }
            [batch_ addChild:sprite z:20 tag:TagKotoba + i];
        } else {
            [sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]
                                        spriteFrameByName:spriteFrameName]];
        }
        sprite.visible = NO;
        sprite.position = center;

        NSMutableArray *actions =
            [NSMutableArray arrayWithObjects:
                                [CCDelayTime actionWithDuration:1.0f * (i + 1)],
                            [CCToggleVisibility action],
                [CCMoveTo actionWithDuration:0.5f
                                    position:ccp(ch * 30 + 50 + offset,
                                                 400 - (line * 25))],
                            nil];
        if (i == message.length - 1) {
            [actions addObject:[CCCallFunc actionWithTarget:self
                                                   selector:@selector(setupRecorder)]];
        }
        [sprite runAction:[CCSequence actionsWithArray:actions]];
    }
}

- (void)disableKotoba {
    CCNode *child;
    CCARRAY_FOREACH([batch_ children], child) {
        if (child.tag >= TagKotoba) {
            [child stopAllActions];
            child.visible = NO;
        }
    }
}

- (void)candleOn {
    CCNode *candle = [batch_ getChildByTag:TagCandle];
    CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    NSArray *candleFrames = [NSArray arrayWithObjects:
                                         [frames spriteFrameByName:@"candle_1.png"],
                                     [frames spriteFrameByName:@"candle_2.png"],
                                     [frames spriteFrameByName:@"candle_3.png"],
                                     [frames spriteFrameByName:@"candle_4.png"],
                                     [frames spriteFrameByName:@"candle_5.png"],
                                     [frames spriteFrameByName:@"candle_6.png"],
                                     nil];
    CCAnimation *candleAnimation = [CCAnimation animationWithSpriteFrames:candleFrames delay:0.3];
    CCAnimate *candleAnimate = [CCAnimate actionWithAnimation:candleAnimation];
    [candle runAction:[CCRepeatForever actionWithAction:candleAnimate]];
}

- (void)candleOff {
    CCNode *candle = [batch_ getChildByTag:TagCandle];
    CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];

    [candle stopAllActions];
    [(CCSprite *)candle setDisplayFrame:[frames spriteFrameByName:@"candle_0.png"]];
}

- (void)setupRecorder {
    if (recorder_) {
        [recorder_ release];
        recorder_ = nil;
    }

    // mic
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings =
        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithFloat: 44100.0],                   AVSampleRateKey,
                           [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                           [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                           [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                      nil];

    NSError *error;

    recorder_ = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (recorder_) {
        [recorder_ prepareToRecord];
        recorder_.meteringEnabled = YES;
        [recorder_ record];
        levelTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                       target:self
                                                     selector:@selector(levelTimerCallback:)
                                                     userInfo: nil
                                                      repeats: YES];
    } else {
        CCLOG(@"%@", error.description);        
    }
    CCLOG(@"setup recorder");
    lowPassResults_ = 0;
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder_ updateMeters];

    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder_ peakPowerForChannel:0]));
    lowPassResults_ = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults_;
    
    CCLOG(@"Average input: %f Peak input: %f Low pass results: %f",
          [recorder_ averagePowerForChannel:0],
          [recorder_ peakPowerForChannel:0],
          lowPassResults_);
    if (lowPassResults_ > 0.95) {
        CCLOG(@"Mic blow detected");
        [self candleOff];
    }
}	

#pragma mark - memory management

- (void)dealloc {
    [recorder_ release];
    [levelTimer_ release];
    [super dealloc];
}
@end
