//
//  DispatchAsyncHelper.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 10..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DispatchAsyncHelper.h"

@implementation DispatchAsyncHelper

+ (void)dispatchAsyncWithBlockOnMainQueue:(void(^)(void))executeBlock {
    if ([NSThread isMainThread]) {
        NSLog(@"Main Thread");
        executeBlock();
    } else {
        NSLog(@"Not Main Thread");
        dispatch_async(dispatch_get_main_queue(), executeBlock);
    }
}

+ (void)dispatchAsyncWithBlockOnMainQueue:(void(^)(void))executeBlock delayTime:(NSTimeInterval)delayTime {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        executeBlock();
    });
}

@end