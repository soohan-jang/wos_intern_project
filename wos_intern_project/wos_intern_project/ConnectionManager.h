//
//  ConnectionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MessageSyncManager.h"
#import "ImageUtility.h"

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
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE;

extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT_CANCELED;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_INSERT;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_MOVED;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_RESIZED;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_ROTATED;
extern NSUInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_Z_ORDER;
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
extern NSString *const KEY_EDITOR_PHOTO_EDIT_INDEX;
extern NSString *const KEY_EDITOR_PHOTO_DELETE_INDEX;

extern NSString *const KEY_EDITOR_DRAWING_EDIT_ID;
extern NSString *const KEY_EDITOR_DRAWING_INSERT_DATA;
extern NSString *const KEY_EDITOR_DRAWING_INSERT_TIMESTAMP;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_ID;
//extern NSString *const KEY_EDITOR_DRAWING_UPDATE_DATA;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_MOVED_X;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_MOVED_Y;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_RESIZED_WIDTH;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_RESIZED_HEIGHT;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_ROTATED_ANGLE;
//extern NSString *const KEY_EDITOR_DRAWING_UPDATE_Z_ORDER;
extern NSString *const KEY_EDITOR_DRAWING_DELETE_ID;

///** 세션 연결, 연결 해제에 대한 노티피케이션 이름 **/
//extern NSString *const NOTIFICATION_PEER_CONNECTED;
//extern NSString *const NOTIFICATION_PEER_DISCONNECTED;
//
///** 스크린 크기값 수신에 대한 노티피케이션 이름 **/
//extern NSString *const NOTIFICATION_RECV_SCREEN_SIZE;
//
///** 액자 선택, 결정, 결정응답, 연결해제에 대한 노티피케이션 이름 **/
//extern NSString *const NOTIFICATION_RECV_PHOTO_FRAME_SELECTED;
//extern NSString *const NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM;
//extern NSString *const NOTIFICATION_RECV_PHOTO_FRAME_CONFIRM_ACK;
//extern NSString *const NOTIFICATION_RECV_PHOTO_FRAME_DISCONNECTED;
//
///** 사진입력, 사진삭제, 그림객체 입력, 갱신, 삭제와 관련된 노티피케이션 이름 **/
//extern NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_INSERT;
//extern NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_INSERT_ACK;
//extern NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_EDIT;
//extern NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_EDIT_CANCELED;
//extern NSString *const NOTIFICATION_RECV_EDITOR_PHOTO_DELETE;
//
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_EDIT;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_EDIT_CANCEL;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_INSERT;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE_MOVED;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE_RESIZED;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE_ROTATED;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE_Z_ORDER;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DRAWING_DELETE;
//extern NSString *const NOTIFICATION_RECV_EDITOR_DISCONNECTED;

@protocol ConnectionManagerDelegate;

@interface ConnectionManager : NSObject <MCSessionDelegate>

@property (nonatomic, weak) id<ConnectionManagerDelegate> delegate;
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
- (void)initInstanceProperties:(NSString *)deviceName withScreenWidthSize:(CGFloat)width withScreenHeightSize:(CGFloat)height;

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

- (void)sendPhotoDataWithFilename:(NSString *)filename withFullscreenImageURL:(NSURL *)fullscreenImageURL withCroppedImageURL:(NSURL *)croppedImageURL withIndex:(NSInteger)index;

/**
 Session의 연결을 해제한다.
 */
- (void)disconnectSession;

@end

/**
 MCSessionDelegate를 전파하기 위한 ConnectionManager의 Delegate이다.
 MCSessionDelegate에 전달되는 값을 확인하여, 세분화한 뒤 그에 해당하는 Delegate로 메시지를 전달한다.
 */
@protocol ConnectionManagerDelegate <NSObject>
@optional
/**
 Peer가 연결되었을 때  호출된다. didStateChanged에 의해 호출된다.
 */
- (void)receivedPeerConnected;
/**
 Peer가 연결해제되었을 때 호출된다. didStateChanged에 의해 호출된다.
 */
