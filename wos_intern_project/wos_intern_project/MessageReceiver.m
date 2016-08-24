//
//  MessageReceiver.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageReceiver.h"
#import "PEBluetoothSession.h"
#import "MessageInterrupter.h"

@interface MessageReceiver () <SessionConnectDelegate, SessionDataReceiveDelegate>

@property (nonatomic, strong) PESession *session;

@end

@implementation MessageReceiver

- (instancetype)initWithSession:(PESession *)session {
    self = [super init];
    
    if (self) {
        switch (session.sessionType) {
            case SessionTypeBluetooth:
                self.session = (PEBluetoothSession *)session;
                self.messageBuffer = [[MessageBuffer alloc] init];
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


#pragma mark - Session Connect Delegate Methods

- (void)didChangeSessionState:(NSInteger)state {
    NSLog(@"Change Session State : %ld", (long)state);
    if (self.stateChangeDelegate) {
        [self.stateChangeDelegate didReceiveChangeSessionState:state];
    }
}


#pragma mark - Session Data Receive Delegate Methods

- (void)didReceiveData:(MessageData *)message {
    if (self.messageBuffer.enabled) {
        [self.messageBuffer putMessage:message];
        return;
    }
    
    MessageInterrupter *messageInterrupter = [MessageInterrupter sharedInstance];
    
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
                if ([messageInterrupter isMessageRecvInterrupt:message.messageTimestamp]) {
                    NSLog(@"Interrupted MessageTypePhotoFrameRequestConfirm");
                    return;
                }
                
                [self.photoFrameDataDelegate didReceiveRequestPhotoFrameConfirm:message.photoFrameIndexPath];
                return;
            case MessageTypePhotoFrameRequestConfirmAck:
                NSLog(@"Receive MessageTypePhotoFrameRequestConfirmAck");
                messageInterrupter.sendMessageTimestamp = 0;
                messageInterrupter.recvMessageTimestamp = 0;
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
                [self.photoDataDelegate didReceiveSelectPhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataDeselect:
                NSLog(@"Receive MessageTypePhotoDataDeselect");
                [self.photoDataDelegate didReceiveDeselectPhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataReceiveStart:
                NSLog(@"Receive MessageTypePhotoDataReceiveStart");
                [self.photoDataDelegate didReceiveStartReceivePhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataReceiveFinish:
                NSLog(@"Receive MessageTypePhotoDataReceiveFinish");
                [self.photoDataDelegate didReceiveFinishReceivePhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataReceiveError:
                NSLog(@"Receive MessageTypePhotoDataReceiveError");
                [self.photoDataDelegate didReceiveErrorReceivePhotoData:message.photoDataIndexPath dataType:message.photoDataType];
                return;
            case MessageTypePhotoDataInsert:
                NSLog(@"Receive MessageTypePhotoDataInsert");
                if (message.photoDataCroppedImageURL) {
                    [self.photoDataDelegate didReceiveInsertPhotoData:message.photoDataIndexPath
                                                             dataType:message.photoDataType
                                                        insertDataURL:message.photoDataCroppedImageURL
                                                           filterType:message.photoDataFilterType];
                    
                }
                
                if (message.photoDataOriginalImageURL) {
                    [self.photoDataDelegate didReceiveInsertPhotoData:message.photoDataIndexPath
                                                             dataType:message.photoDataType
                                                        insertDataURL:message.photoDataOriginalImageURL
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
                [self.photoDataDelegate didReceiveDeletePhotoData:message.photoDataIndexPath];
                return;
            case MessageTypePhotoDataReceiveAck:
                NSLog(@"Receive MessageTypePhotoDataReceiveAck");
                [self.photoDataDelegate didReceivePhotoDataAck:message.photoDataIndexPath
                                                           ack:message.photoDataRecevieAck];
                return;
        }
    }
    
    if (self.decorateDataDelegate) {
        switch (message.messageType) {
            case MessageTypeDecorateDataSelect:
                NSLog(@"Receive MessageTypeDecorateDataSelect");
                [self.decorateDataDelegate didReceiveSelectDecorateData:message.decorateDataUUID];
                return;
            case MessageTypeDecorateDataDeselect:
                NSLog(@"Receive MessageTypeDecorateDataDeselect");
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
                [self.decorateDataDelegate didReceiveDeleteDecorateData:message.decorateDataUUID];
                return;

        }
    }
}

@end
