//
//  PTThreadDownloader.m
//  NSURLConnectionExample
//
//  Created by Haoran Chen on 6/26/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTThreadDownloader.h"

@interface PTThreadDownloader ()

@property (nonatomic, readwrite, retain) NSURL *URL;
@property(nonatomic, readwrite, retain) NSMutableData* responseData;
@property(nonatomic, readwrite, retain) NSURLConnection* connection;
@property(nonatomic, readwrite, assign) NSTimeInterval timeoutInterval;
@property(nonatomic, readwrite, copy) completionBlock completionBlock;
@property(nonatomic, readwrite, retain) NSError *error;

@end

@implementation PTThreadDownloader


+ (void) __attribute__((noreturn)) networkEntry:(id)__unused object
{
    do {
        @autoreleasepool
        {
            [[NSRunLoop currentRunLoop] run];
            
            BOOL ret = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            NSLog(@"exit worker thread runloop: %d", ret);
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
}

+ (id)downloadWithURL:(NSURL *)URL
      timeoutInterval:(NSTimeInterval)timeoutInterval
              success:(void (^)(id responseData))success
              failure:(void (^)(NSError *error))failure
{
    NSLog(@"create downloader in main thread?: %d", [NSThread isMainThread]);
    PTThreadDownloader *downloader = [[PTThreadDownloader alloc] init];
    downloader.URL = URL;
    downloader.timeoutInterval = timeoutInterval;
    [downloader setCompletionBlockWithSuccess:success failure:failure];
        
    [downloader performSelector:@selector(start) onThread:[[self class] networkThread] withObject:nil waitUntilDone:NO];
    
    return downloader;
}

- (void)start
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:self.URL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:self.timeoutInterval];
    [request setHTTPMethod: @"GET"];
    
    self.connection =[[NSURLConnection alloc] initWithRequest:request
                                                     delegate:self
                                             startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)cancel
{
    if (self.connection)
    {
        [self.connection cancel];
        self.connection = nil;
    }
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
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.responseData = nil;
    self.error = error;
    self.completionBlock();
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

@end
