//
//  PTRunLoopThread.m
//  NSThreadExample
//
//  Created by Haoran Chen on 6/18/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTRunLoopThread.h"

static int RunLoopThreadTaskIndex = 0;
static NSString *CustomRunLoopMode = @"CustomRunLoopMode";

@implementation PTRunLoopThread

- (void)main
{
    @autoreleasepool {
        NSLog(@"starting thread.......");
        
        // Timer source - nomal
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(doTimerTask) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        
        // Timer source - scheduled
        //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doTimerTask) userInfo:nil repeats:YES];
        
        // Perform not run in custom run mode
        [self performSelector:@selector(doPerformTask) withObject:nil afterDelay:1.0];
        
        // Port source
        //[[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSRunLoopCommonModes];
        
        // Add custom mode
        CFRunLoopAddCommonMode(CFRunLoopGetCurrent(), (__bridge CFStringRef)(CustomRunLoopMode));
        
        while (! self.isCancelled)
        {
            [self doOtherTask];
            BOOL ret = [[NSRunLoop currentRunLoop] runMode:CustomRunLoopMode
                                                beforeDate:[NSDate distantFuture]];
            NSLog(@"exiting runloop.........: %d", ret);
        }
        NSLog(@"finishing thread.........");
     }
}

- (void)doTimerTask
{
    NSLog(@"do timer task: %d", RunLoopThreadTaskIndex);
    RunLoopThreadTaskIndex++;
   
    if (RunLoopThreadTaskIndex > 5)
    {
        // Only works for -runMode:beforDate
        CFRunLoopStop(CFRunLoopGetCurrent());
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
