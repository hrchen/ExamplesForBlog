//
//  PTAppDelegate.h
//  NSThreadExample
//
//  Created by Haoran Chen on 6/18/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTInputSource.h"

@interface PTAppDelegate : UIResponder <UIApplicationDelegate, NSMachPortDelegate>

@property (strong, nonatomic) UIWindow *window;

+(PTAppDelegate *)sharedAppDelegate;

- (void)registerSource:(RunLoopContext*)sourceContext;
- (void)removeSource:(RunLoopContext*)sourceContext;

@end
