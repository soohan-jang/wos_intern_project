//
//  SessionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "SessionManager.h"
#import "PEBluetoothSession.h"

NSString *const SessionServiceType = @"Co-PhotoEditor";

@implementation SessionManager

+ (instancetype)sharedInstance {
    static SessionManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    
    return instance;
}

- (void)setSession:(PESession *)session {
    switch (session.sessionType) {
        case SessionTypeBluetooth:
            _session = (PEBluetoothSession *)session;
            break;
    }
}

- (void)sessionDisconnect {
    [_session disconnect];
}

@end
