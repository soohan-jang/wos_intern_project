//
//  SessionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "SessionManager.h"
#import "PEBluetoothSession.h"
#import "MessageInterrupter.h"

@interface SessionManager ()

@end

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

- (void)initializeWithSessionType:(NSInteger)sessionType {
    switch (sessionType) {
        case SessionTypeBluetooth:
            _session = [[PEBluetoothSession alloc] init];
            _messageSender = [[MessageSender alloc] initWithSession:_session];
            _messageReceiver = [[MessageReceiver alloc] initWithSession:_session];
            break;
    }
}

- (void)setMessageBufferEnabled:(BOOL)enabled {
    _messageReceiver.messageBuffer.enabled = enabled;
}

- (void)disconnectSession {
    [_session disconnect];
    
    _session = nil;
    _messageSender = nil;
    _messageReceiver = nil;
    [[MessageInterrupter sharedInstance] clearInterrupter];
}

- (BOOL)isSessionNil {
    if (_session && _messageSender && _messageReceiver) {
        return NO;
    }
    
    return YES;
}

@end
