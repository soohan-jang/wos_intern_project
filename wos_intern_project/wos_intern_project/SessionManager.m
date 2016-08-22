//
//  SessionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

- (instancetype)initWithSession:(BluetoothSession *)session {
    self = [super init];
    
    if (self) {
        _session = session;
    }
    
    return self;
}

- (void)sessionDisconnect {
    [_session disconnect];
}

@end
