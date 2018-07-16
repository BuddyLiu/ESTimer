//
//  ESTimer.h
//  DaddyLoan
//
//  Created by Paul on 2018/6/7.
//  Copyright © 2018 QingHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^StartTimerBlock)(CGFloat seconds);
typedef void(^StopTimerBlock)(void);

typedef enum : NSUInteger {
    ESTimerTypeDefault, //默认的NSTimer创建计时器
    ESTimerTypeCAD,     //CADisplayLink创建计时器
    ESTimerTypeGCD,     //GCD创建计时器
} ESTimerType;

@interface ESTimer : NSObject

+(ESTimer *)shareInstance;

-(void)startTimerWithTimerType:(ESTimerType)timerType startTimerBlock:(StartTimerBlock)startTimerBlock;
-(void)startTimerWithTimerType:(ESTimerType)timerType timeInterval:(CGFloat)timeInterval startTimerBlock:(StartTimerBlock)startTimerBlock;

-(void)stopTimerWithTimerType:(ESTimerType)timerType stopTimerBlock:(StopTimerBlock)stopTimerBlock;

@end
