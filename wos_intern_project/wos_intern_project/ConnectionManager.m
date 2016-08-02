//
//  ConnectionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ConnectionManager.h"

/** MCSession Service Type **/
/** 이 값이 일치하는 장비만 Bluetooth 장비목록에 노출된다 **/
NSString *const SERVICE_TYPE                                  = @"Co-PhotoEditor";

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
NSString *const KEY_DATA_TYPE                                 = @"data_type";

/** KEY_DATA_TYPE에 값으로 설정되는 값 **/
//NSNumber로 설정하면 컴파일 시에 초기화되지 않아서 NSUInteger로 설정하였다.
NSUInteger const VALUE_DATA_TYPE_SCREEN_SIZE                    = 100;

NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED           = 200;
NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM            = 201;
NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK        = 202;

NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED       = 300;

NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT            = 400;
NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT_ACK        = 401;
NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT              = 402;
NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED     = 403;
NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE            = 404;

NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT            = 500;
NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT_CANCELED   = 501;
NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_INSERT          = 502;
NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_MOVED    = 503;
NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_RESIZED  = 504;
NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_ROTATED  = 505;
NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_Z_ORDER  = 506;
NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_DELETE          = 507;

NSUInteger const VALUE_DATA_TYPE_EDITOR_DICONNECTED             = 600;

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
NSString *const KEY_SCREEN_SIZE_WIDTH                           = @"screen_size_width";
NSString *const KEY_SCREEN_SIZE_HEIGHT                          = @"screen_size_height";

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
NSString *const KEY_PHOTO_FRAME_SELECTED                        = @"photo_frame_select";

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
NSString *const KEY_PHOTO_FRAME_CONFIRM_ACK                     = @"photo_frame_confirm_ack";

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
/** 아직 미정. 근데 아마 사진은 byte[], 그림 객체는 DrawingObject 값으로 매칭될 듯 **/
NSString *const KEY_EDITOR_PHOTO_INSERT_INDEX                   = @"photo_insert_index";
NSString *const KEY_EDITOR_PHOTO_INSERT_DATA_TYPE               = @"photo_insert_data_type";
NSString *const KEY_EDITOR_PHOTO_INSERT_DATA                    = @"photo_insert_data";
NSString *const KEY_EDITOR_PHOTO_INSERT_ACK                     = @"photo_insert_ack";
NSString *const KEY_EDITOR_PHOTO_EDIT_INDEX                     = @"photo_edit_index";
NSString *const KEY_EDITOR_PHOTO_DELETE_INDEX                   = @"photo_delete_index";

NSString *const KEY_EDITOR_DRAWING_EDIT_ID                      = @"drawing_edit_id";
NSString *const KEY_EDITOR_DRAWING_INSERT_DATA                  = @"drawing_insert_data";
NSString *const KEY_EDITOR_DRAWING_INSERT_TIMESTAMP             = @"drawing_insert_timestamp";
NSString *const KEY_EDITOR_DRAWING_UPDATE_ID                    = @"drawing_update_id";
//NSString *const KEY_EDITOR_DRAWING_UPDATE_DATA                  = @"drawing_update_data";
NSString *const KEY_EDITOR_DRAWING_UPDATE_MOVED_X               = @"drawing_update_moved_x";
NSString *const KEY_EDITOR_DRAWING_UPDATE_MOVED_Y               = @"drawing_update_moved_y";;
NSString *const KEY_EDITOR_DRAWING_UPDATE_RESIZED_WIDTH         = @"drawing_update_resized_width";;
NSString *const KEY_EDITOR_DRAWING_UPDATE_RESIZED_HEIGHT        = @"drawing_update_resized_height";
NSString *const KEY_EDITOR_DRAWING_UPDATE_ROTATED_ANGLE         = @"drawing_update_rotated_angle";
//NSString *const KEY_EDITOR_DRAWING_UPDATE_Z_ORDER               = @"drawing_update_z_order";
NSString *const KEY_EDITOR_DRAWING_DELETE_ID                    = @"drawing_delete_id";

