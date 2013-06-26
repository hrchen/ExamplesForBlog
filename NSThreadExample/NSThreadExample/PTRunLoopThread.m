//
//  PTRunLoopThread.m
//  NSThreadExample
//
//  Created by Haoran Chen on 6/18/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTRunLoopThread.h"

static int RunLoopThreadTaskIndex = 0;

@implementation PTRunLoopThread

- (void)main
{
    @autoreleasepool {
        NSLog(@"starting thread.......");
        
        // Timer source - nomal
        NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(doTimerTask) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        // Timer source - scheduled
        //[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(doTimerTask) userInfo:nil repeats:YES];
        
        // Perform
        [self performSelector:@selector(doPerformTask) withObject:nil afterDelay:1.0];
        
        // Port source
        [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSRunLoopCommonModes];
        
        while (! self.isCancelled)
        {
            [self doOtherTask];
            BOOL ret = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                                beforeDate:[NSDate distantFuture]];
            NSLog(@"exiting runloop.........: %d", ret);
        }
        NSLog(@"finishing thread.........");


    }
}

- (void)doTimerTask
{
    NSLog(@"do timer task");
}

- (void)doOtherTask
{
    NSLog(@"do other task: %d", RunLoopThreadTaskIndex);
    RunLoopThreadTaskIndex++;
}

- (void)doPerformTask
{
    NSLog(@"do perform task");
}

@end
