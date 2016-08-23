//
//  PESession.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PESession.h"

@implementation PESession

- (id)instanceOfSession {
    return nil;
}

- (NSString *)displayNameOfSession {
    return nil;
}

- (BOOL)sendMessage:(MessageData *)message {
    return NO;
}

- (void)sendResource:(MessageData *)message resultBlock:(void (^)(BOOL success))resultHandler {
    return;
}

- (void)disconnect {
    return;
}

@end
