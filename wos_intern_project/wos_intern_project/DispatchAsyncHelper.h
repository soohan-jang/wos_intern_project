//
//  DispatchAsyncHelper.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 10..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DispatchAsyncHelper : NSObject

+ (void)dispatchAsyncWithBlockOnMainQueue:(void(^)(void))executeBlock;

@end
