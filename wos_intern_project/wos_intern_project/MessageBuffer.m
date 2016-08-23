//
//  MessageBuffer.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageBuffer.h"

@interface MessageBuffer () <SessionDataReceiveDelegate>

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) PESession *session;
@property (atomic, strong) NSMutableArray<MessageData *> *messageBuffer;

@end

@implementation MessageBuffer

+ (instancetype)sharedInstance {
    static MessageBuffer *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    
    return instance;
}

- (void)setEnabledMessageBuffer:(BOOL)enabled session:(PESession *)session {
    self.enabled = enabled;
    self.session = session;
    
    if (self.enabled) {
        _session.dataReceiveDelegate = self;
    }
}

- (void)putMessage:(MessageData *)message {
    if (!self.messageBuffer) {
        self.messageBuffer = [[NSMutableArray alloc] init];
    }
    
    [self.messageBuffer addObject:message];
}

- (MessageData *)getMessage {
    if ([self isMessageBufferEmpty]) {
        return nil;
    }
    
    MessageData *message = self.messageBuffer[0];
    [self.messageBuffer removeObjectAtIndex:0];
     
     return message;
}

- (void)clearMessageBuffer {
    if ([self isMessageBufferEmpty]) {
        return;
    }
    
    [self.messageBuffer removeAllObjects];
}

- (BOOL)isMessageBufferEnabled {
    return self.enabled;
}

- (BOOL)isMessageBufferEmpty {
    if (!self.messageBuffer || self.messageBuffer.count == 0) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Session Data Received Delegate

- (void)didReceiveData:(MessageData *)message {
    if (![self isMessageBufferEnabled]) {
        return;
    }
    
    [self putMessage:message];
}

@end
