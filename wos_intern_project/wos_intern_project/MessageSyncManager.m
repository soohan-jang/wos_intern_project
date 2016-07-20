//
//  MessageSyncManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 20..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageSyncManager.h"

@implementation MessageSyncManager

+ (MessageSyncManager *)sharedInstance {
    static MessageSyncManager *instance = nil;
    
    @synchronized (self) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _messageQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)putMessage:(NSDictionary *)message {
    if (_messageQueue == nil) {
        _messageQueue = [[NSMutableArray alloc] initWithObjects:message, nil];
    }
    else {
        [_messageQueue addObject:message];
    }
}

- (NSDictionary *)getMessage {
    if (_messageQueue.count > 0) {
        NSDictionary *message = [_messageQueue objectAtIndex:0];
        [_messageQueue removeObjectAtIndex:0];
        return message;
    }
    else {
        return nil;
    }
}

- (void)clearMessageQueue {
    if (_messageQueue != nil && _messageQueue.count > 0) {
        [_messageQueue removeAllObjects];
    }
}

- (BOOL)isMessageQueueEmpty {
    if (_messageQueue == nil || _messageQueue.count == 0) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
