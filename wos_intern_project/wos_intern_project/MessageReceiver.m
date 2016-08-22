//
//  MessageReceiver.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageReceiver.h"
#import "BluetoothSession.h"

@interface MessageReceiver () <SessionConnectDelegate, SessionDataReceiveDelegate>

@property (nonatomic, strong) GeneralSession *session;

@end

@implementation MessageReceiver

- (instancetype)initWithSession:(GeneralSession *)session {
    self = [super init];
    
    if (self) {
        switch (session.sessionType) {
            case SessionTypeBluetooth:
                self.session = (BluetoothSession *)session;
                self.session.connectDelegate = self;
                self.session.dataReceiveDelegate = self;
                break;
        }
    }
    
    return self;
}


#pragma mark - Session Connect Delegate Methods

- (void)didChangeAvailiableState:(NSInteger)state {
    if (self.stateChangeDelegate) {
        [self.stateChangeDelegate didReceiveChangeAvailiableState:state];
    }
}

- (void)didChangeSessionState:(NSInteger)state {
    if (self.stateChangeDelegate) {
        [self.stateChangeDelegate didReceiveChangeSessionState:state];
    }
}


#pragma mark - Session Data Receive Delegate Methods

- (void)didReceiveData:(MessageData *)message {
    if (self.photoFrameDataDelegate) {
        switch (message.messageType) {
            case MessageTypeScreenSize:
                [self.photoFrameDataDelegate didReceiveScreenSize:message.screenSize];
                break;
            case MessageTypePhotoFrameSelect:
                [self.photoFrameDataDelegate didReceiveSelectPhotoFrame:message.photoFrameIndexPath];
                break;
            case MessageTypePhotoFrameDeselect:
                [self.photoFrameDataDelegate didReceiveDeselectPhotoFrame:message.photoFrameIndexPath];
                break;
            case MessageTypePhotoFrameRequestConfirm:
                [self.photoFrameDataDelegate didReceiveRequestPhotoFrameConfirm:message.photoFrameIndexPath];
                break;
            case MessageTypePhotoFrameRequestConfirmAck:
                [self.photoFrameDataDelegate didReceiveReceivePhotoFrameConfirmAck:message.photoFrameConfirmAck];
                break;
        }
    }
    
    if (self.photoDataDelegate) {
        switch (message.messageType) {
            case MessageTypePhotoDataSelect:
                [self.photoDataDelegate didReceiveSelectPhotoData:message.photoDataIndexPath];
                break;
            case MessageTypePhotoDataDeselect:
                [self.photoDataDelegate didReceiveDeselectPhotoData:message.photoDataIndexPath];
                break;
            case MessageTypePhotoDataInsertStart:
                [self.photoDataDelegate didReceiveStartInsertPhotoData:message.photoDataIndexPath];
                break;
            case MessageTypePhotoDataInsertFinish:
                [self.photoDataDelegate didReceiveFinishInsertPhotoData:message.photoDataIndexPath];
                break;
            case MessageTypePhotoDataInsert:
                if (message.photoDataCroppedImageURL) {
                    [self.photoDataDelegate didReceiveInsertPhotoData:message.photoDataIndexPath
                                                        insertDataURL:message.photoDataCroppedImageURL
                                                           filterType:message.photoDataFilterType];
                    
                }
                
                if (message.photoDataOriginalImageURL) {
                    [self.photoDataDelegate didReceiveInsertPhotoData:message.photoDataIndexPath
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
                break;
            case MessageTypePhotoDataInsertAck:
                [self.photoDataDelegate didReceiveInsertPhotoDataAck:message.photoDataIndexPath];
                break;
            case MessageTypePhotoDataUpdateAck:
                [self.photoDataDelegate didReceiveUpdatePhotoDataAck:message.photoDataIndexPath];
                break;
        }
    }
    
    if (self.decorateDataDelegate) {
        switch (message.messageType) {
            case MessageTypeDecorateDataSelect:
                [self.decorateDataDelegate didReceiveSelectDecorateData:message.decorateDataUUID];
                break;
            case MessageTypeDecorateDataDeselect:
                [self.decorateDataDelegate didReceiveDeselectDecorateData:message.decorateDataUUID];
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
                break;

        }
    }
}

@end
