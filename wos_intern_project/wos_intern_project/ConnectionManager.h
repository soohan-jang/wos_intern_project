//
//  ConnectionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol ConnectionManagerSessionDelegate;

@protocol ConnectionManagerPhotoFrameDataDelegate;
@protocol ConnectionManagerPhotoFrameControlDelegate;

@protocol ConnectionManagerPhotoDataDelegate;
@protocol ConnectionManagerDecorateDataDelegate;

@interface ConnectionManager : NSObject <MCSessionDelegate, CBCentralManagerDelegate>

@property (nonatomic, weak) id<ConnectionManagerSessionDelegate> sessionDelegate;

@property (nonatomic, weak) id<ConnectionManagerPhotoFrameDataDelegate> photoFrameDataDelegate;
@property (nonatomic, weak) id<ConnectionManagerPhotoFrameControlDelegate> photoFrameControlDelegate;

@property (nonatomic, weak) id<ConnectionManagerPhotoDataDelegate> photoDataDelegate;
@property (nonatomic, weak) id<ConnectionManagerDecorateDataDelegate> decorateDataDelegate;

@property (nonatomic, assign) BOOL messageQueueEnabled;

@property (nonatomic, assign) NSInteger sessionState;
@property (nonatomic, strong, readonly) MCPeerID *ownPeerId;
@property (nonatomic, strong, readonly) MCSession *ownSession;

@property (nonatomic, assign, readonly) CGFloat widthRatio, heightRatio;

/**
 @breif
 싱글턴 인스턴스를 가져온다.
 */
+ (ConnectionManager *)sharedInstance;

/**
 @breif
 블루투스를 사용할 수 있는 상태인지를 확인한다.
 */
- (BOOL)isBluetoothAvailable;

/**
 ConnectionManager가 관리하는 MCSession 객체를 이용하여 메시지를 보낸다. 메시지의 범위는 연결된 모든 피어를 대상으로 전파된다.
 */
- (void)sendMessage:(NSDictionary *)message;

/**
 ConnectionManager가 관리하는 MCSession 객체를 이용하여 전달받은 이미지 파일을 보낸다. 메시지의 범위는 연결된 모든 피어를 대상으로 전파된다.
 */
- (void)sendPhotoDataWithFilename:(NSString *)filename fullscreenImageURL:(NSURL *)fullscreenImageURL croppedImageURL:(NSURL *)croppedImageURL index:(NSInteger)index;

/**
 Session의 연결을 해제한다.
 */
- (void)disconnectSession;

/**
 ConnectionManager의 모든 값을 삭제한다.
 */
- (void)clear;

/**
 Message Queue에 메시지를 저장한다. 메시지는 MessageQueue의 맨 끝에 저장된다.
 */
- (void)putMessage:(NSDictionary *)message;

/**
 Message Queue에서 메시지를 가져온다. 맨 앞의 정보(index 0)를 가져오며, 가져온 정보는 Message Queue에서 제거한다.
 */
- (NSDictionary *)getMessage;

/**
 Message Queue에 저장된 메시지를 비운다.
 */
- (void)clearMessageQueue;

/**
 Message Queue가 비어있는지 여부를 반환한다.
 */
- (BOOL)isMessageQueueEmpty;

@end


#pragma mark - ConnectionManagerSessionDelegate

/**
 MCSessionDelegate를 전파하기 위한 ConnectionManager의 Delegate이다.
 MCSessionDelegate에 전달되는 값을 확인하여, 세분화한 뒤 그에 해당하는 Delegate로 메시지를 전달한다.
 */
@protocol ConnectionManagerSessionDelegate <NSObject>
@required
/**
 Peer가 연결되었을 때  호출된다. didStateChanged에 의해 호출된다.
 */
- (void)receivedPeerConnected;

/**
 Peer가 연결해제되었을 때 호출된다. didStateChanged에 의해 호출된다.
 */
- (void)receivedPeerDisconnected;

@end


#pragma mark - ConnectionManagerFrameSelectDelegate

@protocol ConnectionManagerPhotoFrameControlDelegate <NSObject>
@required
/**
 상대방이 사진 액자를 최종적으로 선택한 것에 대한 동의 여부에 응답했을 때 호출된다.
 */
- (void)receivedPhotoFrameConfirmAck:(BOOL)confirmAck;

/**
 현재 사용자의 작업을 취소하기 위해 호출된다.
 */
