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
    if (message[kDataType] == nil)
        return;
    
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
    if (self.sessionConnectDelegate) {
        if (state == MCSessionStateConnected) {
            NSLog(@"Session Connected");
            [self.sessionConnectDelegate receivedPeerConnected];
        } else if (state == MCSessionStateNotConnected) {
            NSLog(@"Session Disconnected");
            self.lastSendMsgTimestamp = nil;
            [self.sessionConnectDelegate receivedPeerDisconnected];
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *message = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSInteger dataType = [message[kDataType] integerValue];
    
    if (self.photoFrameSelectDelegate) {
        switch (dataType) {
            case vDataTypeScreenSize:
                _connectedPeerScreenSize = [message[kScreenSize] CGRectValue];
                NSLog(@"Received Screen Size : x(%f) y(%f) w(%f) h(%f)", _connectedPeerScreenSize.origin.x, _connectedPeerScreenSize.origin.y, _connectedPeerScreenSize.size.width, _connectedPeerScreenSize.size.height);
                break;
            case vDataTypePhotoFrameSelected:
                NSLog(@"Received Selected Frame Index");
                if (self.lastSendMsgTimestamp)
                    break;
                
                if (self.messageQueueEnabled) {
                    //메시지 큐에 데이터를 저장하고, 노티피케이션으로 전파하지 않는다.
                    //여기서는 "마지막 메시지"만 파악하면 되므로, 동기화 큐에 메시지가 하나만 있도록 유지한다. 차후에 1:n 통신을 하면, peer당 메시지 하나로 제한하는 방식으로 가면 될 것 같다.
                    //마지막 메시지 하나만을 동기화 큐에 유지하기 위해, 매번 동기화 큐를 초기화하고 마지막 메시지를 저장한다.
                    //어차피 상대방이 액자선택에 진입하는 시점과 본인이 액자선택에 진입하는 시점이 달라서 발생하는 동기화 오류는, 그 시간 폭이 매우 작다고 보기 때문에... 성능상 큰 문제가 있을 것 같지는 않다.
                    [self clearMessageQueue];
                    
                    //전달받은 객체가 NSNull인지 확인하고, 아닐 경우에만 메시지큐에 메시지를 저장한다.
                    if (![message[kPhotoFrameIndex] isKindOfClass:[NSNull class]]) {
                        [self putMessage:message];
                    }
                } else {
                    if ([message[kPhotoFrameIndex] isKindOfClass:[NSNull class]]) {
                        [self.photoFrameSelectDelegate receivedPhotoFrameSelected:nil];
                    } else {
                        [self.photoFrameSelectDelegate receivedPhotoFrameSelected:message[kPhotoFrameIndex]];
                    }
                }
                break;
            case vDataTypePhotoFrameRequestConfirm:
                NSLog(@"Received Confirm Frame Select");
                //버그가 관측된 바 있다. 재현이 잘 안되서 그렇지...
                //버그 상황에 대해서 재현을 더 시도해봐야 한다. 2016.08.10
                if (self.lastSendMsgTimestamp == nil) {
                    [self.photoFrameSelectDelegate receivedPhotoFrameRequestConfirm:message[kPhotoFrameIndex]];
                } else if ([message[kPhotoFrameConfirmTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                    [self.photoFrameSelectDelegate interruptedPhotoFrameConfirmProgress];
                    [self.photoFrameSelectDelegate receivedPhotoFrameRequestConfirm:message[kPhotoFrameIndex]];
                }
                
                break;
            case vDataTypePhotoFrameConfirmedAck:
                NSLog(@"Received Confirm Ack Frame Select");
                self.lastSendMsgTimestamp = nil;
                [self.photoFrameSelectDelegate receivedPhotoFrameConfirmAck:[message[kPhotoFrameConfirmedAck] boolValue]];
                break;
        }
    }
    
    if (self.photoEditorDelegate) {
        switch (dataType) {
            case vDataTypeEditorPhotoEdit:
                NSLog(@"Received Edit Photo");
                if (self.lastSendMsgTimestamp == nil) {
                    [self.photoEditorDelegate receivedEditorPhotoEditing:message[kEditorPhotoIndexPath]];
                    break;
                }
                
                if (self.selectedPhotoFrameIndex.item == ((NSIndexPath *)message[kEditorPhotoIndexPath]).item) {
                    if ([message[kEditorPhotoEditTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                        [self.photoEditorDelegate interruptedEditorPhotoEditing:message[kEditorPhotoIndexPath]];
                        [self.photoEditorDelegate receivedEditorPhotoEditing:message[kEditorPhotoIndexPath]];
                        
                        self.lastSendMsgTimestamp = nil;
                        self.selectedPhotoFrameIndex = nil;
                    }
                } else {
                    [self.photoEditorDelegate receivedEditorPhotoEditing:message[kEditorPhotoIndexPath]];
                }
                
                break;
            case vDataTypeEditorPhotoEditCanceled:
                NSLog(@"Received Edit Photo Canceled");
                [self.photoEditorDelegate receivedEditorPhotoEditingCancelled:message[kEditorPhotoIndexPath]];
                break;
            case vDataTypeEditorPhotoInsertedAck:
                NSLog(@"Received Insert Photo Ack");
                [self.photoEditorDelegate receivedEditorPhotoInsertAck:message[kEditorPhotoIndexPath]
                                                                   ack:[message[kEditorPhotoInsertedAck] boolValue]];
                break;
            case vDataTypeEditorPhotoDeleted:
                NSLog(@"Received Delete Photo");
                [self.photoEditorDelegate receivedEditorPhotoDeleted:message[kEditorPhotoIndexPath]];
                break;
            case vDataTypeEditorDecorateEdit:
                NSLog(@"Received Edit Decorate Data");
                if (self.lastSendMsgTimestamp == nil) {
                    [self.photoEditorDelegate receivedEditorDecorateDataEditing:[message[kEditorDecorateIndex] integerValue]];
                    break;
                }
                
                if ([self.selectedDecorateDataIndex integerValue] == [message[kEditorDecorateIndex] integerValue]) {
                    if ([message[kEditorDecorateEditTimestamp] compare:self.lastSendMsgTimestamp] == NSOrderedAscending) {
                        [self.photoEditorDelegate interruptedEditorDecorateDataEditing:[message[kEditorDecorateIndex] integerValue]];
                        [self.photoEditorDelegate receivedEditorDecorateDataEditing:[message[kEditorDecorateIndex] integerValue]];
                        
                        self.lastSendMsgTimestamp = nil;
                        self.selectedDecorateDataIndex = nil;
                    }
                } else {
                    [self.photoEditorDelegate receivedEditorDecorateDataEditing:[message[kEditorDecorateIndex] integerValue]];
                }
                
                break;
            case vDataTypeEditorDecorateEditCanceled:
                NSLog(@"Received Edit Cancel Decorate Data");
                [self.photoEditorDelegate receivedEditorDecorateDataEditCancelled:[message[kEditorDecorateIndex] integerValue]];
                break;
            case vDataTypeEditorDecorateInserted:
                NSLog(@"Received Insert Decorate Data");
                [self.photoEditorDelegate receivedEditorDecorateDataInsert:message[kEditorDecorateInsertedData]
                                                                   timestamp:message[kEditorDecorateInsertedTimestamp]];
                break;
            case vDataTypeEditorDecorateUpdateMoved:
                NSLog(@"Received Update Moved Decorate Data");
                [self.photoEditorDelegate receivedEditorDecorateDataMoved:[message[kEditorDecorateIndex] integerValue]
                                                               movedPoint:[message[kEditorDecorateUpdateMovedPoint] CGPointValue]];
                break;
            case vDataTypeEditorDecorateUpdateResized:
                NSLog(@"Received Update Resized Decorate Data");
                [self.photoEditorDelegate receivedEditorDecorateDataResized:[message[kEditorDecorateIndex] integerValue]
                                                                resizedRect:[message[kEditorDecorateUpdateResizedRect] CGRectValue]];
                break;
            case vDataTypeEditorDecorateUpdateRotated:
                NSLog(@"Received Update Rotated Decorate Data");
                [self.photoEditorDelegate receivedEditorDecorateDataRotated:[message[kEditorDecorateIndex] integerValue]
                                                               rotatedAngle:[message[kEditorDecorateUpdateRotatedAngle] floatValue]];
                break;
            case vDataTypeEditorDecorateUpdateZOrder:
                NSLog(@"Received Update Z Order Decorate Data");
                [self.photoEditorDelegate receivedEditorDecorateDataZOrderChanged:[message[kEditorDecorateIndex] integerValue]];
                break;
            case vDataTypeEditorDecorateDeleted:
                NSLog(@"Received Delete Decorate Data");
                [self.photoEditorDelegate receivedEditorDecorateDataDeleted:message[kEditorDecorateDeleteTimestamp]];
                break;
        }
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSArray *array = [resourceName componentsSeparatedByString:SperatorImageName];
    
    if (array == nil || array.count != 2)
        return;
    
    NSInteger photoFrameIndex = [array[0] integerValue];
    NSString *fileType = array[1];
    
    if ([fileType isEqualToString:PostfixImageCropped]) {
        NSLog(@"Receive Start Insert Photo");
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:photoFrameIndex inSection:0];
        [self.photoEditorDelegate receivedEditorPhotoInsert:indexPath type:fileType url:nil];
    }
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    NSArray *array = [resourceName componentsSeparatedByString:SperatorImageName];
    
    if (array == nil || array.count != 2)
        return;
    
    NSInteger photoFrameIndex = [array[0] integerValue];
    NSString *fileType = array[1];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:photoFrameIndex inSection:0];
    [self.photoEditorDelegate receivedEditorPhotoInsert:indexPath type:fileType url:localURL];
    
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
