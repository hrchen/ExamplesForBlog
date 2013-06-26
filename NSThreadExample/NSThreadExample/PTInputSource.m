//
//  PTInputSource.m
//  NSThreadExample
//
//  Created by Haoran Chen on 6/18/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTInputSource.h"
#import "PTAppDelegate.h"

@implementation RunLoopSource

- (id)init
{
    CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
        &RunLoopSourceScheduleRoutine,
        RunLoopSourceCancelRoutine,
        RunLoopSourcePerformRoutine};
    
    runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    commands = [[NSMutableArray alloc] init];
    
    return self;
}
- (void)addToCurrentRunLoop
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}
- (void)invalidate
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopRemoveSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}

// Handler method
- (void)sourceFired
{
    NSLog(@"Source fired: do some work, dude!");
}

// Client interface for registering commands to process
- (void)addCommand:(NSInteger)command withData:(id)data
{
    
}

- (void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop
{
    CFRunLoopSourceSignal(runLoopSource);
    CFRunLoopWakeUp(runloop);
}

@end

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    RunLoopSource* obj = (__bridge RunLoopSource*)info;
    PTAppDelegate*   delegate = [PTAppDelegate sharedAppDelegate];
    RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
    
    [delegate performSelectorOnMainThread:@selector(registerSource:) withObject:theContext waitUntilDone:NO];
}

void RunLoopSourcePerformRoutine (void *info)
{
    RunLoopSource*  obj = (__bridge RunLoopSource*)info;
    [obj sourceFired];
}

void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    RunLoopSource* obj = (__bridge RunLoopSource*)info;
    PTAppDelegate* delegate = [PTAppDelegate sharedAppDelegate];
    RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
    
    [delegate performSelectorOnMainThread:@selector(removeSource:) withObject:theContext waitUntilDone:NO];
}


@implementation RunLoopContext

- (id)initWithSource:(RunLoopSource*)src andLoop:(CFRunLoopRef)loop
{
    self = [super init];
    if (self)
    {
        _runLoop = loop;
        _source = src;
    }
    return self;
}

@end
