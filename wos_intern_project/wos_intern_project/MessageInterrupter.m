//
//  MessageInterrupter.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageInterrupter.h"

@interface MessageInterrupter ()

@end

@implementation MessageInterrupter

+ (instancetype)sharedInstance {
    static MessageInterrupter *instance = nil;
    
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

- (BOOL)isMessageSendInterrupt:(NSTimeInterval)timestamp {
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

- (BOOL)isMessageSendInterrupt:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)isMessageSendInterrupt:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid {
    return NO;
}


#pragma mark - Check Recv Interrupt Methods

- (BOOL)isMessageRecvInterrupt:(NSTimeInterval)timestamp {
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

- (BOOL)isMessageRecvInterrupt:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)isMessageRecvInterrupt:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid {
    return NO;
}


//#pragma mark - Interrupting Check Internal Methods
//
//- (void)interruptConfirmRequest {
//    BOOL interrupt = NO;
//    
//    //두 개의 타임스탬프를 가지고 있다는 것은, 두 사용자 모두 승인 메시지를 송신했음을 의미한다.
//    //이 경우에서 "자신"의 타임스탬프가 상대방보다 크면( = 늦게 승인 메시지를 송신했으면) 자신의 작업을 취소한다.
//    if (_sentMessageTimestamp == 0 || _receivedMessageTimestamp == 0 || _sentMessageTimestamp < _receivedMessageTimestamp) {
//        interrupt = NO;
//    } else {
//        interrupt = YES;
//    }
//    
//    if (self.interruptConfirmRequestDelegate) {
//        [self.interruptConfirmRequestDelegate interruptConfirmRequest:interrupt];
//    }
//    
//    if (interrupt) {
//        //작업을 취소했으므로 송신 타임스탬프를 0으로 초기화한다.
//        _sentMessageTimestamp = 0;
//    }
//}
//
//- (void)interruptPhotoDataSelection {
//    //두 개의 타임스탬프를 가지고 있다는 것은, 두 사용자 모두 승인 메시지를 송신했음을 의미한다.
//    //이 경우에서 "자신"의 타임스탬프가 상대방보다 크면( = 늦게 승인 메시지를 송신했으면) 자신의 작업을 취소한다.
//    if (_sentMessageTimestamp == 0 || _receivedMessageTimestamp == 0 || _sentMessageTimestamp < _receivedMessageTimestamp) {
//        return;
//    }
//    
//    //두 개의 타임스탬프를 모두 가지고 있다면, 선택한 사진 데이터의 인덱스패스가 일치하는지 확인한다.
//    if (_sentIndexPath.item != _receivedIndexPath.item) {
//        return;
//    }
//    
////    if (self.interruptPhotoDataSelectionDelegate) {
////        [self.interruptPhotoDataSelectionDelegate interruptPhotoDataSelction:_sentIndexPath];
////    }
//    
//    //작업을 취소했으므로 송신 타임스탬프, 인덱스 패스를 초기화한다.
//    _sentMessageTimestamp = 0;
//    _sentIndexPath = nil;
//}
//
//- (void)interruptDecorateDataSelection {
//    //두 개의 타임스탬프를 가지고 있다는 것은, 두 사용자 모두 승인 메시지를 송신했음을 의미한다.
//    //이 경우에서 "자신"의 타임스탬프가 상대방보다 크면( = 늦게 승인 메시지를 송신했으면) 자신의 작업을 취소한다.
//    if (_sentMessageTimestamp == 0 || _receivedMessageTimestamp == 0 || _sentMessageTimestamp < _receivedMessageTimestamp) {
//        return;
//    }
//    
//    //두 개의 타임스탬프를 모두 가지고 있다면, 선택한 데코레이트 데이터의 UUID가 일치하는지 확인한다.
//    if (![_sentUUID.UUIDString isEqualToString:_receivedUUID.UUIDString]) {
//        return;
//    }
//    
//    if (self.interruptDecorateDataSelectionDelegate) {
//        [self.interruptDecorateDataSelectionDelegate interruptDecorateDataSelection:_sentUUID];
//    }
//    
//    //작업을 취소했으므로 송신 타임스탬프, 인덱스 패스를 초기화한다.
//    _sentMessageTimestamp = 0;
//    _sentUUID = nil;
//}

@end
