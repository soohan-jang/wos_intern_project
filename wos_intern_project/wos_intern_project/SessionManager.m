//
//  SessionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "SessionManager.h"
#import "PEBluetoothSession.h"

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
            break;
    }
}

- (void)setMessageBufferEnabled:(BOOL)enabled {
    self.messageReceiver.messageBuffer.enabled = enabled;
}

- (void)disconnectSession {
    [_session disconnect];
}

@end
