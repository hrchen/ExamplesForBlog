//
//  PTAppDelegate.m
//  NSThreadExample
//
//  Created by Haoran Chen on 6/18/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTAppDelegate.h"
#import "PTRunLoopThread.h"
#import "PTCFRunLoopThread.h"
#import "PTInputSourceThread.h"
#import "PTObserverThread.h"

void mainRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    CFStringRef mode = CFRunLoopCopyCurrentMode(CFRunLoopGetMain());
    NSLog(@"Current main thread run loop mode: %@", (__bridge NSString *)mode);
    
    CFArrayRef modeArray = CFRunLoopCopyAllModes(CFRunLoopGetMain());
    if (CFArrayGetCount(modeArray) > 0)
    {
        for (int i = 0; i < CFArrayGetCount(modeArray); i++)
        {
            CFStringRef mode = CFArrayGetValueAtIndex(modeArray, i);
            NSLog(@"Main thread run loop has mode: %@", (__bridge NSString *)mode);
        }
    }
}

@interface PTAppDelegate()

@property (nonatomic, readwrite, strong) NSMutableArray *sources;

@end

@implementation PTAppDelegate

+(PTAppDelegate *)sharedAppDelegate
{
    static PTAppDelegate *thePTAppDelegate = nil;
    @synchronized(self){
        if (thePTAppDelegate == nil)
        {
            thePTAppDelegate = [[PTAppDelegate alloc] init];
        }
        return thePTAppDelegate;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        self.sources = [NSMutableArray array];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    UITableViewController *viewController = [[UITableViewController alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
   
    //NSThread subclass and run loop example
    [self launchRunLoopThread];
    
    //NSThread with CFRunLoop
    //[self lauchCFRunLoopThread];
    
    //NSThread with input source
    //[self launchInputSourceThread];
    
    //NSThread with observer
    //[self launchObserverThread];
    
    //Add main run loop observer
    [self addMainRunLoopObserver];
    
    return YES;
}

- (void)launchRunLoopThread;
{
    PTRunLoopThread *thread = [[PTRunLoopThread alloc] init];
    [thread start];
    [self performSelector:@selector(doTaskOnSubThread) onThread:thread withObject:nil waitUntilDone:NO];
}

- (void)lauchCFRunLoopThread
{
    PTCFRunLoopThread *thread = [[PTCFRunLoopThread alloc] init];
    [thread start];
    [self performSelector:@selector(doTaskOnSubThread) onThread:thread withObject:nil waitUntilDone:NO];
}

- (void)doTaskOnSubThread
{
    NSLog(@"do task on sub thread");
}

- (void)launchInputSourceThread
{
    PTInputSourceThread *thread = [[PTInputSourceThread alloc] init];
    [thread start];
}

- (void)registerSource:(RunLoopContext*)sourceContext
{
    [self.sources addObject:sourceContext];
    
    //FIXME: trigger source, just for test
    [self fireSource];
}

- (void)removeSource:(RunLoopContext*)sourceContext
{
    id objToRemove = nil;
    
    for (RunLoopContext* context in self.sources)
    {
        if ([context isEqual:sourceContext])
        {
            objToRemove = context;
            break;
        }
    }
    
    if (objToRemove)
        [self.sources removeObject:objToRemove];
}

- (void)fireSource
{
    if (self.sources.count > 0)
    {
        RunLoopContext *context = [self.sources objectAtIndex:0];
        RunLoopSource *source = context.source;
        CFRunLoopRef runLoop = context.runLoop;
        [source fireCommandsOnRunLoop:runLoop];        
    }
}

- (void)launchObserverThread
{
    PTObserverThread *thread = [[PTObserverThread alloc] init];
    [thread start];
}

- (void)addMainRunLoopObserver
{
    CFRunLoopObserverContext  context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopEntry, YES, 0, &mainRunLoopObserver, &context);
    if (observer)
    {
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer,
                             kCFRunLoopCommonModes);
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
