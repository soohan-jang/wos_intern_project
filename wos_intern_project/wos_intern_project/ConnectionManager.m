//
//  ConnectionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ConnectionManager.h"
#import "CommonConstants.h"
#import "ImageUtility.h"
#import "MessageFactory.h"

NSString *const ConnectionManagerServiceType = @"Co-PhotoEditor";

@interface ConnectionManager ()

@property (nonatomic, strong) CBCentralManager *bluetoothManager;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *messageQueue;
@property (nonatomic, strong) NSNumber *lastSendMsgTimestamp;
@property (nonatomic, strong) NSIndexPath *selectedPhotoFrameIndex;
@property (nonatomic, strong) NSUUID *selectedDecorateDataUUID;

@end

@implementation ConnectionManager

+ (instancetype)sharedInstance {
    static ConnectionManager *instance = nil;
    
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
        _ownPeerId = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
        _ownSession = [[MCSession alloc] initWithPeer:_ownPeerId];
        _ownSession.delegate = self;
        _sessionState = MCSessionStateNotConnected;
        
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        self.messageQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)isBluetoothAvailable {
    NSInteger state = self.bluetoothManager.state;
    
    if (state == CBCentralManagerStatePoweredOn) {
        return YES;
    } else {
        return NO;
    }
}

- (void)sendMessage:(NSDictionary *)message {
    if (message[kDataType] == nil) {
        return;
    }
    
    switch ([message[kDataType] integerValue]) {
        case vDataTypePhotoFrameRequestConfirm:
            self.lastSendMsgTimestamp = message[kPhotoFrameConfirmTimestamp];
            break;
        case vDataTypePhotoEdit:
            self.lastSendMsgTimestamp = message[kPhotoEditTimestamp];
            self.selectedPhotoFrameIndex = message[kPhotoIndexPath];
            break;
        case vDataTypeDecorateEdit:
            self.lastSendMsgTimestamp = message[kDecorateEditTimestamp];
            self.selectedDecorateDataUUID = message[kDecorateUUID];
            break;
        default:
            self.lastSendMsgTimestamp = nil;
            self.selectedPhotoFrameIndex = nil;
            self.selectedDecorateDataUUID = nil;
    }
    
    NSData *archivedMessage = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.ownSession sendData:archivedMessage toPeers:self.ownSession.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}

- (void)sendPhotoDataWithFilename:(NSString *)filename fullscreenImageURL:(NSURL *)fullscreenImageURL croppedImageURL:(NSURL *)croppedImageURL index:(NSInteger)index {
    for (MCPeerID *peer in self.ownSession.connectedPeers) {
        NSString *croppedImageResourceName = [NSString stringWithFormat:@"%@%@%@", [@(index) stringValue], SperatorImageName, PostfixImageCropped];
        [self.ownSession sendResourceAtURL:croppedImageURL withName:croppedImageResourceName toPeer:peer withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            } else {
                NSString *fullscreenImageResourceName = [NSString stringWithFormat:@"%@%@%@", [@(index) stringValue], SperatorImageName, PostfixImageFullscreen];
                
                [self.ownSession sendResourceAtURL:fullscreenImageURL withName:fullscreenImageResourceName toPeer:peer withCompletionHandler:^(NSError *error) {
                    if (error) {
                        NSLog(@"%@", error.localizedDescription);
                    }
                    
                    //파일 전송이 종료되었으므로, 파일 전송을 위해 임시저장했던 이미지 파일을 삭제한다.
                    [ImageUtility removeTemporaryImageWithFilename:filename];
                }];
            }
        }];
    }
}

- (void)disconnectSession {
    self.sessionDelegate = nil;
    self.photoFrameDelegate = nil;
    self.photoFrameDataDelegate = nil;
    self.photoDataDelegate = nil;
    self.decorateDataDelegate = nil;
    
    self.messageQueueEnabled = NO;
    [self clearMessageQueue];
    
    [self.ownSession disconnect];
}

- (void)clear {
    _ownPeerId = nil;
    _ownSession.delegate = nil;
    _ownSession = nil;
    
    self.bluetoothManager.delegate = nil;
    self.bluetoothManager = nil;
    
    self.messageQueue = nil;
}

