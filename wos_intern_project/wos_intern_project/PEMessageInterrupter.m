//
//  MessageInterrupter.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PEMessageInterrupter.h"

@interface PEMessageInterrupter ()

@end

@implementation PEMessageInterrupter

+ (instancetype)sharedInstance {
    static PEMessageInterrupter *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _sendMessageTimestamp = 0;
        _recvMessageTimestamp = 0;
        
        _sendIndexPath = nil;
        _recvIndexPath = nil;
        
        _sendUUID = nil;
        _recvUUID = nil;
    }
    
    return self;
}


#pragma mark - Check Send Interrupt Methods

- (BOOL)isInterruptSendMessage:(NSTimeInterval)timestamp {
    _sendMessageTimestamp = timestamp;
    
    if (_recvMessageTimestamp == 0) {
        return NO;
    }
    
    if (_recvMessageTimestamp < _sendMessageTimestamp) {
        _sendMessageTimestamp = 0;
        return YES;
    }
    
    return NO;
}

- (BOOL)isInterruptSendMessage:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath {
    _sendMessageTimestamp = timestamp;
    _sendIndexPath = indexPath;
    
    if (_recvMessageTimestamp == 0 || _recvIndexPath == nil) {
        return NO;
    }
    
    if (_recvMessageTimestamp < _sendMessageTimestamp && _recvIndexPath.item == _sendIndexPath.item) {
        _sendMessageTimestamp = 0;
        _sendIndexPath = nil;
        return YES;
    }
    
    return NO;
}

- (BOOL)isInterruptSendMessage:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid {
    _sendMessageTimestamp = timestamp;
    _sendUUID = uuid;
    
    if (_recvMessageTimestamp == 0 || _recvUUID == nil) {
        return NO;
    }
    
    if (_recvMessageTimestamp < _sendMessageTimestamp && [_recvUUID.UUIDString isEqualToString:_sendUUID.UUIDString]) {
        _sendMessageTimestamp = 0;
        _sendUUID = 0;
        return YES;
    }
    
    return NO;
}


#pragma mark - Check Recv Interrupt Methods

- (BOOL)isInterruptRecvMessage:(NSTimeInterval)timestamp {
    _recvMessageTimestamp = timestamp;
    
    if (_sendMessageTimestamp == 0) {
        return NO;
    }
    
    if (_sendMessageTimestamp < _recvMessageTimestamp) {
        _recvMessageTimestamp = 0;
        return YES;
    }
    
    return NO;
}

- (BOOL)isInterruptRecvMessage:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath {
    _recvMessageTimestamp = timestamp;
    _recvIndexPath = indexPath;
    
    if (_sendMessageTimestamp == 0 || _sendIndexPath == nil) {
        return NO;
    }
    
    if (_sendMessageTimestamp < _recvMessageTimestamp && _sendIndexPath.item == _recvIndexPath.item) {
        _recvMessageTimestamp = 0;
        _recvIndexPath = 0;
        return YES;
    }
    
    return NO;
}

- (BOOL)isInterruptRecvMessage:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid {
    _recvMessageTimestamp = timestamp;
    _recvUUID = uuid;
    
    if (_sendMessageTimestamp == 0 || _sendUUID == nil) {
        return NO;
    }
    
    if (_sendMessageTimestamp < _recvMessageTimestamp && [_sendUUID.UUIDString isEqualToString:_recvUUID.UUIDString]) {
        _recvMessageTimestamp = 0;
        _recvUUID = nil;
        return YES;
    }
    
    return NO;
}


#pragma mark - Clear Methods

- (void)clearInterrupter {
    _sendMessageTimestamp = 0;
    _sendIndexPath = nil;
    _sendUUID = nil;
    
    _recvMessageTimestamp = 0;
    _recvIndexPath = nil;
    _recvUUID = nil;
}

@end
