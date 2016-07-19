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
NSString *const SERVICE_TYPE                                = @"Co-PhotoEditor";

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
NSString *const KEY_DATA_TYPE                               = @"data_type";

/** KEY_DATA_TYPE에 값으로 설정되는 값 **/
NSUInteger const VALUE_DATA_TYPE_SCREEN_SIZE                = 100;

NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED       = 200;
NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM        = 201;
NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK    = 202;
NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED   = 203;

NSUInteger const VALUE_DATA_TYPE_PHOTO_INSERT_DATA          = 300;
NSUInteger const VALUE_DATA_TYPE_PHOTO_DELETE_DATA          = 301;
NSUInteger const VALUE_DATA_TYPE_DRAWING_INSERT_DATA        = 302;
NSUInteger const VALUE_DATA_TYPE_DRAWING_UPDATE_DATA        = 303;
NSUInteger const VALUE_DATA_TYPE_DRAWING_DELETE_DATA        = 304;

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
NSString *const KEY_SCREEN_SIZE_WIDTH                       = @"screen_size_width";
NSString *const KEY_SCREEN_SIZE_HEIGHT                      = @"screen_size_height";

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
NSString *const KEY_PHOTO_FRAME_SELECTED                    = @"photo_frame_select";

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
NSString *const KEY_PHOTO_FRAME_CONFIRM_ACK                 = @"photo_frame_confirm_ack";

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
/** 아직 미정. 근데 아마 사진은 byte[], 그림 객체는 DrawingObject 값으로 매칭될 듯 **/
NSString *const KEY_PHOTO_INSERT_DATA                       = @"photo_insert_data";
NSString *const KEY_PHOTO_DELETE_DATA                       = @"photo_delete_data";
NSString *const KEY_DRAWING_INSERT_DATA                     = @"drawing_insert_data";
NSString *const KEY_DRAWING_UPDATE_DATA                     = @"drawing_update_data";
NSString *const KEY_DRAWING_DELETE_DATA                     = @"drawing_delete_data";

/** 세션 연결, 연결 해제에 대한 노티피케이션 이름 **/
NSString *const NOTIFICATION_PEER_CONNECTED                 = @"noti_peer_connected";
NSString *const NOTIFICATION_PEER_DISCONNECTED              = @"noti_peer_disconnected";

/** 스크린 크기값 수신에 대한 노티피케이션 이름 **/
NSString *const NOTIFICATION_RECV_SCREEN_SIZE               = @"noti_recv_screen_size";

/** 액자 선택, 결정, 결정응답, 연결해제에 대한 노티피케이션 이름 **/
NSString *const NOTIFICATION_RECV_PHOTO_FRAME_SELECTED      = @"noti_recv_photo_frame_selected";
NSString *const NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM       = @"noti_recv_photo_frame_confirm";
NSString *const NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM_ACK   = @"noti_recv_photo_frame_confirm_ack";
NSString *const NOTIFICATION_RECV_PHOTO_FRAME_DISCONNECTED  = @"noti_recv_photo_frame_disconnected";

/** 사진입력, 사진삭제, 그림객체 입력, 갱신, 삭제와 관련된 노티피케이션 이름 **/
NSString *const NOTIFICATION_REVC_PHOTO_INSERT_DATA         = @"noti_recv_photo_insert_data";
NSString *const NOTIFICATION_REVC_PHOTO_DELETE_DATA         = @"noti_recv_photo_delete_data";
NSString *const NOTIFICATION_REVC_DRAWING_INSERT_DATA       = @"noti_recv_drawing_insert_data";
NSString *const NOTIFICATION_REVC_DRAWING_UPDATE_DATA       = @"noti_recv_drawing_update_data";
NSString *const NOTIFICATION_REVC_DRAWING_DELETE_DATA       = @"noti_recv_drawing_delete_data";

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

- (void)initInstanceProperties:(NSString *)deviceName screenWidthSize:(CGFloat)width screenHeightSize:(CGFloat)height {
    ownPeerId = [[MCPeerID alloc] initWithDisplayName:deviceName];
    ownSession = [[MCSession alloc] initWithPeer:ownPeerId];
    ownSession.delegate = self;
    
    ownScreenWidth = [NSNumber numberWithFloat:width];
    ownScreenHeight = [NSNumber numberWithFloat:height];
    
    browserViewController = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_TYPE session:ownSession];
    advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:ownPeerId discoveryInfo:nil serviceType:SERVICE_TYPE];
    
    //1:1 통신이므로 연결할 피어의 수는 하나로 제한한다.
    self.browserViewController.maximumNumberOfPeers = 1;
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

- (void)disconnectSession {
    [self.ownSession disconnect];
}

/**** MCSessionDelegate Methods. ****/

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    //연결이 완료되면 연결된 peerId를 배열에 저장하고, 상대방에게 자신의 화면크기 정보를 보낸다.
    if (state == MCSessionStateConnected) {
        NSLog(@"Session Connected");
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PEER_CONNECTED object:nil];
    }
    else if (state == MCSessionStateNotConnected) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PEER_DISCONNECTED object:nil];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *receivedData = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSUInteger dataType = [(NSNumber *)[receivedData objectForKey:KEY_DATA_TYPE] intValue];
    
    switch (dataType) {
        case VALUE_DATA_TYPE_SCREEN_SIZE:
            connectedPeerScreenWidth = [receivedData objectForKey:KEY_SCREEN_SIZE_WIDTH];
            connectedPeerScreenHeight = [receivedData objectForKey:KEY_SCREEN_SIZE_HEIGHT];
            NSLog(@"Received Screen Size : width(%f), height(%f)", [connectedPeerScreenWidth floatValue], [connectedPeerScreenHeight floatValue]);
            break;
        case VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED:
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil userInfo:receivedData];
            NSLog(@"Received Selected Frame Index");
            break;
        case VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM:
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM object:nil userInfo:nil];
            NSLog(@"Received Confirm Frame Select");
            break;
        case VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK:
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM_ACK object:nil userInfo:receivedData];
            NSLog(@"Received Confirm Ack Frame Select");
            break;
        case VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED:
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECV_PHOTO_FRAME_DISCONNECTED object:nil userInfo:nil];
            NSLog(@"Received Session Disconnected at PhotoFrameSelectViewController");
            break;
        case VALUE_DATA_TYPE_PHOTO_INSERT_DATA:
            
            break;
        case VALUE_DATA_TYPE_PHOTO_DELETE_DATA:
            
            break;
        case VALUE_DATA_TYPE_DRAWING_INSERT_DATA:
            
            break;
        case VALUE_DATA_TYPE_DRAWING_UPDATE_DATA:
            
            break;
        case VALUE_DATA_TYPE_DRAWING_DELETE_DATA:
            
            break;
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {}
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}

@end
