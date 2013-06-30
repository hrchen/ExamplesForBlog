//
//  PTOperationDownloader.m
//  NSURLConnectionExample
//
//  Created by Haoran Chen on 6/30/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTOperationDownloader.h"

@interface PTOperationDownloader()

@property (nonatomic, readwrite, retain) NSURL *URL;
@property(nonatomic, readwrite, retain) NSMutableData* responseData;
@property(nonatomic, readwrite, retain) NSURLConnection* connection;
@property(nonatomic, readwrite, assign) NSTimeInterval timeoutInterval;
@property(nonatomic, readwrite, copy) completionBlock completionBlock;
@property(nonatomic, readwrite, retain) NSError *error;
@property(atomic, readwrite, assign) BOOL finished;
@property(atomic, readwrite, assign) BOOL executing;
@property(nonatomic, readwrite, strong) NSRecursiveLock *lock;
@end

@implementation PTOperationDownloader

- (id)init
{
    self = [super init];
    if (self) {
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"com.kiloapp.lock";
    }
    return self;
}

+ (void) __attribute__((noreturn)) networkEntry:(id)__unused object
{
    do {
        @autoreleasepool
        {
            [[NSRunLoop currentRunLoop] run];
            NSLog(@"exit worker thread runloop");
        }
    } while (YES);
}

+ (NSThread *)networkThread
{
    static NSThread *_networkThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkEntry:) object:nil];
        [_networkThread start];
    });
    
    return _networkThread;
}


- (void)setCompletionBlockWithSuccess:(void (^)(id responseData))success
                              failure:(void (^)(NSError *error))failure
{
    [self.lock lock];
    __weak typeof(self) weakSelf = self;
    self.completionBlock = ^ {
        if (weakSelf.error) {
            if (failure) {
                failure(weakSelf.error);
                
            }
        } else {
            if (success) {
                success(weakSelf.responseData);
            }
        }
    };
    [self.lock unlock];
}

+ (id)downloadWithURL:(NSURL *)URL
      timeoutInterval:(NSTimeInterval)timeoutInterval
              success:(void (^)(id responseData))success
              failure:(void (^)(NSError *error))failure
{
    NSLog(@"create downloader in main thread?: %d", [NSThread isMainThread]);
    PTOperationDownloader *downloader = [[PTOperationDownloader alloc] init];
    downloader.URL = URL;
    downloader.timeoutInterval = timeoutInterval;
    [downloader setCompletionBlockWithSuccess:success failure:failure];
    
    
    
    return downloader;
}

- (void)start
{
    [self.lock lock];
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        self.finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self performSelector:@selector(operationDidStart) onThread:[[self class] networkThread] withObject:nil waitUntilDone:NO];
    self.executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self.lock unlock];
}

- (void)operationDidStart
{
    [self.lock lock];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:self.URL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:self.timeoutInterval];
    [request setHTTPMethod: @"GET"];
    
    self.connection =[[NSURLConnection alloc] initWithRequest:request
                                                     delegate:self
                                             startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
    [self.lock unlock];
}

- (void)operationDidFinish
{
    [self.lock lock];
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    [self.lock unlock];
}

- (void)cancel
{
    [self.lock lock];
    [super cancel];
    if (self.connection)
    {
        [self.connection cancel];
        self.connection = nil;
    }
    
    [self.lock unlock];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return self.executing;
}

- (BOOL)isFinished {
    return self.finished;
}

#pragma mark - NSURLConnection Delegate
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
    if (![response respondsToSelector:@selector(statusCode)] || [((NSHTTPURLResponse *)response) statusCode] < 400)
    {
        NSUInteger expectedSize = response.expectedContentLength > 0 ? (NSUInteger)response.expectedContentLength : 0;
        self.responseData = [[NSMutableData alloc] initWithCapacity:expectedSize];
    }
    else
    {
        [aConnection cancel];
        
        NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                    code:[((NSHTTPURLResponse *)response) statusCode]
                                                userInfo:nil];
        self.error = error;
        self.connection = nil;
        self.responseData = nil;
        self.completionBlock();
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    NSLog(@"connectionDidFinishLoading in main thread?: %d", [NSThread isMainThread]);
    self.connection = nil;
    self.completionBlock();
    [self operationDidFinish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.responseData = nil;
    self.error = error;
    self.completionBlock();
    [self operationDidFinish];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

@end
