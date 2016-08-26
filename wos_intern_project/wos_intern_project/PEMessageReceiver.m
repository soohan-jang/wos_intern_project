//
//  MessageReceiver.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PEMessageReceiver.h"

#import "PEBluetoothSession.h"
#import "PEMessageInterrupter.h"

#import "ImageUtility.h"

@interface PEMessageReceiver () <SessionConnectDelegate, SessionDataReceiveDelegate>

@property (nonatomic, strong) PESession *session;

@end

@implementation PEMessageReceiver

- (instancetype)initWithSession:(PESession *)session {
    self = [super init];
    
    if (self) {
        switch (session.sessionType) {
            case SessionTypeBluetooth:
                self.session = (PEBluetoothSession *)session;
                self.messageBuffer = [[PEMessageBuffer alloc] init];
                self.session.connectDelegate = self;
                self.session.dataReceiveDelegate = self;
                break;
        }
    }
    
    return self;
}

- (void)setMessageBufferEnabled:(BOOL)enabled {
    self.messageBuffer.enabled = enabled;
}

- (void)startSynchronizeMessage {
    if ([self.messageBuffer isMessageBufferEnabled] && ![self.messageBuffer isMessageBufferEmpty]) {
        while (![self.messageBuffer isMessageBufferEmpty]) {
            [self dispatchMessage:[self.messageBuffer getMessage]];
        }
    }
    
    [self setMessageBufferEnabled:NO];
}

