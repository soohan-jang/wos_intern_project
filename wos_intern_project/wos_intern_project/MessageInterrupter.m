//
//  MessageInterrupter.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageInterrupter.h"

@interface MessageInterrupter ()

@property (nonatomic, assign) NSTimeInterval sentMessageTimestamp;
@property (nonatomic, assign) NSTimeInterval receivedMessageTimestamp;

@property (nonatomic, strong) NSIndexPath *sentIndexPath;
@property (nonatomic, strong) NSIndexPath *receivedIndexPath;

@property (nonatomic, strong) NSUUID *sentUUID;
@property (nonatomic, strong) NSUUID *receivedUUID;

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
        _receivedMessageTimestamp = 0;
        _sentMessageTimestamp = 0;
        
        _receivedIndexPath = nil;
        _sentIndexPath = nil;
        
        _receivedUUID = nil;
        _sentUUID = nil;
    }
    
    return self;
}

- (void)setSentTimestamp:(NSTimeInterval)timestamp {
    //이 메소드는 사진액자 최종선택을 위한 승인 단계에서 사용되는 인터럽트 메소드이다.
    //따라서 아래의 속성들 중 하나라도 값이 있으면, 이 메소드는 작동하지 않는다.
    if (_receivedIndexPath || _receivedUUID || _sentIndexPath || _sentUUID) {
        return;
    }
    
    _sentMessageTimestamp = timestamp;
    
    [self interruptConfirmRequest];
}

- (void)setSentTimestamp:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath {
    //이 메소드는 사진 데이터 선택 시 사용되는 인터럽트 메소드이다.
    //따라서 아래의 속성이 모두 있을 때만 작동한다.
    if (!(_receivedMessageTimestamp && _receivedIndexPath)) {
        return;
    }
    
    _sentMessageTimestamp = timestamp;
    _sentIndexPath = indexPath;
    
    [self interruptPhotoDataSelection];
}

- (void)setSentTimestamp:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid {
    //이 메소드는 데코레이트 데이터 선택 시 사용되는 인터럽트 메소드이다.
    //따라서 아래의 속성이 모두 있을 때만 작동한다.
    if (!(_receivedMessageTimestamp && _receivedUUID)) {
        return;
    }
    
    _sentMessageTimestamp = timestamp;
    _sentUUID = uuid;
    
    [self interruptDecorateDataSelection];
}

- (void)setReceivedTimestamp:(NSTimeInterval)timestamp {
    //이 메소드는 사진액자 최종선택을 위한 승인 단계에서 사용되는 인터럽트 메소드이다.
    //따라서 아래의 속성들 중 하나라도 값이 있으면, 이 메소드는 작동하지 않는다.
    if (_receivedIndexPath || _receivedUUID || _sentIndexPath || _sentUUID) {
        return;
    }
    
    _receivedMessageTimestamp = timestamp;

    [self interruptConfirmRequest];
}

- (void)setReceivedTimestamp:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath {
    //이 메소드는 사진 데이터 선택 시 사용되는 인터럽트 메소드이다.
    //따라서 아래의 속성이 모두 있을 때만 작동한다.
    if (!(_sentMessageTimestamp && _sentIndexPath)) {
        return;
    }
    
    _receivedMessageTimestamp = timestamp;
    _receivedIndexPath = indexPath;
    
    [self interruptPhotoDataSelection];
}

- (void)setReceivedTimestamp:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid {
    //이 메소드는 데코레이트 데이터 선택 시 사용되는 인터럽트 메소드이다.
    //따라서 아래의 속성이 모두 있을 때만 작동한다.
    if (!(_sentMessageTimestamp && _sentUUID)) {
        return;
    }
    
    _receivedMessageTimestamp = timestamp;
    _receivedUUID = uuid;
    
    [self interruptDecorateDataSelection];
}


#pragma mark - Interrupting Check Internal Methods

- (void)interruptConfirmRequest {
    //두 개의 타임스탬프를 가지고 있다는 것은, 두 사용자 모두 승인 메시지를 송신했음을 의미한다.
    //이 경우에서 "자신"의 타임스탬프가 상대방보다 크면( = 늦게 승인 메시지를 송신했으면) 자신의 작업을 취소한다.
    if (_sentMessageTimestamp == 0 || _receivedMessageTimestamp == 0 || _sentMessageTimestamp < _receivedMessageTimestamp) {
        return;
    }
    
    if (self.interruptConfirmRequestDelegate) {
        [self.interruptConfirmRequestDelegate interruptConfirmRequest];
    }
    
    //작업을 취소했으므로 송신 타임스탬프를 0으로 초기화한다.
    _sentMessageTimestamp = 0;
}

- (void)interruptPhotoDataSelection {
    //두 개의 타임스탬프를 가지고 있다는 것은, 두 사용자 모두 승인 메시지를 송신했음을 의미한다.
    //이 경우에서 "자신"의 타임스탬프가 상대방보다 크면( = 늦게 승인 메시지를 송신했으면) 자신의 작업을 취소한다.
    if (_sentMessageTimestamp == 0 || _receivedMessageTimestamp == 0 || _sentMessageTimestamp < _receivedMessageTimestamp) {
        return;
    }
    
    //두 개의 타임스탬프를 모두 가지고 있다면, 선택한 사진 데이터의 인덱스패스가 일치하는지 확인한다.
    if (_sentIndexPath.item != _receivedIndexPath.item) {
        return;
    }
    
    if (self.interruptPhotoDataSelectionDelegate) {
        [self.interruptPhotoDataSelectionDelegate interruptPhotoDataSelction:_sentIndexPath];
    }
    
    //작업을 취소했으므로 송신 타임스탬프, 인덱스 패스를 초기화한다.
    _sentMessageTimestamp = 0;
    _sentIndexPath = nil;
}

- (void)interruptDecorateDataSelection {
    //두 개의 타임스탬프를 가지고 있다는 것은, 두 사용자 모두 승인 메시지를 송신했음을 의미한다.
    //이 경우에서 "자신"의 타임스탬프가 상대방보다 크면( = 늦게 승인 메시지를 송신했으면) 자신의 작업을 취소한다.
    if (_sentMessageTimestamp == 0 || _receivedMessageTimestamp == 0 || _sentMessageTimestamp < _receivedMessageTimestamp) {
        return;
    }
    
    //두 개의 타임스탬프를 모두 가지고 있다면, 선택한 데코레이트 데이터의 UUID가 일치하는지 확인한다.
    if (![_sentUUID.UUIDString isEqualToString:_receivedUUID.UUIDString]) {
        return;
    }
    
    if (self.interruptDecorateDataSelectionDelegate) {
        [self.interruptDecorateDataSelectionDelegate interruptDecorateDataSelection:_sentUUID];
    }
    
    //작업을 취소했으므로 송신 타임스탬프, 인덱스 패스를 초기화한다.
    _sentMessageTimestamp = 0;
    _sentUUID = nil;
}

@end
