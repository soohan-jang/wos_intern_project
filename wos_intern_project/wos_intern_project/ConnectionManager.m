//
//  ConnectionManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager

@synthesize SERVICE_TYPE;

/** 공통적으로 사용되는, 전달받은 데이터 식별 키 : 이 키의 값으로 전달받은 데이터의 종류를 파악한다. **/
@synthesize KEY_DATA_TYPE;

/** 연결되었을 때, 이를 알리기 위한 알림 식별자 **/
@synthesize NOTIFICATION_CONNECTED;

/** 연결이 해제되었을 때, 이를 알리기 위한 알림 식별자 **/
@synthesize NOTIFICATION_DISCONNECTED;

/** 젼댤받은 데이터가 어떤 정보인지 확인하기 위한 식별자 **/
@synthesize VALUE_DATA_TYPE_SCREEN_SIZE;

/** 화면 사이즈를 전달받았을 때, 이를 알리기 위한 알림 식별자 **/
@synthesize NOTIFICATION_RECV_SCREEN_SIZE;

/** 전달받은 데이터의 상대방 단말 화면 너비, 높이값을 담고 있는 키 값 **/
@synthesize KEY_SCREEN_SIZE_WIDTH, KEY_SCREEN_SIZE_HEIGHT;

/** 액자와 관련된 상태를 알리기 위한 알림 식별자 : 현재 보여져야 하는 액자의 인덱스, 현재 사진 액자에 대한 의사 표현, 선택된 사진 액자 정보 **/
@synthesize NOTIFICATION_RECV_PHOTO_FRAME_INDEX, NOTIFICATION_RECV_PHOTO_FRAME_LIKED, NOTIFICATION_RECV_PHOTO_FRAME_SELECTED;

/** 젼댤받은 데이터가 어떤 정보인지 확인하기 위한 식별자 **/
@synthesize VALUE_DATA_TYPE_PHOTO_FRAME_INDEX, VALUE_DATA_TYPE_PHOTO_FRAME_LIKED, VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED;

/** 전달받은 데이터의 액자 인덱스, 좋아요를 표시한 액자 인덱스, 선택된 액자 인덱스 키 값 **/
@synthesize KEY_FRAME_INDEX, KEY_FRAME_LIKED, KEY_FRAME_SELECTED;

/** 화면에 표시될 사진, 그림정보, 삭제 정보가 전달되었을 때 알리기 위한 알림 식별자 **/
@synthesize NOTIFICATION_REVC_PHOTO_INSERT_DATA, NOTIFICATION_REVC_PHOTO_DELETE_DATA, NOTIFICATION_REVC_DRAWING_INSERT_DATA, NOTIFICATION_REVC_DRAWING_UPDATE_DATA, NOTIFICATION_REVC_DRAWING_DELETE_DATA;

/** 젼댤받은 데이터가 어떤 정보인지 확인하기 위한 식별자 **/
@synthesize KEY_PHOTO_INSERT_DATA, KEY_PHOTO_DELETE_DATA, KEY_DRAWING_INSERT_DATA, KEY_DRAWING_UPDATE_DATA, KEY_DRAWING_DELETE_DATA;

/** 전달받은 데이터의 사진 정보, 그림정보, 삭제정보를 담고 있는 키 값 **/
@synthesize VALUE_DATA_TYPE_PHOTO_INSERT_DATA, VALUE_DATA_TYPE_PHOTO_DELETE_DATA, VALUE_DATA_TYPE_DRAWING_INSERT_DATA, VALUE_DATA_TYPE_DRAWING_UPDATE_DATA, VALUE_DATA_TYPE_DRAWING_DELETE_DATA;

@synthesize ownPeerId, ownSession;
@synthesize browserViewController, advertiser;
@synthesize ownScreenWidth, ownScreenHeight;

@synthesize connectedPeerScreenWidth, connectedPeerScreenHeight;

+ (ConnectionManager *)sharedInstance {
    static ConnectionManager *instance = nil;
    
    @synchronized (self) {
        if (instance == nil) {
            instance = [[self alloc] init];
            [instance initializeReadonlyString];
        }
    }
    
    return instance;
}

/** berif
 통신에 사용되는 프로토콜 키와 벨류 값을 설정한다.
 이 메소드는 sharedInstance에서 호출된다. 독자적으로 호출하지 말 것!
 */
