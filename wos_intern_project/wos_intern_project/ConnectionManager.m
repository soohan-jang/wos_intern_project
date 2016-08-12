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

@interface ConnectionManager ()

@property (nonatomic, strong) CBCentralManager *bluetoothManager;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *messageQueue;
@property (nonatomic, strong) NSNumber *lastSendMsgTimestamp;
@property (nonatomic, strong) NSIndexPath *selectedPhotoFrameIndex;
@property (nonatomic, strong) NSNumber *selectedDecorateDataIndex;

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
        
        _ownScreenSize = [[UIScreen mainScreen] bounds];
        
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
        case vDataTypeEditorPhotoEdit:
            self.lastSendMsgTimestamp = message[kEditorPhotoEditTimestamp];
            self.selectedPhotoFrameIndex = message[kEditorPhotoIndexPath];
            break;
        case vDataTypeEditorDecorateEdit:
            self.lastSendMsgTimestamp = message[kEditorDecorateEditTimestamp];
            self.selectedDecorateDataIndex = message[kEditorDecorateIndex];
            break;
        default:
            self.lastSendMsgTimestamp = nil;
            self.selectedPhotoFrameIndex = nil;
            self.selectedDecorateDataIndex = nil;
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
    [self.ownSession disconnect];
    [self setMessageQueueEnabled:NO];
    [self clearMessageQueue];
}

- (void)clear {
    _ownPeerId = nil;
    _ownSession.delegate = nil;
    _ownSession = nil;
    
    _ownScreenSize = CGRectZero;
    _connectedPeerScreenSize = CGRectZero;
    
    self.bluetoothManager.delegate = nil;
    self.bluetoothManager = nil;
    
    self.messageQueue = nil;
}


#pragma mark - MessagePool Methods

