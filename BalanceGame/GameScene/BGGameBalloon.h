//
//  BGGameBalloon.h
//  BalanceGame
//
//  Created by Akifumi on 2012/08/27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BGGameBalloon : CCSprite {
    
}
@property (nonatomic, copy) void (^onOkButtonPressed)();
+ (BGGameBalloon *)node;
- (void)showWithWords:(NSArray *)wordLabels imagesAnimationFrame:(NSArray *)frame;
- (void)notShow;
@end
