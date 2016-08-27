//
//  MessageSender.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PEMessageSender.h"

#import "PEBluetoothSession.h"
#import "PEMessageInterrupter.h"

#import "PEMessage.h"

@interface PEMessageSender ()

@property (nonatomic, strong) PESession *session;

@end

@implementation PEMessageSender


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
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoFrameSelect;
    data.photoFrameIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeselectPhotoFrameMessage:(NSIndexPath *)indexPath {
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoFrameDeselect;
    data.photoFrameIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Photo Frame Confrim & Response Message Methods

- (BOOL)sendPhotoFrameConfrimRequestMessage:(NSIndexPath *)indexPath {
    NSTimeInterval timestamp = [self timestamp];
    
    if ([[PEMessageInterrupter sharedInstance] isInterruptSendMessage:timestamp]) {
        NSLog(@"Interrupted sendPhotoFrameConfrimRequestMessage");
        return NO;
    }
    
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoFrameRequestConfirm;
    data.messageTimestamp = timestamp;
    data.photoFrameIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendPhotoFrameConfirmAckMessage:(BOOL)confrimAck {
    PEMessageInterrupter *messageInterrupter = [PEMessageInterrupter sharedInstance];
    messageInterrupter.sendMessageTimestamp = 0;
    messageInterrupter.recvMessageTimestamp = 0;
    
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoFrameRequestConfirmAck;
    data.photoFrameConfirmAck = confrimAck;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send My Device's Screen Size Method

- (BOOL)sendScreenSizeDeviceDataMessage:(CGSize)screenSize {
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypeDeviceDataScreenSize;
    data.deviceDataScreenSize = screenSize;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Select & Deselect Photo Data Message Methods

- (BOOL)sendSelectPhotoDataMessage:(NSIndexPath *)indexPath {
    NSTimeInterval timestamp = [self timestamp];
    
    if ([[PEMessageInterrupter sharedInstance] isInterruptSendMessage:timestamp indexPath:indexPath]) {
        NSLog(@"Interrupted sendSelectPhotoDataMessage");
        return NO;
    }
    
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoDataSelect;
    data.messageTimestamp = timestamp;
    data.photoDataIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeselectPhotoDataMessage:(NSIndexPath *)indexPath {
    [[PEMessageInterrupter sharedInstance] clearInterrupter];
    
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoDataDeselect;
    data.photoDataIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Insert & Update & Delete Photo Data Message Methods

- (void)sendInsertPhotoDataMessage:(NSIndexPath *)indexPath originalImageURL:(NSURL *)originalImageURL croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType {
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoDataInsert;
    data.photoDataIndexPath = indexPath;
    data.photoDataOriginalImageURL = originalImageURL;
    data.photoDataCroppedImageURL = croppedImageURL;
    data.photoDataFilterType = filterType;
    
    [self.session sendResource:data];
}

- (void)sendUpdatePhotoDataMessage:(NSIndexPath *)indexPath croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType {
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoDataUpdate;
    data.photoDataIndexPath = indexPath;
    data.photoDataCroppedImageURL = croppedImageURL;
    data.photoDataFilterType = filterType;
    
    [self.session sendResource:data];
}

- (BOOL)sendDeletePhotoDataMessage:(NSIndexPath *)indexPath {
    [[PEMessageInterrupter sharedInstance] clearInterrupter];
    
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoDataDelete;
    data.photoDataIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Insert & Update Photo Data Response Ack Meesage Methods

- (BOOL)sendPhotoDataAckMessage:(NSIndexPath *)indexPath ack:(BOOL)ack {
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypePhotoDataReceiveAck;
    data.photoDataIndexPath = indexPath;
    data.photoDataRecevieAck = ack;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Select & Deselect Decorate Data Message Methods

- (BOOL)sendSelectDecorateDataMessage:(NSUUID *)uuid {
    NSTimeInterval timestamp = [self timestamp];
    
    if ([[PEMessageInterrupter sharedInstance] isInterruptSendMessage:timestamp uuid:uuid]) {
        NSLog(@"Interrupted sendSelectDecorateDataMessage");
        return NO;
    }

    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypeDecorateDataSelect;
    data.messageTimestamp = timestamp;
    data.decorateDataUUID = uuid;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeselectDecorateDataMessage:(NSUUID *)uuid {
    [[PEMessageInterrupter sharedInstance] clearInterrupter];
    
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypeDecorateDataDeselect;
    data.decorateDataUUID = uuid;
    
    return [self.session sendMessage:data];
}


#pragma mark - Insert & Update & Delete Decorate Data Message Methods

- (BOOL)sendInsertDecorateDataMessage:(PEDecorate *)insertData {
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypeDecorateDataInsert;
    data.decorateData = insertData;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendUpdateDecorateDataMessage:(NSUUID *)uuid updateFrame:(CGRect)updateFrame {
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypeDecorateDataUpdate;
    data.decorateDataUUID = uuid;
    data.decorateDataFrame = updateFrame;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeleteDecorateDataMessage:(NSUUID *)uuid {
    PEMessage *data = [[PEMessage alloc] init];
    data.messageType = MessageTypeDecorateDataDelete;
    data.decorateDataUUID = uuid;
    
    return [self.session sendMessage:data];
}


#pragma mark - Utility Methods

- (NSTimeInterval)timestamp {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

@end