- (void)dispatchMessage:(PEMessage *)message {
    PEMessageInterrupter *messageInterrupter = [PEMessageInterrupter sharedInstance];
    
    if (self.photoFrameDataDelegate) {
        switch (message.messageType) {
            case MessageTypePhotoFrameSelect:
                NSLog(@"Receive MessageTypePhotoFrameSelect");
                [self.photoFrameDataDelegate didReceiveSelectPhotoFrame:message.photoFrameIndexPath];
                return;
            case MessageTypePhotoFrameDeselect:
                NSLog(@"Receive MessageTypePhotoFrameDeselect");
                [self.photoFrameDataDelegate didReceiveDeselectPhotoFrame:message.photoFrameIndexPath];
                return;
            case MessageTypePhotoFrameRequestConfirm:
                NSLog(@"Receive MessageTypePhotoFrameRequestConfirm");
                if ([messageInterrupter isInterruptRecvMessage:message.messageTimestamp]) {
                    NSLog(@"Interrupted MessageTypePhotoFrameRequestConfirm");
                    return;
                }
                
                [self.photoFrameDataDelegate didReceiveRequestPhotoFrameConfirm:message.photoFrameIndexPath];
                return;
            case MessageTypePhotoFrameRequestConfirmAck:
                NSLog(@"Receive MessageTypePhotoFrameRequestConfirmAck");
                [messageInterrupter clearInterrupter];
                [self.photoFrameDataDelegate didReceiveRequestPhotoFrameConfirmAck:message.photoFrameConfirmAck];
                return;
        }
    }
    
    if (self.deviceDataDelegate) {
        switch (message.messageType) {
            case MessageTypeDeviceDataScreenSize:
                NSLog(@"Receive MessageTypeDeviceDataScreenSize");
                [self.deviceDataDelegate didReceiveDeviceScreenSize:message.deviceDataScreenSize];
                return;
        }
    }
    
    if (self.photoDataDelegate) {
        switch (message.messageType) {
            case MessageTypePhotoDataSelect:
                NSLog(@"Receive MessageTypePhotoDataSelect");
                messageInterrupter.recvMessageTimestamp = message.messageTimestamp;
                if ([messageInterrupter isInterruptRecvMessage:message.messageTimestamp indexPath:message.photoDataIndexPath]) {
                    NSLog(@"Interrupted MessageTypePhotoDataSelect");
                    return;
                }
                
                [self.photoDataDelegate didReceiveSelectPhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataDeselect:
                NSLog(@"Receive MessageTypePhotoDataDeselect");
                [messageInterrupter clearInterrupter];
                [self.photoDataDelegate didReceiveDeselectPhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataReceiveStart:
                NSLog(@"Receive MessageTypePhotoDataReceiveStart");
                [self.photoDataDelegate didReceiveStartReceivePhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataReceiveFinish:
                NSLog(@"Receive MessageTypePhotoDataReceiveFinish");
                [messageInterrupter clearInterrupter];
                [self.photoDataDelegate didReceiveFinishReceivePhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataReceiveError:
                NSLog(@"Receive MessageTypePhotoDataReceiveError");
                [self.photoDataDelegate didReceiveErrorReceivePhotoData:message.photoDataIndexPath dataType:message.photoDataType];
                return;
            case MessageTypePhotoDataInsert:
                NSLog(@"Receive MessageTypePhotoDataInsert");
                if ([message.photoDataType isEqualToString:PhotoTypeOriginal]) {
                    [self.photoDataDelegate didReceiveInsertPhotoData:message.photoDataIndexPath
                                                             dataType:message.photoDataType
                                                        insertDataURL:message.photoDataOriginalImageURL
                                                           filterType:message.photoDataFilterType];
                } else if ([message.photoDataType isEqualToString:PhotoTypeCropped]) {
                    [self.photoDataDelegate didReceiveInsertPhotoData:message.photoDataIndexPath
                                                             dataType:message.photoDataType
                                                        insertDataURL:message.photoDataCroppedImageURL
                                                           filterType:message.photoDataFilterType];
                }
                
                return;
            case MessageTypePhotoDataUpdate:
                NSLog(@"Receive MessageTypePhotoDataUpdate");
                [self.photoDataDelegate didReceiveUpdatePhotoData:message.photoDataIndexPath
                                                    updateDataURL:message.photoDataCroppedImageURL
                                                       filterType:message.photoDataFilterType];
                return;
            case MessageTypePhotoDataDelete:
                NSLog(@"Receive MessageTypePhotoDataDelete");
                [messageInterrupter clearInterrupter];
                [self.photoDataDelegate didReceiveDeletePhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataReceiveAck:
                NSLog(@"Receive MessageTypePhotoDataReceiveAck");
                [messageInterrupter clearInterrupter];
                [self.photoDataDelegate didReceivePhotoDataAck:message.photoDataIndexPath
                                                           ack:message.photoDataRecevieAck];
                return;
        }
    }
    
    if (self.decorateDataDelegate) {
        switch (message.messageType) {
            case MessageTypeDecorateDataSelect:
                NSLog(@"Receive MessageTypeDecorateDataSelect");
                if ([messageInterrupter isInterruptRecvMessage:message.messageTimestamp uuid:message.decorateDataUUID]) {
                    NSLog(@"Interrupted MessageTypeDecorateDataSelect");
                    return;
                }
                
                [self.decorateDataDelegate didReceiveSelectDecorateData:message.decorateDataUUID];
                return;
            case MessageTypeDecorateDataDeselect:
                NSLog(@"Receive MessageTypeDecorateDataDeselect");
                [messageInterrupter clearInterrupter];
                [self.decorateDataDelegate didReceiveDeselectDecorateData:message.decorateDataUUID];
                return;
            case MessageTypeDecorateDataInsert:
                NSLog(@"Receive MessageTypeDecorateDataInsert");
                [self.decorateDataDelegate didReceiveInsertDecorateData:message.decorateData];
                return;
            case MessageTypeDecorateDataUpdate:
                NSLog(@"Receive MessageTypeDecorateDataUpdate");
                [self.decorateDataDelegate didReceiveUpdateDecorateData:message.decorateDataUUID
                                                            updateFrame:message.decorateDataFrame];
                return;
            case MessageTypeDecorateDataDelete:
                NSLog(@"Receive MessageTypeDecorateDataDelete");
                [messageInterrupter clearInterrupter];
                [self.decorateDataDelegate didReceiveDeleteDecorateData:message.decorateDataUUID];
                return;
                
        }
    }
}


#pragma mark - Session Connect Delegate Methods

- (void)didChangeSessionState:(NSInteger)state {
    NSLog(@"Change Session State : %ld", (long)state);
    if (self.stateChangeDelegate) {
        [self.stateChangeDelegate didReceiveChangeSessionState:state];
    }
}


#pragma mark - Session Data Receive Delegate Methods

- (void)didReceiveData:(PEMessage *)message {
    if (self.messageBuffer.enabled) {
        [self.messageBuffer putMessage:message];
        return;
    }
    
    [self dispatchMessage:message];
}

@end
