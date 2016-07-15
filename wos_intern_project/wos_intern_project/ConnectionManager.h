//
//  ConnectionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ConnectionManager : NSObject <MCSessionDelegate>

@property (nonatomic, copy, readonly) NSString *SERVICE_TYPE;

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
@property (nonatomic, copy, readonly) NSString *KEY_DATA_TYPE;

/** Session Disconnected Protocol String ... **/
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_PEER_CONNECTED;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_PEER_DISCONNECTED;

/** Screen Size Data Protocol String ... **/
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_SCREEN_SIZE;

@property (nonatomic, readonly) NSNumber *VALUE_DATA_TYPE_SCREEN_SIZE;

@property (nonatomic, copy, readonly) NSString *KEY_SCREEN_SIZE_WIDTH;
@property (nonatomic, copy, readonly) NSString *KEY_SCREEN_SIZE_HEIGHT;

/** PhotoFrame Data Protocol String ... **/
//@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_PHOTO_FRAME_INDEX;
//@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_PHOTO_FRAME_LIKED;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_PHOTO_FRAME_SELECTED;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_PHOTO_FRAME_DESELECTED;

//@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_FRAME_INDEX;
//@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_FRAME_LIKED;
@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED;
@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_FRAME_DESELECTED;

//@property (nonatomic, copy, readonly) NSString *KEY_PHOTO_FRAME_INDEX;
//@property (nonatomic, copy, readonly) NSString *KEY_PHOTO_FRAME_LIKED;
@property (nonatomic, copy, readonly) NSString *KEY_PHOTO_FRAME_SELECTED;
@property (nonatomic, copy, readonly) NSString *KEY_PHOTO_FRAME_DESELECTED;

/** PhotoData, DrawingData Protocol String... **/
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_REVC_PHOTO_INSERT_DATA;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_REVC_PHOTO_DELETE_DATA;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_REVC_DRAWING_INSERT_DATA;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_REVC_DRAWING_UPDATE_DATA;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_REVC_DRAWING_DELETE_DATA;

@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_INSERT_DATA;
@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_DELETE_DATA;
@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_DRAWING_INSERT_DATA;
@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_DRAWING_UPDATE_DATA;
@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_DRAWING_DELETE_DATA;

@property (nonatomic, copy, readonly) NSString *KEY_PHOTO_INSERT_DATA;
@property (nonatomic, copy, readonly) NSString *KEY_PHOTO_DELETE_DATA;
@property (nonatomic, copy, readonly) NSString *KEY_DRAWING_INSERT_DATA;
@property (nonatomic, copy, readonly) NSString *KEY_DRAWING_UPDATE_DATA;
@property (nonatomic, copy, readonly) NSString *KEY_DRAWING_DELETE_DATA;

/** Common Properties **/
@property (nonatomic, weak) NSNotificationCenter *notificationCenter;

@property (nonatomic, strong, readonly) MCPeerID *ownPeerId;
@property (nonatomic, strong, readonly) MCSession *ownSession;
@property (nonatomic, strong, readonly) MCBrowserViewController *browserViewController;
@property (nonatomic, strong, readonly) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong, readonly) NSNumber *ownScreenWidth, *ownScreenHeight;

/** 연결된 상대방 정보 **/
//원래 이것도 배열로 구성해서 각 피어에 해당하는 셋을 맞춰야되는데, 당장은 1:1 통신을 하므로...
//@property (nonatomic, strong, readonly) NSMutableArray *connectedPeerIds;
@property (nonatomic, strong, readonly) NSNumber *connectedPeerScreenWidth, *connectedPeerScreenHeight;

+ (ConnectionManager *)sharedInstance;

/**
 인스턴스의 프로퍼티를 초기화한다. 인자로 받은 deviceName은 자기자신의 peerID.displayName이 된다.
 초기화되는 프로퍼티는 notificationCenter, ownPeerId, session, session.delegate, browserViewController, advertiser이다.
 */
- (void)initInstanceProperties:(NSString *)deviceName screenWidthSize:(CGFloat)width screenHeightSize:(CGFloat)height;

/**
 다른 단말기에 자신의 단말기가 검색되는 것을 허용한다.
 */
- (void)startAdvertise;

/**
 다른 단말기에 자신의 단말기가 검색되는 것을 허용하지 않는다.
 */
- (void)stopAdvertise;

/**
 ConnectionManager가 관리하는 MCSession 객체를 이용하여 메시지를 보낸다. 메시지의 범위는 연결된 모든 피어를 대상으로 전파된다.
 */
- (void)sendData:(NSData *)sendData;

/**
 Session의 연결을 해제한다.
 */
- (void)disconnectSession;

@end