///** 세션 연결, 연결 해제에 대한 노티피케이션 이름 **/
//NSString *const NOTIFICATION_PEER_CONNECTED                     = @"noti_peer_connected";
//NSString *const NOTIFICATION_PEER_DISCONNECTED                  = @"noti_peer_disconnected";
//
///** 스크린 크기값 수신에 대한 노티피케이션 이름 **/
//NSString *const NOTIFICATION_RECV_SCREEN_SIZE                   = @"noti_recv_screen_size";
//
///** 액자 선택, 결정, 결정응답, 연결해제에 대한 노티피케이션 이름 **/
//NSString *const NOTIFICATION_RECV_PHOTO_FRAME_SELECTED          = @"noti_recv_photo_frame_selected";
//NSString *const NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM           = @"noti_recv_photo_frame_confirm";
//NSString *const NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM_ACK       = @"noti_recv_photo_frame_confirm_ack";
//NSString *const NOTIFICATION_RECV_PHOTO_FRAME_DISCONNECTED      = @"noti_recv_photo_frame_disconnected";
//
///** 사진입력, 사진삭제, 그림객체 입력, 갱신, 삭제와 관련된 노티피케이션 이름 **/
//NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_INSERT           = @"noti_recv_editor_photo_insert";
//NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_INSERT_ACK       = @"noti_recv_editor_photo_insert_ack";
//NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_EDIT             = @"noti_recv_editor_photo_edit";
//NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_EDIT_CANCELED    = @"noti_recv_editor_photo_edit_canceled";
//NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_DELETE           = @"noti_recv_editor_photo_delete";
//NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_EDIT           = @"noti_recv_editor_drawing_edit";
//NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_EDIT_CANCEL    = @"noti_recv_editor_drawing_edit_cancel";
//NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_INSERT         = @"noti_recv_editor_drawing_insert";
//NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE_MOVED   = @"noti_recv_editor_drawing_update_moved";
//NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE_RESIZED = @"noti_recv_editor_drawing_update_resized";
//NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE_ROTATED = @"noti_recv_editor_drawing_update_rotated";
//NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE_Z_ORDER = @"noti_recv_editor_drawing_update_z_order";
//NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_DELETE         = @"noti_recv_editor_drawing_delete";
//NSString *const NOTIFICATION_RECV_EDITOR_DISCONNECTED           = @"noti_recv_editor_disconnected";

@implementation ConnectionManager

@synthesize ownPeerId, ownSession;
@synthesize browserViewController, advertiser;
@synthesize ownScreenWidth, ownScreenHeight;

@synthesize connectedPeerScreenWidth, connectedPeerScreenHeight;

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
    ownPeerId = [[MCPeerID alloc] initWithDisplayName:deviceName];
    ownSession = [[MCSession alloc] initWithPeer:ownPeerId];
    ownSession.delegate = self;
    
    ownScreenWidth = @(width);
    ownScreenHeight = @(height);
    
    browserViewController = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_TYPE session:ownSession];
    advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:ownPeerId discoveryInfo:nil serviceType:SERVICE_TYPE];
    
    //1:1 통신이므로 연결할 피어의 수는 하나로 제한한다.
    browserViewController.maximumNumberOfPeers = 1;
}

- (void)startAdvertise {
    [advertiser startAdvertisingPeer];
}

