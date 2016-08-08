//
//  ConnectionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "ConnectionManager.h"

@interface ConnectionManager ()

@property (nonatomic, strong) CBCentralManager *bluetoothManager;

/** 연결된 상대방 정보 **/
//원래 이것도 배열로 구성해서 각 피어에 해당하는 셋을 맞춰야되는데, 당장은 1:1 통신을 하므로...
//@property (nonatomic, strong, readonly) NSMutableArray *connectedPeerIds;
@property (nonatomic, assign) CGFloat connectedPeerScreenWidth, connectedPeerScreenHeight;

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
        
        CGRect mainScreenRect = [[UIScreen mainScreen] bounds];
        _ownScreenWidth = mainScreenRect.size.width;
        _ownScreenHeight = mainScreenRect.size.height;
        
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
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

- (void)sendData:(NSDictionary *)data {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:data];
    [self.ownSession sendData:archivedData toPeers:self.ownSession.connectedPeers withMode:MCSessionSendDataReliable error:nil];
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
}

- (void)clear {
    _ownPeerId = nil;
    _ownSession.delegate = nil;
    _ownSession = nil;
    
    _ownScreenWidth = 0;
    _ownScreenHeight = 0;
    
    self.bluetoothManager.delegate = nil;
    self.bluetoothManager = nil;
}


