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

- (BOOL)isMessageBufferEmpty {
    if (!self.messageBuffer || self.messageBuffer.count == 0) {
        return YES;
    }
    
    return NO;
}

@end
