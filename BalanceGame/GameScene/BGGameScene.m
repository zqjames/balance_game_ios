//
//  BGGameScene.m
//  BalanceGame
//
//  Created by Akifumi on 2012/08/23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "BGGameScene.h"
#import "BGGameManager.h"
#import "BGGameCityLayer.h"
#import "BGGameMainLayer.h"
#import "BGGameResultLayer.h"

#import "BGSelectCourseScene.h"
#import "BGSelectFacebookFriendScene.h"
#import "BGTopScene.h"

#import "BGBGMPlayer.h"
#import "BGSEPlayer.h"

@implementation BGGameScene

+ (BGGameScene *)sceneWithTower:(BGGameTower *)tower selectedUser:(BGRFacebookUser *)selectedUser{
    BGGameScene *scene = [self node];
    
    PLAY_BGM(@"Fairwind_loop.mp3");
    
    BGGameManager *manager = [BGGameManager node];
    [scene addChild:manager];
    
    BGGameCityLayer *backgroundLayer = [BGGameCityLayer node];
    [scene addChild:backgroundLayer];
    
    BGGameMainLayer *mainLayer = [BGGameMainLayer layerWithTower:tower];
    [scene addChild:mainLayer];
        
    manager.onShowTouchWarning = ^(BOOL flag){
        [mainLayer getTouchWarningState:flag];
    };
    
    manager.onShowBalloon = ^(NSArray *words, NSArray *frame){
        [mainLayer showBalloonWithWords:words imagesAnimationFrame:frame];
        [mainLayer notShowNextButton];
    };
    
    manager.onNotShowBalloon = ^(){
        [mainLayer notShowBalloon];
        [mainLayer showNextButton];
    };
    
    manager.onSendAcceleration = ^(UIAcceleration *acceleration){
        [mainLayer moveTowerWithAngle:manager.towerAngle acceleration:acceleration parcent:manager.comatibilityParcent];
    };
    
    manager.onNoticeAllClear = ^(){
        [mainLayer allClear:manager.comatibilityParcent];
        [manager postScoreWithSelectedUser:selectedUser];
        
        BGGameResultLayer *resultLayer = [BGGameResultLayer layerWithSuccess:YES score:manager.comatibilityParcent selectedUser:selectedUser towerNumber:tower.number];
        resultLayer.onPressedRestartButton = ^(){
            [[CCDirector sharedDirector] pushScene:[BGTopScene scene]];
        };
        [scene addChild:resultLayer];
    };
    
    manager.onNoticeGameOver = ^(UIAcceleration *acceleration){
        [mainLayer gameOver];
        [manager postScoreWithSelectedUser:selectedUser];
        
        BGGameResultLayer *resultLayer = [BGGameResultLayer layerWithSuccess:NO score:manager.comatibilityParcent selectedUser:selectedUser towerNumber:tower.number];
        resultLayer.onPressedRestartButton = ^(){
            [[CCDirector sharedDirector] pushScene:[BGTopScene scene]];
        };
        [scene addChild:resultLayer];
    };
    
    manager.onNoticeTimer = ^(){
        [mainLayer changeTimegame:manager.remainGameTime];
    };
    
    mainLayer.onOkButtonPressed = ^(){
        [manager pressedBalloonOkButton];
    };
    
    mainLayer.onNextButtonPressed = ^(){
        PLAY_SE(@"yattaa_01.wav");
        [manager unschedule:@selector(timer:)];
        [mainLayer getTouchWarningState:NO];
        ccTime time;
        if (manager.currentQuestionCount < 3) {
            time = 3.0;
        }else {
            time = 5.0;
        }
        [mainLayer clearWithShowTime:time];
        [scene runAction:[CCSequence actions:[CCDelayTime actionWithDuration:time], [CCCallBlock actionWithBlock:^(){
            [manager schedule:@selector(timer:)];
            if (manager.currentQuestionCount == 2) {
                [backgroundLayer night];
            }
            if (manager.currentGameState != GameStateOver) {
                [manager nextQuestion];
            }
        }], nil]];
        
        if (manager.currentQuestionCount == 5) {
            [mainLayer showFireworksForever:YES];
        }else if (manager.currentQuestionCount > 2) {
            [mainLayer showFireworksForever:NO];
        }
    };
    
    mainLayer.isOnLeftArea = ^(){
        return manager.onLeftTouchArea;
    };
    
    mainLayer.isOnRightArea = ^(){
        return manager.onRightTouchArea;
    };
    
    mainLayer.onSetLeftAreaState = ^(BOOL flag){
        [manager setOnLeftTouchArea:flag];
        return manager.onLeftTouchArea;
    };
    
    mainLayer.onSetRightAreaState = ^(BOOL flag){
        [manager setOnRightTouchArea:flag];
        return manager.onRightTouchArea;
    };
    
    mainLayer.onSendAcceleration = ^(UIAcceleration *acceleration){
        [manager getAcceleration:acceleration];
    };
    
    mainLayer.onGetCurrentGameState = ^(){
        return manager.currentGameState;
    };
    
    mainLayer.onPressedRestartButton = ^(){
        STOP_BGM;
        if (selectedUser != nil) {
            [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:[BGSelectFacebookFriendScene scene] withColor:ccc3(0, 0, 0)]];
        }else {
            [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:[BGSelectCourseScene sceneWithSelectedUser:nil] withColor:ccc3(0, 0, 0)]];
        }
    };
    
    return scene;
}

@end
