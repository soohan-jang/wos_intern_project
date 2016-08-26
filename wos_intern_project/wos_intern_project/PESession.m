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

- (BOOL)sendMessage:(PEMessage *)message {
    return NO;
}

- (void)sendResource:(PEMessage *)message resultBlock:(void (^)(BOOL success))resultHandler {
    return;
}

- (void)disconnectSession {
    return;
}

@end
