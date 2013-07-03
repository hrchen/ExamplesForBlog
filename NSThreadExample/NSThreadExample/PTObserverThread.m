//
//  PTObserverThread.m
//  NSThreadExample
//
//  Created by Haoran Chen on 6/24/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTObserverThread.h"

void myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
            //This activity occurs once for each call to CFRunLoopRun and CFRunLoopRunInMode
        case kCFRunLoopEntry:
            NSLog(@"run loop entry");
            break;
            //Inside the event processing loop before any timers are processed
        case kCFRunLoopBeforeTimers:
            NSLog(@"run loop before timers");
            break;
            //Inside the event processing loop before any sources are processed
        case kCFRunLoopBeforeSources:
            NSLog(@"run loop before sources");
            break;
            //Inside the event processing loop before the run loop sleeps, waiting for a source or timer to fire.
            //This activity does not occur if CFRunLoopRunInMode is called with a timeout of 0 seconds.
            //It also does not occur in a particular iteration of the event processing loop if a version 0 source fires
        case kCFRunLoopBeforeWaiting:
            NSLog(@"run loop before waiting");
            break;
            //Inside the event processing loop after the run loop wakes up, but before processing the event that woke it up.
            //This activity occurs only if the run loop did in fact go to sleep during the current loop
        case kCFRunLoopAfterWaiting:
            NSLog(@"run loop after waiting");
            break;
            //The exit of the run loop, after exiting the event processing loop.
            //This activity occurs once for each call to CFRunLoopRun and CFRunLoopRunInMode
        case kCFRunLoopExit:
            NSLog(@"run loop exit");
            break;
            /*
             A combination of all the preceding stages
             case kCFRunLoopAllActivities:
             break;
             */
        default:
            break;
    }
}

static int ObserverThreadTaskIndex = 0;

@implementation PTObserverThread

- (void)main
{
    @autoreleasepool {
        NSLog(@"starting thread.......");
        
        // Timer source
        NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(doTimerTask) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

        
        // Create a run loop observer and attach it to the run loop.
        CFRunLoopObserverContext  context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeTimers, YES, 0, &myRunLoopObserver, &context);  
        if (observer)
        {
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer,
                                 kCFRunLoopCommonModes);
        }
        
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
    NSLog(@"do timer task: %d", ObserverThreadTaskIndex);
    ObserverThreadTaskIndex++;
}

- (void)doOtherTask
{
    NSLog(@"do other task");
}

@end