#pragma mark - MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if (self.sessionConnectDelegate) {
        if (state == MCSessionStateConnected) {
            NSLog(@"Session Connected");
            [self.sessionConnectDelegate receivedPeerConnected];
        } else if (state == MCSessionStateNotConnected) {
            NSLog(@"Session Disconnected");
            [self.sessionConnectDelegate receivedPeerDisconnected];
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *receivedData = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSInteger dataType = [receivedData[kDataType] integerValue];
    MessageSyncManager *messageSyncManager = [MessageSyncManager sharedInstance];
    
    if (self.photoFrameSelectDelegate) {
        switch (dataType) {
            case vDataTypeScreenSize:
                self.connectedPeerScreenWidth = [receivedData[kScreenWidth] floatValue];
                self.connectedPeerScreenHeight = [receivedData[kScreenHeight] floatValue];
                NSLog(@"Received Screen Size : width(%f), height(%f)", self.connectedPeerScreenWidth, self.connectedPeerScreenHeight);
                break;
            case vDataTypePhotoFrameSelected:
                NSLog(@"Received Selected Frame Index");
                if ([messageSyncManager isMessageQueueEnabled]) {
                    //메시지 큐에 데이터를 저장하고, 노티피케이션으로 전파하지 않는다.
                    //여기서는 "마지막 메시지"만 파악하면 되므로, 동기화 큐에 메시지가 하나만 있도록 유지한다. 차후에 1:n 통신을 하면, peer당 메시지 하나로 제한하는 방식으로 가면 될 것 같다.
                    //마지막 메시지 하나만을 동기화 큐에 유지하기 위해, 매번 동기화 큐를 초기화하고 마지막 메시지를 저장한다.
                    //어차피 상대방이 액자선택에 진입하는 시점과 본인이 액자선택에 진입하는 시점이 달라서 발생하는 동기화 오류는, 그 시간 폭이 매우 작다고 보기 때문에... 성능상 큰 문제가 있을 것 같지는 않다.
                    [messageSyncManager clearMessageQueue];
                    
                    //전달받은 객체가 NSNull인지 확인하고, 아닐 경우에만 메시지큐에 메시지를 저장한다.
                    if (![receivedData[kPhotoFrameSelected] isKindOfClass:[NSNull class]]) {
                        [messageSyncManager putMessage:receivedData];
                    }
                } else {
                    if ([receivedData[kPhotoFrameSelected] isKindOfClass:[NSNull class]]) {
                        [self.photoFrameSelectDelegate receivedPhotoFrameSelected:nil];
                    } else {
                        [self.photoFrameSelectDelegate receivedPhotoFrameSelected:receivedData[kPhotoFrameSelected]];
                    }
                }
                break;
            case vDataTypePhotoFrameConfirm:
                NSLog(@"Received Confirm Frame Select");
                [self.photoFrameSelectDelegate receivedPhotoFrameRequestConfirm];
                break;
            case vDataTypePhotoFrameConfirmAck:
                NSLog(@"Received Confirm Ack Frame Select");
                [self.photoFrameSelectDelegate receivedPhotoFrameConfirmAck:[receivedData[kPhotoFrameSelectedConfirmAck] boolValue]];
                break;
        }
    }
    
    if (self.photoEditorDelegate) {
        switch (dataType) {
            case vDataTypeEditorPhotoInsertAck:
                NSLog(@"Received Insert Photo Ack");
                [self.photoEditorDelegate receivedEditorPhotoInsertAck:[receivedData[kEditorPhotoInsertIndex] integerValue]
                                                                   ack:[receivedData[kEditorPhotoInsertAck] boolValue]];
                break;
            case vDataTypeEditorPhotoEdit:
                NSLog(@"Received Edit Photo");
                [self.photoEditorDelegate receivedEditorPhotoEditing:[receivedData[kEditorPhotoEditIndex] integerValue]];
                break;
            case vDataTypeEditorPhotoEditCancel:
                NSLog(@"Received Edit Photo Canceled");
                [self.photoEditorDelegate receivedEditorPhotoEditingCancelled:[receivedData[kEditorPhotoEditIndex] integerValue]];
                break;
            case vDataTypeEditorPhotoDelete:
                NSLog(@"Received Delete Photo");
                [self.photoEditorDelegate receivedEditorPhotoDelete:[receivedData[kEditorPhotoDeleteIndex] integerValue]];
                break;
            case vDataTypeEditorDrawingEdit:
                NSLog(@"Received Edit Drawing Object");
                [self.photoEditorDelegate receivedEditorDecorateObjectEditing:receivedData[kEditorDrawingEditID]];
                break;
            case vDataTypeEditorDrawingEditCancel:
                NSLog(@"Received Edit Cancel Drawing Object");
                [self.photoEditorDelegate receivedEditorDecorateObjectEditCancelled:receivedData[kEditorDrawingEditID]];
                break;
            case vDataTypeEditorDrawingInsert:
                NSLog(@"Received Insert Drawing Object");
                [self.photoEditorDelegate receivedEditorDecorateObjectInsert:receivedData[kEditorDrawingInsertData]
                                                                   timestamp:receivedData[kEditorDrawingInsertTimestamp]];
                break;
            case vDataTypeEditorDrawingUpdateMoved:
                NSLog(@"Received Update Moved Drawing Object");
                [self.photoEditorDelegate receivedEditorDecorateObjectMoved:receivedData[kEditorDrawingUpdateID]
                                                                    originX:[receivedData[kEditorDrawingUpdateMovedX] floatValue]
                                                                    originY:[receivedData[kEditorDrawingUpdateMovedY] floatValue]];
                break;
            case vDataTypeEditorDrawingUpdateResized:
                NSLog(@"Received Update Resized Drawing Object");
                [self.photoEditorDelegate receivedEditorDecorateObjectResized:receivedData[kEditorDrawingUpdateID]
                                                                      originX:[receivedData[kEditorDrawingUpdateResizedX] floatValue]
                                                                      originY:[receivedData[kEditorDrawingUpdateResizedY] floatValue]
                                                                        width:[receivedData[kEditorDrawingUpdateResizedWidth] floatValue]
                                                                       height:[receivedData[kEditorDrawingUpdateResizedHeight] floatValue]];
                break;
            case vDataTypeEditorDrawingUpdateRotated:
                NSLog(@"Received Update Rotated Drawing Object");
                [self.photoEditorDelegate receivedEditorDecorateObjectRotated:receivedData[kEditorDrawingUpdateID]
                                                                        angle:[receivedData[kEditorDrawingUpdateRotatedAngle] floatValue]];
                break;
            case vDataTypeEditorDrawingUpdateZOrder:
                NSLog(@"Received Update Z Order Drawing Object");
                [self.photoEditorDelegate receivedEditorDecorateObjectZOrderChanged:receivedData[kEditorDrawingUpdateID]];
                break;
            case vDataTypeEditorDrawingDelete:
                NSLog(@"Received Delete Drawing Object");
                [self.photoEditorDelegate receivedEditorDecorateObjectDelete:receivedData[kEditorDrawingDeleteID]];
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
        [self.photoEditorDelegate receivedEditorPhotoInsert:photoFrameIndex type:fileType url:nil];
    }
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    NSArray *array = [resourceName componentsSeparatedByString:SperatorImageName];
    
    if (array == nil || array.count != 2)
        return;
    
    NSInteger photoFrameIndex = [array[0] integerValue];
    NSString *fileType = array[1];
    
    [self.photoEditorDelegate receivedEditorPhotoInsert:photoFrameIndex type:fileType url:localURL];
    
    if ([fileType isEqualToString:PostfixImageFullscreen]) {
        NSLog(@"Receive Finish Insert Photo");
        NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoInsertAck),
                                   kEditorPhotoInsertAck: @YES,
                                   kEditorPhotoEditIndex: @(photoFrameIndex)};
        
        [self sendData:sendData];
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {

}


#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

}

@end
