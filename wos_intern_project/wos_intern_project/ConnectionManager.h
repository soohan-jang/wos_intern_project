//
//  ConnectionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MessageSyncManager.h"

/** MCSession Service Type **/
/** 이 값이 일치하는 장비만 Bluetooth 장비목록에 노출된다 **/
extern NSString *const SERVICE_TYPE;

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
extern NSString *const KEY_DATA_TYPE;

/** KEY_DATA_TYPE에 값으로 설정되는 값 **/
extern NSUInteger const VALUE_DATA_TYPE_SCREEN_SIZE;

extern NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED;
extern NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM;
extern NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK;
extern NSUInteger const VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED;

extern NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT_ACK;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_INSERT;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_DELETE;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DICONNECTED;

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
extern NSString *const KEY_SCREEN_SIZE_WIDTH;
extern NSString *const KEY_SCREEN_SIZE_HEIGHT;

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
extern NSString *const KEY_PHOTO_FRAME_SELECTED;

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
extern NSString *const KEY_PHOTO_FRAME_CONFIRM_ACK;

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
/** 아직 미정. 근데 아마 사진은 byte[], 그림 객체는 DrawingObject 값으로 매칭될 듯 **/
extern NSString *const KEY_EDITOR_PHOTO_INSERT_INDEX;
extern NSString *const KEY_EDITOR_PHOTO_INSERT_DATA_TYPE;
extern NSString *const KEY_EDITOR_PHOTO_INSERT_DATA;
extern NSString *const KEY_EDITOR_PHOTO_INSERT_ACK;
extern NSString *const KEY_EDITOR_PHOTO_DELETE_INDEX;
extern NSString *const KEY_EDITOR_DRAWING_INSERT_DATA;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_DATA;
extern NSString *const KEY_EDITOR_DRAWING_DELETE_DATA;

/** 세션 연결, 연결 해제에 대한 노티피케이션 이름 **/
extern NSString *const NOTIFICATION_PEER_CONNECTED;
extern NSString *const NOTIFICATION_PEER_DISCONNECTED;

/** 스크린 크기값 수신에 대한 노티피케이션 이름 **/
extern NSString *const NOTIFICATION_RECV_SCREEN_SIZE;

/** 액자 선택, 결정, 결정응답, 연결해제에 대한 노티피케이션 이름 **/
extern NSString *const NOTIFICATION_RECV_PHOTO_FRAME_SELECTED;
extern NSString *const NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM;
extern NSString *const NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM_ACK;
extern NSString *const NOTIFICATION_RECV_PHOTO_FRAME_DISCONNECTED;

/** 사진입력, 사진삭제, 그림객체 입력, 갱신, 삭제와 관련된 노티피케이션 이름 **/
extern NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_INSERT;
extern NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_INSERT_ACK;
extern NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_DELETE;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_INSERT;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_DELETE;
extern NSString *const NOTIFICATION_RECV_EDITOR_DISCONNECTED;

@interface ConnectionManager : NSObject <MCSessionDelegate>

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

- (void)sendResourceDataWithFilename:(NSString *)filename index:(NSInteger)index;

/**
 Session의 연결을 해제한다.
 */
- (void)disconnectSession;

@end
