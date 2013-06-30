//
//  PTOperationDownloader.h
//  NSURLConnectionExample
//
//  Created by Haoran Chen on 6/30/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completionBlock)();

@interface PTOperationDownloader : NSOperation

@property (nonatomic, readonly, retain) NSURL *URL;
@property(nonatomic, readonly, retain) NSMutableData* responseData;

+ (id)downloadWithURL:(NSURL *)URL
      timeoutInterval:(NSTimeInterval)timeoutInterval
              success:(void (^)(id responseData))success
              failure:(void (^)(NSError *error))failure;

- (void)setCompletionBlockWithSuccess:(void (^)(id responseData))success
                              failure:(void (^)(NSError *error))failure;

@end
