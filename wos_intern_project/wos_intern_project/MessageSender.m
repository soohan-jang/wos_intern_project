//
//  MessageSender.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageSender.h"
#import "BluetoothSession.h"
#import "MessageData.h"

@interface MessageSender ()

@property (nonatomic, strong) GeneralSession *session;

@end

@implementation MessageSender


#pragma mark - Init Method

- (instancetype)initWithSession:(GeneralSession *)session {
    self = [super init];
    
    if (self) {
        switch (session.sessionType) {
            case SessionTypeBluetooth:
                self.session = (BluetoothSession *)session;
                break;
        }
        
        self.session = session;
    }
    
    return self;
}


#pragma mark - Send My Device's Screen Size Method

- (BOOL)sendScreenSizeMessage:(CGSize)screenSize {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypeScreenSize;
    data.screenSize = screenSize;
    
    return [self.session sendMessage:data];
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
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoFrameRequestConfirm;
    data.photoFrameIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendPhotoframeConfirmAckMessage:(BOOL)confrimAck {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoFrameRequestConfirmAck;
    data.photoFrameConfirmAck = confrimAck;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Select & Deselect Photo Data Message Methods

- (BOOL)sendSelectPhotoDataMessage:(NSIndexPath *)indexPath {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataSelect;
    data.photoDataIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeselectPhotoDataMessage:(NSIndexPath *)indexPath {
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
            
        }
    }];
}

- (BOOL)sendDeletePhotoDataMessage:(NSIndexPath *)indexPath {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataDelete;
    data.photoDataIndexPath = indexPath;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Insert & Update Photo Data Response Ack Meesage Methods

- (BOOL)sendInsertPhotoDataAckMessage:(NSIndexPath *)indexPath insertAck:(BOOL)insertAck {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataInsertAck;
    data.photoDataRecevieAck = insertAck;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendUpdatePhotoDataAckMessage:(NSIndexPath *)indexPath updateAck:(BOOL)updateAck {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypePhotoDataUpdateAck;
    data.photoDataRecevieAck = updateAck;
    
    return [self.session sendMessage:data];
}


#pragma mark - Send Select & Deselect Decorate Data Message Methods

- (BOOL)sendSelectDecorateDataMessage:(NSUUID *)uuid {
    MessageData *data = [[MessageData alloc] init];
    data.messageType = MessageTypeDecorateDataSelect;
    data.decorateDataUUID = uuid;
    
    return [self.session sendMessage:data];
}

- (BOOL)sendDeselectDecorateDataMessage:(NSUUID *)uuid {
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

@end
