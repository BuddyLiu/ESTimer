//
//  ESTimer.m
//  DaddyLoan
//
//  Created by Paul on 2018/6/7.
//  Copyright © 2018 QingHu. All rights reserved.
//

#import "ESTimer.h"

@interface ESTimer()

@property (nonatomic, assign) ESTimerType timerType;
@property (nonatomic, assign) CGFloat timeInterval;

@property (nonatomic, strong) NSTimer *defaultTimer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) dispatch_source_t gcdTimer;

@property (nonatomic, strong) StartTimerBlock defaultTimerStartTimerBlock;
@property (nonatomic, strong) StartTimerBlock displayLinkStartTimerBlock;
@property (nonatomic, strong) StartTimerBlock gcdTimerStartTimerBlock;

@property (nonatomic, strong) StopTimerBlock defaultTimerStopTimerBlock;
@property (nonatomic, strong) StopTimerBlock displayLinkStopTimerBlock;
@property (nonatomic, strong) StopTimerBlock gcdTimerStopTimerBlock;

@end

static ESTimer *esTimer;
static CGFloat defaultTimeInterval = 1.0;

static NSUInteger defaultTimerSecond = 0;
static NSUInteger displayLinkSecond = 0;
static NSUInteger gcdTimerSecond = 0;

@implementation ESTimer

+(ESTimer *)shareInstance
{
    if(!esTimer)
    {
        esTimer = [[ESTimer alloc] init];
        esTimer.timeInterval = defaultTimeInterval;
    }
    return esTimer;
}

-(void)startTimerWithTimerType:(ESTimerType)timerType startTimerBlock:(StartTimerBlock)startTimerBlock
{
    [self startTimerWithTimerType:timerType timeInterval:1.0 startTimerBlock:startTimerBlock];
}

-(void)startTimerWithTimerType:(ESTimerType)timerType timeInterval:(CGFloat)timeInterval startTimerBlock:(StartTimerBlock)startTimerBlock
{
    esTimer.timerType = timerType;
    esTimer.timeInterval = timeInterval;
    if(esTimer.timerType == ESTimerTypeDefault)
    {
        defaultTimerSecond = 0;
        esTimer.defaultTimerStartTimerBlock = startTimerBlock;
        esTimer.defaultTimer = [NSTimer scheduledTimerWithTimeInterval:esTimer.timeInterval
                                                                target:esTimer
                                                              selector:@selector(defaultTimerAction)
                                                              userInfo:nil
                                                               repeats:YES];
    }
    else if(esTimer.timerType == ESTimerTypeCAD)
    {
        displayLinkSecond = 0;
        esTimer.displayLinkStartTimerBlock = startTimerBlock;
        esTimer.displayLink = [CADisplayLink displayLinkWithTarget:esTimer
                                                       selector:@selector(handleDisplayLink)];
        // 每隔1帧调用一次
        esTimer.displayLink.frameInterval = esTimer.timeInterval*60;
        [esTimer.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else if(esTimer.timerType == ESTimerTypeGCD)
    {
        gcdTimerSecond = 0;
        esTimer.gcdTimerStartTimerBlock = startTimerBlock;
        esTimer.gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(esTimer.gcdTimer, DISPATCH_TIME_NOW, esTimer.timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(esTimer.gcdTimer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                gcdTimerSecond += 1;
                esTimer.gcdTimerStartTimerBlock(gcdTimerSecond);
            });
        });
        dispatch_resume(esTimer.gcdTimer);
    }
    else
    {
        
    }
}

-(void)stopTimerWithTimerType:(ESTimerType)timerType stopTimerBlock:(StopTimerBlock)stopTimerBlock
{
    esTimer.timerType = timerType;
    if(esTimer.timerType == ESTimerTypeDefault)
    {
        defaultTimerSecond = 0.0;
        esTimer.defaultTimerStopTimerBlock = stopTimerBlock;
        esTimer.defaultTimerStopTimerBlock();
        [esTimer.defaultTimer invalidate];
        esTimer.defaultTimer = nil;
    }
    else if(esTimer.timerType == ESTimerTypeCAD)
    {
        displayLinkSecond = 0.0;
        esTimer.defaultTimerStopTimerBlock = stopTimerBlock;
        esTimer.defaultTimerStopTimerBlock();
        [esTimer.displayLink invalidate];
        esTimer.displayLink = nil;
    }
    else if(esTimer.timerType == ESTimerTypeGCD)
    {
        gcdTimerSecond = 0.0;
        esTimer.defaultTimerStopTimerBlock = stopTimerBlock;
        esTimer.defaultTimerStopTimerBlock();
        // 挂起定时器（dispatch_suspend 之后的 Timer，是不能被释放的！会引起崩溃）
//        dispatch_suspend(esTimer.gcdTimer);
        // 关闭定时器
        dispatch_source_cancel(esTimer.gcdTimer);
    }
    else
    {
        
    }
}

-(void)defaultTimerAction
{
    defaultTimerSecond += 1;
    esTimer.defaultTimerStartTimerBlock(defaultTimerSecond);
}

-(void)handleDisplayLink
{
    displayLinkSecond += 1;
    esTimer.displayLinkStartTimerBlock(displayLinkSecond);
}

@end