- (void)calculateScreenRatio:(CGSize)otherScreenSize {
    CGSize ownScreenSize = [UIScreen mainScreen].bounds.size;
    _widthRatio = otherScreenSize.width / ownScreenSize.width;
    _heightRatio = otherScreenSize.height / ownScreenSize.height;
}


#pragma mark - MessageQueue Methods

- (void)putMessage:(NSDictionary *)message {
    if (self.messageQueue == nil) {
        self.messageQueue = [[NSMutableArray alloc] init];
    }
    
    [self.messageQueue addObject:message];
}

- (NSDictionary *)getMessage {
    if (self.messageQueue.count > 0) {
        NSDictionary *message = self.messageQueue[0];
        [self.messageQueue removeObjectAtIndex:0];
        return message;
    } else {
        return nil;
    }
}

- (void)clearMessageQueue {
    if (self.messageQueue != nil && self.messageQueue.count > 0) {
        [self.messageQueue removeAllObjects];
    }
}

- (BOOL)isMessageQueueEmpty {
    if (self.messageQueue == nil || self.messageQueue.count == 0) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if (self.sessionDelegate) {
        _sessionState = state;
        
        switch (_sessionState) {
            case MCSessionStateConnected:
                NSLog(@"Session Connected");
                [self.sessionDelegate receivedPeerConnected];
                break;
            case MCSessionStateNotConnected:
                NSLog(@"Session Disconnected");
                self.lastSendMsgTimestamp = nil;
                [self.sessionDelegate receivedPeerDisconnected];
                break;
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *message = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSInteger dataType = [message[kDataType] integerValue];
    
    if (self.photoFrameDelegate) {
        switch (dataType) {
            case vDataTypePhotoFrameRequestConfirm:
                NSLog(@"Received Confirm Frame Select");
                if (self.lastSendMsgTimestamp == nil) {
                    [self.photoFrameDelegate receivedPhotoFrameConfirmRequest:message[kPhotoFrameIndexPath]];
                } else if ([message[kPhotoFrameConfirmTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                    [self.photoFrameDelegate interruptedPhotoFrameConfirm];
                    [self.photoFrameDelegate receivedPhotoFrameConfirmRequest:message[kPhotoFrameIndexPath]];
                }
                break;
            case vDataTypeScreenSize:
                NSLog(@"Received Screen Size");
                [self calculateScreenRatio:[message[kScreenSize] CGSizeValue]];
                break;
            case vDataTypePhotoFrameConfirmedAck:
                NSLog(@"Received Confirm Ack Frame Select");
                self.lastSendMsgTimestamp = nil;
                [self.photoFrameDelegate receivedPhotoFrameConfirmAck:[message[kPhotoFrameConfirmedAck] boolValue]];
                break;
        }
    }
    
    if (self.photoFrameDataDelegate) {
        switch (dataType) {
            case vDataTypePhotoFrameSelected:
                NSLog(@"Received Selected Frame Index");
                if (self.lastSendMsgTimestamp) {
                    break;
                }
                
                if (self.messageQueueEnabled) {
                    [self putMessage:message];
                } else {
                    [self.photoFrameDataDelegate receivedPhotoFrameSelected:message[kPhotoFrameIndexPath]];
                }
                break;
        }
    }
    
    if (self.photoDataDelegate) {
        switch (dataType) {
            case vDataTypePhotoEdit:
                NSLog(@"Received Edit Photo");
                if (self.lastSendMsgTimestamp == nil) {
                    [self.photoDataDelegate receivedPhotoEditing:message[kPhotoIndexPath]];
                    break;
                }
                
                if (self.selectedPhotoFrameIndex.item == ((NSIndexPath *)message[kPhotoIndexPath]).item) {
                    if ([message[kPhotoEditTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                        [self.photoDataDelegate interruptedPhotoEditing:message[kPhotoIndexPath]];
                        [self.photoDataDelegate receivedPhotoEditing:message[kPhotoIndexPath]];
                        
                        self.lastSendMsgTimestamp = nil;
                        self.selectedPhotoFrameIndex = nil;
                    }
                } else {
                    [self.photoDataDelegate receivedPhotoEditing:message[kPhotoIndexPath]];
                }
                
                break;
            case vDataTypePhotoEditCanceled:
                NSLog(@"Received Edit Photo Canceled");
                [self.photoDataDelegate receivedPhotoEditingCancelled:message[kPhotoIndexPath]];
                break;
            case vDataTypePhotoInsertedAck:
                NSLog(@"Received Insert Photo Ack");
                [self.photoDataDelegate receivedPhotoInsertAck:message[kPhotoIndexPath]
                                                                   ack:[message[kPhotoInsertedAck] boolValue]];
                break;
            case vDataTypePhotoDeleted:
                NSLog(@"Received Delete Photo");
                [self.photoDataDelegate receivedPhotoDeleted:message[kPhotoIndexPath]];
                break;
        }
    }
    
    if (self.decorateDataDelegate) {
        switch (dataType) {
            case vDataTypeDecorateEdit:
                NSLog(@"Received Edit Decorate Data");
                if (self.lastSendMsgTimestamp == nil) {
                    [self.decorateDataDelegate receivedDecorateDataEditing:message[kDecorateUUID]];
                    break;
                }
                
                if ([self.selectedDecorateDataUUID.UUIDString isEqualToString:((NSUUID *)message[kDecorateUUID]).UUIDString]) {
                    if ([message[kDecorateEditTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                        [self.decorateDataDelegate interruptedDecorateDataEditing:message[kDecorateUUID]];
                        [self.decorateDataDelegate receivedDecorateDataEditing:message[kDecorateUUID]];
                        
                        self.lastSendMsgTimestamp = nil;
                        self.selectedDecorateDataUUID = nil;
                    }
                } else {
                    [self.decorateDataDelegate receivedDecorateDataEditing:message[kDecorateUUID]];
                }
                
                break;
            case vDataTypeDecorateEditCanceled:
                NSLog(@"Received Edit Cancel Decorate Data");
                [self.decorateDataDelegate receivedDecorateDataEditCancelled:message[kDecorateUUID]];
                break;
            case vDataTypeDecorateInserted:
                NSLog(@"Received Insert Decorate Data");
                [self.decorateDataDelegate receivedDecorateDataInsert:message[kDecorateInsertedData]];
                break;
            case vDataTypeDecorateUpdated:
                NSLog(@"Received Update Decorate Data");
                [self.decorateDataDelegate receivedDecorateDataUpdate:message[kDecorateUUID]
                                                              frame:[message[kDEcorateUpdatedFrame] CGRectValue]];
                break;
            case vDataTypeDecorateDeleted:
                NSLog(@"Received Delete Decorate Data");
                [self.decorateDataDelegate receivedDecorateDataDeleted:message[kDecorateUUID]];
                break;
        }
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    if (!self.photoDataDelegate) {
        return;
    }
    
    NSArray *array = [resourceName componentsSeparatedByString:SperatorImageName];
    
    if (array == nil || array.count != 2) {
        return;
    }
    
    NSInteger photoFrameIndex = [array[0] integerValue];
    NSString *fileType = array[1];
    
    if ([fileType isEqualToString:PostfixImageCropped]) {
        NSLog(@"Receive Start Insert Photo");
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:photoFrameIndex inSection:0];
        [self.photoDataDelegate receivedPhotoInsert:indexPath type:fileType url:nil];
    }
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    if (!self.photoDataDelegate) {
        return;
    }
    
    NSArray *array = [resourceName componentsSeparatedByString:SperatorImageName];
    
    if (array == nil || array.count != 2) {
        return;
    }
    
    NSInteger photoFrameIndex = [array[0] integerValue];
    NSString *fileType = array[1];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:photoFrameIndex inSection:0];
    [self.photoDataDelegate receivedPhotoInsert:indexPath type:fileType url:localURL];
    
    if ([fileType isEqualToString:PostfixImageFullscreen]) {
        NSLog(@"Receive Finish Insert Photo");
        [self sendMessage:[MessageFactory messageGeneratePhotoInsertCompleted:indexPath success:YES]];
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {

}


#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

}

@end
