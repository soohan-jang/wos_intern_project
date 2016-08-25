//
//  MessageSender.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageSender.h"
#import "PEBluetoothSession.h"
#import "MessageInterrupter.h"
#import "MessageData.h"

@interface MessageSender ()

@property (nonatomic, strong) PESession *session;

@end

@implementation MessageSender


#pragma mark - Init Method

- (instancetype)initWithSession:(PESession *)session {
    self = [super init];
    
    if (self) {
        switch (session.sessionType) {
            case SessionTypeBluetooth:
                self.session = (PEBluetoothSession *)session;
                break;
        }
        
        self.session = session;
    }
    
    return self;
}


#pragma mark - Send Select & Deselect Photo Frame Message Methods

- (BOOL)sendSelectPhotoFrameMessage:(NSIndexPath *)indexPath {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoFrameSelect;
    data.photoFrameIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeselectPhotoFrameMessage:(NSIndexPath *)indexPath {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoFrameDeselect;
    data.photoFrameIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Photo Frame Confrim & Response Message Methods

- (BOOL)sendPhotoFrameConfrimRequestMessage:(NSIndexPath *)indexPath {
    NSTimeInterval timestamp = [self timestamp];
    
    if ([[MessageInterrupter sharedInstance] isInterruptSendMessage:timestamp]) {
        NSLog(@"Interrupted sendPhotoFrameConfrimRequestMessage");
        return NO;
    }
    
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoFrameRequestConfirm;
    data.messageTimestamp = timestamp;
    data.photoFrameIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendPhotoFrameConfirmAckMessage:(BOOL)confrimAck {
    MessageInterrupter *messageInterrupter = [MessageInterrupter sharedInstance];
    messageInterrupter.sendMessageTimestamp = 0;
    messageInterrupter.recvMessageTimestamp = 0;
    
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoFrameRequestConfirmAck;
    data.photoFrameConfirmAck = confrimAck;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send My Device's Screen Size Method

- (BOOL)sendScreenSizeDeviceDataMessage:(CGSize)screenSize {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypeDeviceDataScreenSize;
    data.deviceDataScreenSize = screenSize;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Select & Deselect Photo Data Message Methods

- (BOOL)sendSelectPhotoDataMessage:(NSIndexPath *)indexPath {
    NSTimeInterval timestamp = [self timestamp];
    
    if ([[MessageInterrupter sharedInstance] isInterruptSendMessage:timestamp indexPath:indexPath]) {
        NSLog(@"Interrupted sendSelectPhotoDataMessage");
        return NO;
    }
    
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataSelect;
    data.messageTimestamp = timestamp;
    data.photoDataIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeselectPhotoDataMessage:(NSIndexPath *)indexPath {
    [[MessageInterrupter sharedInstance] clearInterrupter];
    
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataDeselect;
    data.photoDataIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Insert & Update & Delete Photo Data Message Methods

- (void)sendInsertPhotoDataMessage:(NSIndexPath *)indexPath originalImageURL:(NSURL *)originalImageURL croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataInsert;
    data.photoDataIndexPath = indexPath;
    data.photoDataOriginalImageURL = originalImageURL;
    data.photoDataCroppedImageURL = croppedImageURL;
    data.photoDataFilterType = filterType;
    
    [self.session sendResource:data resultBlock:^(BOOL success) {
        if (!success) {
            //error
        }
    }];
}

- (void)sendUpdatePhotoDataMessage:(NSIndexPath *)indexPath croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataUpdate;
    data.photoDataIndexPath = indexPath;
    data.photoDataCroppedImageURL = croppedImageURL;
    data.photoDataFilterType = filterType;
    
    [self.session sendResource:data resultBlock:^(BOOL success) {
        if (!success) {
            //error
        }
    }];
}

- (BOOL)sendDeletePhotoDataMessage:(NSIndexPath *)indexPath {
    [[MessageInterrupter sharedInstance] clearInterrupter];
    
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataDelete;
    data.photoDataIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Insert & Update Photo Data Response Ack Meesage Methods

- (BOOL)sendPhotoDataAckMessage:(NSIndexPath *)indexPath ack:(BOOL)ack {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataReceiveAck;
    data.photoDataIndexPath = indexPath;
    data.photoDataRecevieAck = ack;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Select & Deselect Decorate Data Message Methods

- (BOOL)sendSelectDecorateDataMessage:(NSUUID *)uuid {
    NSTimeInterval timestamp = [self timestamp];
    
    if ([[MessageInterrupter sharedInstance] isInterruptSendMessage:timestamp uuid:uuid]) {
        NSLog(@"Interrupted sendSelectDecorateDataMessage");
        return NO;
    }

    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypeDecorateDataSelect;
    data.messageTimestamp = timestamp;
    data.decorateDataUUID = uuid;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeselectDecorateDataMessage:(NSUUID *)uuid {
    [[MessageInterrupter sharedInstance] clearInterrupter];
    
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypeDecorateDataDeselect;
    data.decorateDataUUID = uuid;
    
    return [self.session sendMessage:data];
}


#pragma mark - Insert & Update & Delete Decorate Data Message Methods

- (BOOL)sendInsertDecorateDataMessage:(DecorateData *)insertData {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypeDecorateDataInsert;
    data.decorateData = insertData;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendUpdateDecorateDataMessage:(NSUUID *)uuid updateFrame:(CGRect)updateFrame {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypeDecorateDataUpdate;
    data.decorateDataUUID = uuid;
    data.decorateDataFrame = updateFrame;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeleteDecorateDataMessage:(NSUUID *)uuid {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypeDecorateDataDelete;
    data.decorateDataUUID = uuid;
    
    return [self.session sendMessage:data];
}


#pragma mark - Utility Methods

- (NSTimeInterval)timestamp {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

@end