- (void)receivedPeerDisconnected;

/**
 선택된 사진 액자의 종류를 받았을 때 호출된다. 여기서의 사진 액자는 전체 사진 액자의 틀을 의미한다.
 */
- (void)receivedPhotoFrameSelected:(NSIndexPath *)selectedIndexPath;
/**
 상대방이 현재 선택한 사진 액자를 최종적으로 선택할 때, 동의를 여부를 물었을 때 호출된다.
 */
- (void)receivedPhotoFrameRequestConfirm;
/**
 상대방이 사진 액자를 최종적으로 선택한 것에 대한 동의 여부에 응답했을 때 호출된다.
 */
- (void)receivedPhotoFrameConfirmAck:(BOOL)confirmAck;
/**
 사진 액자 선택에서 상대방이 연결을 끊었을 때 호출된다.
 receivedPeerDisconnected로 통폐합 예정이다.
 */
- (void)receivedPhotoFrameDisconnected;

/**
 상대방이 특정 사진 액자 영역을 선택했을 때 호출된다.
 */
- (void)receivedEditorPhotoEditing:(NSInteger)targetFrameIndex;
/**
 상대방이 특정 사진 액자 영역을 선택 해제했을 때 호출된다.
 */
- (void)receivedEditorPhotoEditingCancelled:(NSInteger)targetFrameIndex;
/**
 상대방이 특정 사진 액자 영역에 사진을 삽입했을 때 호출된다.
 사진이 삽입되었을 때 총 2번 호출되는데, 어느 사진 액자 영역에 삽입될 지/현재 전달받은 사진 정보가 무엇인지/사진 정보가 저장된 URL을 전달한다.
 사진 정보는 cropped와 fullscreen으로 구분되며, cropped는
 */
- (void)receivedEditorPhotoInsert:(NSInteger)targetFrameIndex WithType:(NSString *)type WithURL:(NSURL *)url;
/**
 상대방이 사진 정보를 모두 수신한 뒤에 이 여부를 전달했을 때 호출된다.
 */
- (void)receivedEditorPhotoInsertAck:(NSInteger)targetFrameIndex WithAck:(BOOL)insertAck;
/**
 상대방이 사진 정보를 삭제했을 때 호출된다.
 */
- (void)receivedEditorPhotoDelete:(NSInteger)targetFrameIndex;

/**
 상대방에 특정 그림 객체를 선택했을 때 호출된다.
 */
- (void)receivedEditorDecorateObjectEditing:(NSString *)identifier;
/**
 상대방이 특정 그림 객체를 선택해제했을 때 호출된다.
 */
- (void)receivedEditorDecorateObjectEditCancelled:(NSString *)identifier;
/**
 상대방이 그림 객체를 삽입했을 때 호출된다.
 */
- (void)receivedEditorDecorateObjectInsert:(id)insertData WithTimestamp:(NSNumber *)timestamp;
/**
 상대방이 그림 객체의 위치를 이동시켰을 때 호출된다.
 */
- (void)receivedEditorDecorateObjectMoved:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY;
/**
 상대방이 그림 객체의 크기를 변경했을 때 호출된다.
 */
- (void)receivedEditorDecorateObjectResized:(NSString *)identifier WithWidth:(CGFloat)width WithHeight:(CGFloat)height;
/**
 상대방이 그림 객체를 회전시켰을 때 호출된다.
 */
- (void)receivedEditorDecorateObjectRotated:(NSString *)identifier WithAngle:(CGFloat)angle;
/**
 상대방이 그림 객체의 Z-order를 변경했을 때 호출된다.
 */
- (void)receivedEditorDecorateObjectZOrderChanged:(NSString *)identifier;
/**
 상대방이 그림 객체를 삭제했을 때 호출된다.
 */
- (void)receivedEditorDecorateObjectDelete:(NSString *)identifier;
/**
 사진 편집에서 상대방이 연결을 끊었을 때 호출된다.
 receivedPeerDisconnected로 통폐합할 예정이다.
 */
- (void)receivedEditorDisconnected;

@end