- (void)putMessage:(NSDictionary *)message {
    if (self.messageQueue == nil) {
        self.messageQueue = [[NSMutableArray alloc] init];
    }
    
    //    if ([message[KEY_DATA_TYPE] integerValue] == VALUE_DATA_TYPE_EDITOR_DRAWING_DELETE) {
    //        DrawingObject *deletedObject = (DrawingObject *)message[KEY_EDITOR_DRAWING_DELETE_DATA];
    //        for (DrawingObject *object in _messageQueue) {
    //            if ([deletedObject getID] == [object getID]) {
    //                [_messageQueue removeObject:object];
    //            }
    //        }
    //    }
    
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
        if (state == MCSessionStateConnected) {
            NSLog(@"Session Connected");
            [self.sessionDelegate receivedPeerConnected];
        } else if (state == MCSessionStateNotConnected) {
            NSLog(@"Session Disconnected");
            self.lastSendMsgTimestamp = nil;
            [self.sessionDelegate receivedPeerDisconnected];
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *message = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSInteger dataType = [message[kDataType] integerValue];
    
    if (self.photoFrameControlDelegate) {
        switch (dataType) {
            case vDataTypeScreenSize:
                _connectedPeerScreenSize = [message[kScreenSize] CGRectValue];
                NSLog(@"Received Screen Size : x(%f) y(%f) w(%f) h(%f)", _connectedPeerScreenSize.origin.x, _connectedPeerScreenSize.origin.y, _connectedPeerScreenSize.size.width, _connectedPeerScreenSize.size.height);
                break;
            case vDataTypePhotoFrameConfirmedAck:
                NSLog(@"Received Confirm Ack Frame Select");
                self.lastSendMsgTimestamp = nil;
                [self.photoFrameControlDelegate receivedPhotoFrameConfirmAck:[message[kPhotoFrameConfirmedAck] boolValue]];
                break;
        }
    }
    
    if (self.photoFrameDataDelegate && self.photoFrameControlDelegate) {
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
            case vDataTypePhotoFrameRequestConfirm:
                NSLog(@"Received Confirm Frame Select");
                //버그가 관측된 바 있다. 재현이 잘 안되서 그렇지...
                //버그 상황에 대해서 재현을 더 시도해봐야 한다. 2016.08.10
                if (self.lastSendMsgTimestamp == nil) {
                    [self.photoFrameDataDelegate receivedPhotoFrameRequestConfirm:message[kPhotoFrameIndexPath]];
                } else if ([message[kPhotoFrameConfirmTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                    [self.photoFrameControlDelegate interruptedPhotoFrameConfirmProgress];
                    [self.photoFrameDataDelegate receivedPhotoFrameRequestConfirm:message[kPhotoFrameIndexPath]];
                }
                
                break;
        }
    }
    
    if (self.photoDataDelegate) {
        switch (dataType) {
            case vDataTypeEditorPhotoEdit:
                NSLog(@"Received Edit Photo");
                if (self.lastSendMsgTimestamp == nil) {
                    [self.photoDataDelegate receivedEditorPhotoEditing:message[kEditorPhotoIndexPath]];
                    break;
                }
                
                if (self.selectedPhotoFrameIndex.item == ((NSIndexPath *)message[kEditorPhotoIndexPath]).item) {
                    if ([message[kEditorPhotoEditTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                        [self.photoDataDelegate interruptedEditorPhotoEditing:message[kEditorPhotoIndexPath]];
                        [self.photoDataDelegate receivedEditorPhotoEditing:message[kEditorPhotoIndexPath]];
                        
                        self.lastSendMsgTimestamp = nil;
                        self.selectedPhotoFrameIndex = nil;
                    }
                } else {
                    [self.photoDataDelegate receivedEditorPhotoEditing:message[kEditorPhotoIndexPath]];
                }
                
                break;
            case vDataTypeEditorPhotoEditCanceled:
                NSLog(@"Received Edit Photo Canceled");
                [self.photoDataDelegate receivedEditorPhotoEditingCancelled:message[kEditorPhotoIndexPath]];
                break;
            case vDataTypeEditorPhotoInsertedAck:
                NSLog(@"Received Insert Photo Ack");
                [self.photoDataDelegate receivedEditorPhotoInsertAck:message[kEditorPhotoIndexPath]
                                                                   ack:[message[kEditorPhotoInsertedAck] boolValue]];
                break;
            case vDataTypeEditorPhotoDeleted:
                NSLog(@"Received Delete Photo");
                [self.photoDataDelegate receivedEditorPhotoDeleted:message[kEditorPhotoIndexPath]];
                break;
        }
    }
    
    if (self.decorateDataDelegate) {
        switch (dataType) {
            case vDataTypeEditorDecorateEdit:
                NSLog(@"Received Edit Decorate Data");
                if (self.lastSendMsgTimestamp == nil) {
                    [self.decorateDataDelegate receivedEditorDecorateDataEditing:[message[kEditorDecorateIndex] integerValue]];
                    break;
                }
                
                if ([self.selectedDecorateDataIndex integerValue] == [message[kEditorDecorateIndex] integerValue]) {
                    if ([message[kEditorDecorateEditTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                        [self.decorateDataDelegate interruptedEditorDecorateDataEditing];
                        [self.decorateDataDelegate receivedEditorDecorateDataEditing:[message[kEditorDecorateIndex] integerValue]];
                        
                        self.lastSendMsgTimestamp = nil;
                        self.selectedDecorateDataIndex = nil;
                    }
                } else {
                    [self.decorateDataDelegate receivedEditorDecorateDataEditing:[message[kEditorDecorateIndex] integerValue]];
                }
                
                break;
            case vDataTypeEditorDecorateEditCanceled:
                NSLog(@"Received Edit Cancel Decorate Data");
                [self.decorateDataDelegate receivedEditorDecorateDataEditCancelled:[message[kEditorDecorateIndex] integerValue]];
                break;
            case vDataTypeEditorDecorateInserted:
                NSLog(@"Received Insert Decorate Data");
                [self.decorateDataDelegate receivedEditorDecorateDataInsert:message[kEditorDecorateInsertedData]
                                                                 timestamp:message[kEditorDecorateInsertedTimestamp]];
                break;
            case vDataTypeEditorDecorateUpdateMoved:
                NSLog(@"Received Update Moved Decorate Data");
                [self.decorateDataDelegate receivedEditorDecorateDataMoved:[message[kEditorDecorateIndex] integerValue]
                                                               movedPoint:[message[kEditorDecorateUpdateMovedPoint] CGPointValue]];
                break;
            case vDataTypeEditorDecorateUpdateResized:
                NSLog(@"Received Update Resized Decorate Data");
                [self.decorateDataDelegate receivedEditorDecorateDataResized:[message[kEditorDecorateIndex] integerValue]
                                                                resizedRect:[message[kEditorDecorateUpdateResizedRect] CGRectValue]];
                break;
            case vDataTypeEditorDecorateUpdateRotated:
                NSLog(@"Received Update Rotated Decorate Data");
                [self.decorateDataDelegate receivedEditorDecorateDataRotated:[message[kEditorDecorateIndex] integerValue]
                                                               rotatedAngle:[message[kEditorDecorateUpdateRotatedAngle] floatValue]];
                break;
            case vDataTypeEditorDecorateUpdateZOrder:
                NSLog(@"Received Update Z Order Decorate Data");
                [self.decorateDataDelegate receivedEditorDecorateDataZOrderChanged:[message[kEditorDecorateIndex] integerValue]];
                break;
            case vDataTypeEditorDecorateDeleted:
                NSLog(@"Received Delete Decorate Data");
                [self.decorateDataDelegate receivedEditorDecorateDataDeleted:message[kEditorDecorateDeleteTimestamp]];
                break;
        }
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSArray *array = [resourceName componentsSeparatedByString:SperatorImageName];
    
    if (array == nil || array.count != 2) {
        return;
    }
    
    NSInteger photoFrameIndex = [array[0] integerValue];
    NSString *fileType = array[1];
    
    if ([fileType isEqualToString:PostfixImageCropped]) {
        NSLog(@"Receive Start Insert Photo");
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:photoFrameIndex inSection:0];
        [self.photoDataDelegate receivedEditorPhotoInsert:indexPath type:fileType url:nil];
    }
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    NSArray *array = [resourceName componentsSeparatedByString:SperatorImageName];
    
    if (array == nil || array.count != 2) {
        return;
    }
    
    NSInteger photoFrameIndex = [array[0] integerValue];
    NSString *fileType = array[1];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:photoFrameIndex inSection:0];
    [self.photoDataDelegate receivedEditorPhotoInsert:indexPath type:fileType url:localURL];
    
    if ([fileType isEqualToString:PostfixImageFullscreen]) {
        NSLog(@"Receive Finish Insert Photo");
        [self sendMessage:[MessageFactory MessageGeneratePhotoInsertCompleted:indexPath success:YES]];
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {

}


#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

}

@end