- (void)initializeReadonlyString {
    SERVICE_TYPE = @"Co-PhotoEditor";
    
    KEY_DATA_TYPE = @"data_type";
    
    VALUE_DATA_TYPE_SCREEN_SIZE = @100;
    VALUE_DATA_TYPE_PHOTO_FRAME_INDEX = @200;
    VALUE_DATA_TYPE_PHOTO_FRAME_LIKED = @201;
    VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED = @202;
    VALUE_DATA_TYPE_PHOTO_INSERT_DATA = @301;
    VALUE_DATA_TYPE_PHOTO_DELETE_DATA = @302;
    VALUE_DATA_TYPE_DRAWING_INSERT_DATA = @303;
    VALUE_DATA_TYPE_DRAWING_UPDATE_DATA = @304;
    VALUE_DATA_TYPE_DRAWING_DELETE_DATA = @305;
    
    KEY_SCREEN_SIZE_WIDTH = @"screen_size_width";
    KEY_SCREEN_SIZE_HEIGHT = @"screen_size_height";
    KEY_FRAME_INDEX = @"frame_index";
    KEY_FRAME_LIKED = @"frame_liked";
    KEY_FRAME_SELECTED = @"frame_selected";
    KEY_PHOTO_INSERT_DATA = @"photo_insert_data";
    KEY_PHOTO_DELETE_DATA = @"photo_delete_data";
    KEY_DRAWING_INSERT_DATA = @"photo_insert_data";
    KEY_DRAWING_UPDATE_DATA = @"photo_update_data";
    KEY_DRAWING_DELETE_DATA = @"photo_delete_data";
    
    NOTIFICATION_CONNECTED = @"connected";
    NOTIFICATION_DISCONNECTED = @"disconnected";
    NOTIFICATION_RECV_SCREEN_SIZE = @"recv_screen_size";
    NOTIFICATION_RECV_PHOTO_FRAME_INDEX = @"recv_photo_frame_index";
    NOTIFICATION_RECV_PHOTO_FRAME_LIKED = @"recv_photo_frame_liked";
    NOTIFICATION_RECV_PHOTO_FRAME_SELECTED = @"recv_photo_frame_selected";
    NOTIFICATION_REVC_PHOTO_INSERT_DATA = @"recv_photo_insert_data";
    NOTIFICATION_REVC_PHOTO_DELETE_DATA = @"recv_photo_delete_data";
    NOTIFICATION_REVC_DRAWING_INSERT_DATA = @"recv_drawing_insert_data";
    NOTIFICATION_REVC_DRAWING_UPDATE_DATA = @"recv_drawing_update_data";
    NOTIFICATION_REVC_DRAWING_DELETE_DATA = @"recv_drawing_delete_data";
}

/** berif
 인스턴스의 프로퍼티를 초기화한다. 인자로 받은 deviceName은 자기자신의 peerID.displayName이 된다.
 초기화되는 프로퍼티는 notificationCenter, ownPeerId, session, session.delegate, browserViewController, advertiser이다.
 */
- (void)initInstanceProperties:(NSString *)deviceName screenWidthSize:(CGFloat)width screenHeightSize:(CGFloat)height {
    self.notificationCenter = [NSNotificationCenter defaultCenter];
    
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
    advertiser = nil;
}

- (void)setConnectedPeerScreenWidthWith:(NSNumber *)width connectedPeerScreenHeight:(NSNumber *)height {
    connectedPeerScreenWidth = width;
    connectedPeerScreenHeight = height;
}

/**
 MCSessionDelegate Methods.
 **/

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    //연결이 완료되면 연결된 peerId를 배열에 저장하고, 상대방에게 자신의 화면크기 정보를 보낸다.
    if (state == MCSessionStateConnected) {
        [self.notificationCenter postNotificationName:NOTIFICATION_CONNECTED object:nil];
    }
    else if (state == MCSessionStateNotConnected) {
        [self.notificationCenter postNotificationName:NOTIFICATION_DISCONNECTED object:nil];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *receivedData = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSNumber *dataType = [receivedData objectForKey:KEY_DATA_TYPE];
    
    //받은 정보가 화면크기 정보일 때, 데이터를 읽어와 받은 정보를 저장한다.
    if ([dataType isEqualToNumber:VALUE_DATA_TYPE_SCREEN_SIZE]) {
        NSDictionary *unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        connectedPeerScreenWidth = [unarchivedData objectForKey:KEY_SCREEN_SIZE_WIDTH];
        connectedPeerScreenHeight = [unarchivedData objectForKey:KEY_SCREEN_SIZE_HEIGHT];
        
        NSLog(@"Received Screen Size : width(%f), height(%f)", [connectedPeerScreenWidth floatValue], [connectedPeerScreenHeight floatValue]);
        
        [self.notificationCenter postNotificationName:NOTIFICATION_RECV_SCREEN_SIZE object:nil userInfo:unarchivedData];
    }
    else if ([dataType isEqualToNumber:VALUE_DATA_TYPE_PHOTO_FRAME_INDEX]) {
        
    }
    else if ([dataType isEqualToNumber:VALUE_DATA_TYPE_PHOTO_FRAME_LIKED]) {
        
    }
    else if ([dataType isEqualToNumber:VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED]) {
        
    }
    else if ([dataType isEqualToNumber:VALUE_DATA_TYPE_PHOTO_INSERT_DATA]) {
        
    }
    else if ([dataType isEqualToNumber:VALUE_DATA_TYPE_PHOTO_DELETE_DATA]) {
        
    }
    else if ([dataType isEqualToNumber:VALUE_DATA_TYPE_DRAWING_INSERT_DATA]) {
        
    }
    else if ([dataType isEqualToNumber:VALUE_DATA_TYPE_DRAWING_UPDATE_DATA]) {
        
    }
    else if ([dataType isEqualToNumber:VALUE_DATA_TYPE_DRAWING_DELETE_DATA]) {
        
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {}
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}

@end
