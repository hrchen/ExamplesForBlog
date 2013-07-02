//
//  PTInputSourceThread.m
//  NSThreadExample
//
//  Created by Haoran Chen on 6/19/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTInputSourceThread.h"
#import "PTInputSource.h"

@interface PTInputSourceThread()

@property (nonatomic, readwrite, retain) RunLoopSource *source;

@end
@implementation PTInputSourceThread

- (void)main
{
    @autoreleasepool
    {
        NSLog(@"starting thread.......");
        
        NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
        _source = [[RunLoopSource alloc] init];
        [_source addToCurrentRunLoop];
        
        while (! self.isCancelled)
        {
            [self doOtherTask];

            BOOL ret = [myRunLoop runMode:NSDefaultRunLoopMode
                                                beforeDate:[NSDate distantFuture]];
            NSLog(@"exiting runloop.........: %d", ret);
        }
        NSLog(@"finishing thread.........");
    }
}

- (void)doOtherTask
{
    NSLog(@"do other task");
}


@end
