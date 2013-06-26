//
//  PTViewController.m
//  NSURLConnectionExample
//
//  Created by Haoran Chen on 6/25/13.
//  Copyright (c) 2013 KiloApp. All rights reserved.
//

#import "PTViewController.h"
#import "PTURLDownloader.h"

@interface PTViewController ()

@end

@implementation PTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.frame = CGRectMake(100, 100, 100, 30);
    [button addTarget:self action:@selector(toggleButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleButton
{
    NSString *URLString = @"http://farm7.staticflickr.com/6191/6075294191_4c8ca20409.jpg";
       
    //Use PTURLDownloader
    PTURLDownloader *downloader = [PTURLDownloader downloadWithURL:[NSURL URLWithString:URLString]
                                                   timeoutInterval:15
                                                           success:^(id responseData){
                                                               NSLog(@"success block in main thread?: %d", [NSThread isMainThread]);
                                                           }
                                                           failure:^(NSError *error){
                                                               NSLog(@"failure block in main thread?: %d", [NSThread isMainThread]);
                                                           }];
    
    NSLog(@"started downloader: %@", downloader.URL.absoluteString);
}

@end
