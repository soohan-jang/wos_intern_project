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

@end

@implementation ConnectionManager

//@synthesize ownPeerId, ownSession;
//@synthesize browserViewController, advertiser;
//@synthesize ownScreenWidth, ownScreenHeight;
//@synthesize connectedPeerScreenWidth, connectedPeerScreenHeight;

+ (ConnectionManager *)sharedInstance {
    static ConnectionManager *instance = nil;
    
    @synchronized (self) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

- (void)initInstanceProperties:(NSString *)deviceName withScreenWidthSize:(CGFloat)width withScreenHeightSize:(CGFloat)height {
    _ownPeerId = [[MCPeerID alloc] initWithDisplayName:deviceName];
    _ownSession = [[MCSession alloc] initWithPeer:_ownPeerId];
    _ownSession.delegate = self;
    
    _ownScreenWidth = @(width);
    _ownScreenHeight = @(height);
    
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (NSInteger)getBluetoothState {
    return self.bluetoothManager.state;
}

- (void)sendData:(NSData *)sendData {
    [self.ownSession sendData:sendData toPeers:self.ownSession.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}

- (void)sendPhotoDataWithFilename:(NSString *)filename withFullscreenImageURL:(NSURL *)fullscreenImageURL withCroppedImageURL:(NSURL *)croppedImageURL withIndex:(NSInteger)index {
    for (MCPeerID *peer in self.ownSession.connectedPeers) {
        NSString *croppedImageResourceName = [NSString stringWithFormat:@"%@+_cropped", [@(index) stringValue]];
        [self.ownSession sendResourceAtURL:croppedImageURL withName:croppedImageResourceName toPeer:peer withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            } else {
                NSString *fullscreenImageResourceName = [NSString stringWithFormat:@"%@+_fullscreen", [@(index) stringValue]];
                
                [self.ownSession sendResourceAtURL:fullscreenImageURL withName:fullscreenImageResourceName toPeer:peer withCompletionHandler:^(NSError *error) {
                    if (error) {
                        NSLog(@"%@", error.localizedDescription);
                    }
                    
                    //파일 전송이 종료되었으므로, 파일 전송을 위해 임시저장했던 이미지 파일을 삭제한다.
                    [[ImageUtility sharedInstance] removeTempImageWithFilename:filename];
                }];
            }
        }];
    }
}

- (void)disconnectSession {
    [self.ownSession disconnect];
}


#pragma mark - MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    //연결이 완료되면 연결된 peerId를 배열에 저장하고, 상대방에게 자신의 화면크기 정보를 보낸다.
    if (state == MCSessionStateConnected) {
        NSLog(@"Session Connected");
        if ([self.delegate respondsToSelector:@selector(receivedPeerConnected)]) {
            [self.delegate receivedPeerConnected];
        }
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"Session Disconnected");
        if ([self.delegate respondsToSelector:@selector(receivedPeerDisconnected)]) {
            [self.delegate receivedPeerDisconnected];
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *receivedData = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSInteger dataType = [(NSNumber *)receivedData[KEY_DATA_TYPE] integerValue];
    
    if (dataType == VALUE_DATA_TYPE_SCREEN_SIZE) {
        _connectedPeerScreenWidth = receivedData[KEY_SCREEN_SIZE_WIDTH];
        _connectedPeerScreenHeight = receivedData[KEY_SCREEN_SIZE_HEIGHT];
        NSLog(@"Received Screen Size : width(%f), height(%f)", [_connectedPeerScreenWidth floatValue], [_connectedPeerScreenHeight floatValue]);
    } else if (dataType == VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED) {
        NSLog(@"Received Selected Frame Index");
        if ([[MessageSyncManager sharedInstance] isMessageQueueEnabled]) {
            //메시지 큐에 데이터를 저장하고, 노티피케이션으로 전파하지 않는다.
            //여기서는 "마지막 메시지"만 파악하면 되므로, 동기화 큐에 메시지가 하나만 있도록 유지한다. 차후에 1:n 통신을 하면, peer당 메시지 하나로 제한하는 방식으로 가면 될 것 같다.
            //마지막 메시지 하나만을 동기화 큐에 유지하기 위해, 매번 동기화 큐를 초기화하고 마지막 메시지를 저장한다.
            //어차피 상대방이 액자선택에 진입하는 시점과 본인이 액자선택에 진입하는 시점이 달라서 발생하는 동기화 오류는, 그 시간 폭이 매우 작다고 보기 때문에... 성능상 큰 문제가 있을 것 같지는 않다.
            [[MessageSyncManager sharedInstance] clearMessageQueue];
            
            //전달받은 객체가 NSNull인지 확인하고, 아닐 경우에만 메시지큐에 메시지를 저장한다.
            if (![receivedData[KEY_PHOTO_FRAME_SELECTED] isEqual:[NSNull null]]) {
                [[MessageSyncManager sharedInstance] putMessage:receivedData];
                
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(receivedPhotoFrameSelected:)]) {
                if ([receivedData[KEY_PHOTO_FRAME_SELECTED] isEqual:[NSNull null]]) {
                    [self.delegate receivedPhotoFrameSelected:nil];
                } else {
                    [self.delegate receivedPhotoFrameSelected:receivedData[KEY_PHOTO_FRAME_SELECTED]];
                }
            }
        }
    } else if (dataType == VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM) {
        NSLog(@"Received Confirm Frame Select");
        if ([self.delegate respondsToSelector:@selector(receivedPhotoFrameRequestConfirm)]) {
            [self.delegate receivedPhotoFrameRequestConfirm];
        }
    } else if (dataType == VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK) {
        NSLog(@"Received Confirm Ack Frame Select");
        if ([self.delegate respondsToSelector:@selector(receivedPhotoFrameConfirmAck:)]) {
            [self.delegate receivedPhotoFrameConfirmAck:[receivedData[KEY_PHOTO_FRAME_CONFIRM_ACK] boolValue]];
        }
    } else if (dataType == VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED) {
        NSLog(@"Received Session Disconnected at PhotoFrameSelectViewController");
        if ([self.delegate respondsToSelector:@selector(receivedPhotoFrameDisconnected)]) {
            [self.delegate receivedPhotoFrameDisconnected];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT) {
        NSLog(@"Received Edit Photo");
        if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoEditing:)]) {
            [self.delegate receivedEditorPhotoEditing:[receivedData[KEY_EDITOR_PHOTO_EDIT_INDEX] integerValue]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED) {
        NSLog(@"Received Edit Photo Canceled");
        if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoEditingCancelled:)]) {
            [self.delegate receivedEditorPhotoEditingCancelled:[receivedData[KEY_EDITOR_PHOTO_EDIT_INDEX] integerValue]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT_ACK) {
        NSLog(@"Received Insert Photo Ack");
        if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoInsertAck:WithAck:)]) {
            [self.delegate receivedEditorPhotoInsertAck:[receivedData[KEY_EDITOR_PHOTO_INSERT_INDEX] integerValue] WithAck:[receivedData[KEY_EDITOR_PHOTO_INSERT_ACK] boolValue]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE) {
        NSLog(@"Received Delete Photo");
        if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoDelete:)]) {
            [self.delegate receivedEditorPhotoDelete:[receivedData[KEY_EDITOR_PHOTO_DELETE_INDEX] integerValue]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT) {
        NSLog(@"Received Edit Drawing Object");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectEditing:)]) {
            [self.delegate receivedEditorDecorateObjectEditing:receivedData[KEY_EDITOR_DRAWING_EDIT_ID]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT_CANCELED) {
        NSLog(@"Received Edit Cancel Drawing Object");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectEditCancelled:)]) {
            [self.delegate receivedEditorDecorateObjectEditCancelled:receivedData[KEY_EDITOR_DRAWING_EDIT_ID]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DRAWING_INSERT) {
        NSLog(@"Received Insert Drawing Object");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectInsert:WithTimestamp:)]) {
            [self.delegate receivedEditorDecorateObjectInsert:receivedData[KEY_EDITOR_DRAWING_INSERT_DATA] WithTimestamp:receivedData[KEY_EDITOR_DRAWING_INSERT_TIMESTAMP]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_MOVED) {
        NSLog(@"Received Update Moved Drawing Object");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectMoved:WithOriginX:WithOriginY:)]) {
            [self.delegate receivedEditorDecorateObjectMoved:receivedData[KEY_EDITOR_DRAWING_UPDATE_ID] WithOriginX:[receivedData[KEY_EDITOR_DRAWING_UPDATE_MOVED_X] floatValue] WithOriginY:[receivedData[KEY_EDITOR_DRAWING_UPDATE_MOVED_Y] floatValue]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_RESIZED) {
        NSLog(@"Received Update Resized Drawing Object");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectResized:WithWidth:WithHeight:)]) {
            [self.delegate receivedEditorDecorateObjectResized:receivedData[KEY_EDITOR_DRAWING_UPDATE_ID] WithWidth:[receivedData[KEY_EDITOR_DRAWING_UPDATE_RESIZED_WIDTH] floatValue] WithHeight:[receivedData[KEY_EDITOR_DRAWING_UPDATE_RESIZED_HEIGHT] floatValue]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_ROTATED) {
        NSLog(@"Received Update Rotated Drawing Object");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectRotated:WithAngle:)]) {
            [self.delegate receivedEditorDecorateObjectRotated:receivedData[KEY_EDITOR_DRAWING_UPDATE_ID] WithAngle:[receivedData[KEY_EDITOR_DRAWING_UPDATE_ROTATED_ANGLE] floatValue]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_Z_ORDER) {
        NSLog(@"Received Update Z Order Drawing Object");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectZOrderChanged:)]) {
            [self.delegate receivedEditorDecorateObjectZOrderChanged:receivedData[KEY_EDITOR_DRAWING_UPDATE_ID]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DRAWING_DELETE) {
        NSLog(@"Received Delete Drawing Object");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectDelete:)]) {
            [self.delegate receivedEditorDecorateObjectDelete:receivedData[KEY_EDITOR_DRAWING_DELETE_ID]];
        }
    } else if (dataType == VALUE_DATA_TYPE_EDITOR_DICONNECTED) {
        NSLog(@"Received Session Disconnected at PhotoEditorViewController");
        if ([self.delegate respondsToSelector:@selector(receivedEditorDisconnected)]) {
            [self.delegate receivedEditorDisconnected];
        }
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSArray *array = [resourceName componentsSeparatedByString:@"+"];
    
    if (array != nil && array.count == 2) {
        if ([array[1] isEqualToString:@"_cropped"]) {
            NSLog(@"Receive Start Insert Photo");
            if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoInsert:WithType:WithURL:)]) {
                [self.delegate receivedEditorPhotoInsert:[array[0] integerValue] WithType:array[1] WithURL:nil];
            }
        }
    }
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    NSArray *array = [resourceName componentsSeparatedByString:@"+"];
    
    if (array != nil && array.count == 2) {
        if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoInsert:WithType:WithURL:)]) {
            [self.delegate receivedEditorPhotoInsert:[array[0] integerValue] WithType:array[1] WithURL:localURL];
        }
        
        if ([array[1] isEqualToString:@"_fullscreen"]) {
            NSLog(@"Receive Finish Insert Photo");
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT_ACK),
                                       KEY_EDITOR_PHOTO_INSERT_ACK: @YES,
                                       KEY_EDITOR_PHOTO_INSERT_INDEX: @([array[0] integerValue])};
            
            [self sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
        }
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}


#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central { /** Do nothing... **/ }

@end
