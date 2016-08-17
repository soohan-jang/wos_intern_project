//
//  DispatchAsyncHelper.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 10..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DispatchAsyncHelper.h"

@implementation DispatchAsyncHelper

+ (void)dispatchAsyncWithBlockOnMainQueue:dispatch_block_t {
    dispatch_async(dispatch_get_main_queue(), dispatch_block_t);
}

+ (void)dispatchAsyncWithBlockOnMainQueue:dispatch_block_t delay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), dispatch_block_t);
}

@end