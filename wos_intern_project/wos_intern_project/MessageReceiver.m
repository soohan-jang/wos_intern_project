//
//  MessageReceiver.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageReceiver.h"
#import "PEBluetoothSession.h"
#import "MessageBuffer.h"
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
                self.session.connectDelegate = self;
                self.session.dataReceiveDelegate = self;
                break;
        }
    }
    
    return self;
}


#pragma mark - Session Connect Delegate Methods

- (void)didChangeSessionState:(NSInteger)state {
    if (self.stateChangeDelegate) {
        [self.stateChangeDelegate didReceiveChangeSessionState:state];
    }
}


#pragma mark - Session Data Receive Delegate Methods

- (void)didReceiveData:(MessageData *)message {
    MessageInterrupter *messageInterrupter = [MessageInterrupter sharedInstance];
    
    if (self.photoFrameDataDelegate) {
        switch (message.messageType) {
            case MessageTypePhotoFrameSelect:
                [self.photoFrameDataDelegate didReceiveSelectPhotoFrame:message.photoFrameIndexPath];
                break;
            case MessageTypePhotoFrameDeselect:
                [self.photoFrameDataDelegate didReceiveDeselectPhotoFrame:message.photoFrameIndexPath];
                break;
            case MessageTypePhotoFrameRequestConfirm:
                [self.photoFrameDataDelegate didReceiveRequestPhotoFrameConfirm:message.photoFrameIndexPath];
                [messageInterrupter setReceivedTimestamp:message.messageTimestamp];
                break;
            case MessageTypePhotoFrameRequestConfirmAck:
                [self.photoFrameDataDelegate didReceiveReceivePhotoFrameConfirmAck:message.photoFrameConfirmAck];
                [messageInterrupter setReceivedTimestamp:0];
                break;
        }
    }
    
    if (self.deviceDataDelegate) {
        switch (message.messageType) {
            case MessageTypeDeviceDataScreenSize:
                [self.deviceDataDelegate didReceiveDeviceScreenSize:message.deviceDataScreenSize];
                break;
        }
    }
    
    if (self.photoDataDelegate) {
        switch (message.messageType) {
            case MessageTypePhotoDataSelect:
                [self.photoDataDelegate didReceiveSelectPhotoData:message.photoDataIndexPath];
                [messageInterrupter setReceivedTimestamp:message.messageTimestamp indexPath:message.photoDataIndexPath];
                break;
            case MessageTypePhotoDataDeselect:
                [self.photoDataDelegate didReceiveDeselectPhotoData:message.photoDataIndexPath];
                [messageInterrupter setReceivedTimestamp:0 indexPath:nil];
                break;
            case MessageTypePhotoDataReceiveStart:
                [self.photoDataDelegate didReceiveStartReceivePhotoData:message.photoDataIndexPath];
                break;
            case MessageTypePhotoDataReceiveFinish:
                [self.photoDataDelegate didReceiveFinishReceivePhotoData:message.photoDataIndexPath];
                break;
            case MessageTypePhotoDataReceiveError:
                [self.photoDataDelegate didReceiveErrorReceivePhotoData:message.photoDataIndexPath dataType:message.photoDataType];
                break;
            case MessageTypePhotoDataInsert:
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
                break;
            case MessageTypePhotoDataUpdate:
                [self.photoDataDelegate didReceiveUpdatePhotoData:message.photoDataIndexPath
                                                    updateDataURL:message.photoDataCroppedImageURL
                                                       filterType:message.photoDataFilterType];
                break;
            case MessageTypePhotoDataDelete:
                [self.photoDataDelegate didReceiveDeletePhotoData:message.photoDataIndexPath];
                [messageInterrupter setReceivedTimestamp:0 uuid:nil];
                break;
            case MessageTypePhotoDataReceiveAck:
                [self.photoDataDelegate didReceivePhotoDataAck:message.photoDataIndexPath
                                                           ack:message.photoDataRecevieAck];
                break;
        }
    }
    
    if (self.decorateDataDelegate) {
        switch (message.messageType) {
            case MessageTypeDecorateDataSelect:
                [self.decorateDataDelegate didReceiveSelectDecorateData:message.decorateDataUUID];
                [messageInterrupter setReceivedTimestamp:message.messageTimestamp uuid:message.decorateDataUUID];
                break;
            case MessageTypeDecorateDataDeselect:
                [self.decorateDataDelegate didReceiveDeselectDecorateData:message.decorateDataUUID];
                [messageInterrupter setReceivedTimestamp:0 uuid:nil];
                break;
            case MessageTypeDecorateDataInsert:
                [self.decorateDataDelegate didReceiveInsertDecorateData:message.decorateData];
                break;
            case MessageTypeDecorateDataUpdate:
                [self.decorateDataDelegate didReceiveUpdateDecorateData:message.decorateDataUUID
                                                            updateFrame:message.decorateDataFrame];
                break;
            case MessageTypeDecorateDataDelete:
                [self.decorateDataDelegate didReceiveDeleteDecorateData:message.decorateDataUUID];
                [messageInterrupter setReceivedTimestamp:0 uuid:nil];
                break;

        }
    }
}

@end
