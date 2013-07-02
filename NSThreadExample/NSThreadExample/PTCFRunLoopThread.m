//
//  PTCFRunLoopThread.m
//  NSThreadExample
//
//  Created by Haoran Chen on 7/2/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTCFRunLoopThread.h"

static int CFRunLoopThreadTimerIndex = 0;

@implementation PTCFRunLoopThread


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
                
        while (!self.isCancelled)
        {
            [self doOtherTask];
            
            SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 2, YES);
            if (result == kCFRunLoopRunStopped)
            {
                [self cancel];
            }
            NSLog(@"exit run loop.........: %ld", result);
        }
        NSLog(@"finishing thread.........");
    }
}

- (void)doTimerTask
{
    NSLog(@"do timer task: %d", CFRunLoopThreadTimerIndex);
    CFRunLoopThreadTimerIndex++;
    if (CFRunLoopThreadTimerIndex > 5)
    {
        CFRunLoopStop(CFRunLoopGetCurrent());
        
        //Try call run loop recursively
//        SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 2, YES);
//        if (result == kCFRunLoopRunTimedOut)
//        {
//            [self cancel];
//        }
    }
}

- (void)doOtherTask
{
    NSLog(@"do other task");
}

- (void)doPerformTask
{
    NSLog(@"do perform task");
}


@end
