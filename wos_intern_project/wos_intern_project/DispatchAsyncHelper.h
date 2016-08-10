//
//  DispatchAsyncHelper.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 10..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^dispatch_block_t)(void);

@interface DispatchAsyncHelper : NSObject

+ (void)dispatchAsyncWithBlock:dispatch_block_t;

+ (void)dispatchAsyncWithBlock:dispatch_block_t delay:(float)delay;

@end
