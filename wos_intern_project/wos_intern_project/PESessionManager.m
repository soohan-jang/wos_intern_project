//
//  SessionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PESessionManager.h"

#import "PEBluetoothSession.h"
#import "PEMessageInterrupter.h"

@interface PESessionManager ()

@end

@implementation PESessionManager

+ (instancetype)sharedInstance {
    static PESessionManager *instance = nil;
    
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
            _messageSender = [[PEMessageSender alloc] initWithSession:_session];
            _messageReceiver = [[PEMessageReceiver alloc] initWithSession:_session];
            break;
    }
}

- (void)setMessageBufferEnabled:(BOOL)enabled {
    _messageReceiver.messageBuffer.enabled = enabled;
}

- (void)disconnectSession {
    [_session disconnectSession];
    
    _session = nil;
    _messageSender = nil;
    _messageReceiver = nil;
    [[PEMessageInterrupter sharedInstance] clearInterrupter];
}

- (BOOL)isSessionNil {
    if (_session && _messageSender && _messageReceiver) {
        return NO;
    }
    
    return YES;
}

@end