- (void)interruptedPhotoFrameConfirmProgress;

@end


#pragma mark - ConnectionManagerFrameSelectDataDelegate

@protocol ConnectionManagerPhotoFrameDataDelegate <NSObject>
@required
/**
 선택된 사진 액자의 종류를 받았을 때 호출된다. 여기서의 사진 액자는 전체 사진 액자의 틀을 의미한다.
 */
- (void)receivedPhotoFrameSelected:(NSIndexPath *)indexPath;

/**
 상대방이 현재 선택한 사진 액자를 최종적하기 위해 동의 여부를 물어볼 때 호출된다.
 */
- (void)receivedPhotoFrameRequestConfirm:(NSIndexPath *)confirmIndexPath;

@end


#pragma mark - ConnectionManagerPhotoDataDelegate

@protocol ConnectionManagerPhotoDataDelegate <NSObject>
@required
/**
 상대방이 특정 사진 액자 영역을 선택했을 때 호출된다.
 */
- (void)receivedEditorPhotoEditing:(NSIndexPath *)indexPath;

/**
 상대방이 특정 사진 액자 영역을 선택 해제했을 때 호출된다.
 */
- (void)receivedEditorPhotoEditingCancelled:(NSIndexPath *)indexPath;

/**
 상대방이 특정 사진 액자 영역에 사진을 삽입했을 때 호출된다.
 사진이 삽입되었을 때 내부적으로 sendResourceAtURL을 2번 호출되는데, 어느 사진 액자 영역에 삽입될 지/현재 전달받은 사진 정보가 무엇인지/사진 정보가 저장된 URL을 전달한다.
 우선적으로 CroppedImage를 먼저 보내고, CroppedImage 전송이 종료되면 FullscreenImage를 전송한다.
 */
- (void)receivedEditorPhotoInsert:(NSIndexPath *)indexPath type:(NSString *)type url:(NSURL *)url;

/**
 상대방이 사진 정보를 모두 수신한 뒤에 이 여부를 전달했을 때 호출된다.
 */
- (void)receivedEditorPhotoInsertAck:(NSIndexPath *)indexPath ack:(BOOL)insertAck;

/**
 상대방이 사진 정보를 삭제했을 때 호출된다.
 */
- (void)receivedEditorPhotoDeleted:(NSIndexPath *)indexPath;

/**
 현재 사용자의 작업을 취소하기 위해 호출된다.
 */
- (void)interruptedEditorPhotoEditing:(NSIndexPath *)indexPath;

@end


#pragma mark - ConnectionManagerDecorateDataDelegate

@protocol ConnectionManagerDecorateDataDelegate <NSObject>
@required
/**
 상대방에 특정 그림 객체를 선택했을 때 호출된다.
 */
- (void)receivedEditorDecorateDataEditing:(NSInteger)index;

/**
 상대방이 특정 그림 객체를 선택해제했을 때 호출된다.
 */
- (void)receivedEditorDecorateDataEditCancelled:(NSInteger)index;

/**
 상대방이 그림 객체를 삽입했을 때 호출된다.
 */
- (void)receivedEditorDecorateDataInsert:(UIImage *)insertData scale:(CGFloat)scale timestamp:(NSNumber *)timestamp;

/**
 상대방이 그림 객체의 위치를 이동시켰을 때 호출된다.
 */
- (void)receivedEditorDecorateDataMoved:(NSInteger)index movedPoint:(CGPoint)point;

/**
 상대방이 그림 객체의 크기를 변경했을 때 호출된다.
 */
- (void)receivedEditorDecorateDataResized:(NSInteger)index resizedRect:(CGRect)rect;

/**
 상대방이 그림 객체를 회전시켰을 때 호출된다.
 */
- (void)receivedEditorDecorateDataRotated:(NSInteger)index rotatedAngle:(CGFloat)angle;

/**
 상대방이 그림 객체의 Z-order를 변경했을 때 호출된다.
 */
- (void)receivedEditorDecorateDataZOrderChanged:(NSInteger)index;

/**
 상대방이 그림 객체를 삭제했을 때 호출된다.
 */
- (void)receivedEditorDecorateDataDeleted:(NSNumber *)timestamp;

/**
 현재 사용자의 작업을 취소하기 위해 호출된다.
 */
- (void)interruptedEditorDecorateDataEditing;

@end