- (void)stopAdvertise {
    [advertiser stopAdvertisingPeer];
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
    
    switch (dataType) {
        case VALUE_DATA_TYPE_SCREEN_SIZE:
            NSLog(@"Received Screen Size : width(%f), height(%f)", [connectedPeerScreenWidth floatValue], [connectedPeerScreenHeight floatValue]);
            connectedPeerScreenWidth = receivedData[KEY_SCREEN_SIZE_WIDTH];
            connectedPeerScreenHeight = receivedData[KEY_SCREEN_SIZE_HEIGHT];
            break;
        case VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED:
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
            break;
        case VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM:
            NSLog(@"Received Confirm Frame Select");
            if ([self.delegate respondsToSelector:@selector(receivedPhotoFrameRequestConfirm)]) {
                [self.delegate receivedPhotoFrameRequestConfirm];
            }
            break;
        case VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK:
            NSLog(@"Received Confirm Ack Frame Select");
            if ([self.delegate respondsToSelector:@selector(receivedPhotoFrameConfirmAck:)]) {
                [self.delegate receivedPhotoFrameConfirmAck:[receivedData[KEY_PHOTO_FRAME_CONFIRM_ACK] boolValue]];
            }
            break;
        case VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED:
            NSLog(@"Received Session Disconnected at PhotoFrameSelectViewController");
            if ([self.delegate respondsToSelector:@selector(receivedPhotoFrameDisconnected)]) {
                [self.delegate receivedPhotoFrameDisconnected];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT:
            NSLog(@"Received Edit Photo");
            if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoEditing:)]) {
                [self.delegate receivedEditorPhotoEditing:[receivedData[KEY_EDITOR_PHOTO_EDIT_INDEX] integerValue]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED:
            NSLog(@"Received Edit Photo Canceled");
            if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoEditingCancelled:)]) {
                [self.delegate receivedEditorPhotoEditingCancelled:[receivedData[KEY_EDITOR_PHOTO_EDIT_INDEX] integerValue]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT_ACK:
            NSLog(@"Received Insert Photo Ack");
            if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoInsertAck:WithAck:)]) {
                [self.delegate receivedEditorPhotoInsertAck:[receivedData[KEY_EDITOR_PHOTO_INSERT_INDEX] integerValue] WithAck:[receivedData[KEY_EDITOR_PHOTO_INSERT_ACK] boolValue]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE:
            NSLog(@"Received Delete Photo");
            if ([self.delegate respondsToSelector:@selector(receivedEditorPhotoDelete:)]) {
                [self.delegate receivedEditorPhotoDelete:[receivedData[KEY_EDITOR_PHOTO_DELETE_INDEX] integerValue]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT:
            NSLog(@"Received Edit Drawing Object");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectEditing:)]) {
                [self.delegate receivedEditorDecorateObjectEditing:receivedData[KEY_EDITOR_DRAWING_EDIT_ID]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT_CANCELED:
            NSLog(@"Received Edit Cancel Drawing Object");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectEditCancelled:)]) {
                [self.delegate receivedEditorDecorateObjectEditCancelled:receivedData[KEY_EDITOR_DRAWING_EDIT_ID]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DRAWING_INSERT:
            NSLog(@"Received Insert Drawing Object");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectInsert:WithTimestamp:)]) {
                [self.delegate receivedEditorDecorateObjectInsert:receivedData[KEY_EDITOR_DRAWING_INSERT_DATA] WithTimestamp:receivedData[KEY_EDITOR_DRAWING_INSERT_TIMESTAMP]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_MOVED:
            NSLog(@"Received Update Moved Drawing Object");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectMoved:WithOriginX:WithOriginY:)]) {
                [self.delegate receivedEditorDecorateObjectMoved:receivedData[KEY_EDITOR_DRAWING_UPDATE_ID] WithOriginX:[receivedData[KEY_EDITOR_DRAWING_UPDATE_MOVED_X] floatValue] WithOriginY:[receivedData[KEY_EDITOR_DRAWING_UPDATE_MOVED_Y] floatValue]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_RESIZED:
            NSLog(@"Received Update Resized Drawing Object");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectResized:WithWidth:WithHeight:)]) {
                [self.delegate receivedEditorDecorateObjectResized:receivedData[KEY_EDITOR_DRAWING_UPDATE_ID] WithWidth:[receivedData[KEY_EDITOR_DRAWING_UPDATE_RESIZED_WIDTH] floatValue] WithHeight:[receivedData[KEY_EDITOR_DRAWING_UPDATE_RESIZED_HEIGHT] floatValue]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_ROTATED:
            NSLog(@"Received Update Rotated Drawing Object");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectRotated:WithAngle:)]) {
                [self.delegate receivedEditorDecorateObjectRotated:receivedData[KEY_EDITOR_DRAWING_UPDATE_ID] WithAngle:[receivedData[KEY_EDITOR_DRAWING_UPDATE_ROTATED_ANGLE] floatValue]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_Z_ORDER:
            NSLog(@"Received Update Z Order Drawing Object");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectZOrderChanged:)]) {
                [self.delegate receivedEditorDecorateObjectZOrderChanged:receivedData[KEY_EDITOR_DRAWING_UPDATE_ID]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DRAWING_DELETE:
            NSLog(@"Received Delete Drawing Object");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDecorateObjectDelete:)]) {
                [self.delegate receivedEditorDecorateObjectDelete:receivedData[KEY_EDITOR_DRAWING_DELETE_ID]];
            }
            break;
        case VALUE_DATA_TYPE_EDITOR_DICONNECTED:
            NSLog(@"Received Session Disconnected at PhotoEditorViewController");
            if ([self.delegate respondsToSelector:@selector(receivedEditorDisconnected)]) {
                [self.delegate receivedEditorDisconnected];
            }
            break;
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

@end
