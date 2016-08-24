//
//  MessageBuffer.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageBuffer.h"

@interface MessageBuffer ()

@property (atomic, strong) NSMutableArray<MessageData *> *messageBuffer;

@end

@implementation MessageBuffer

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

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self clearMessageBuffer];
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

@end
