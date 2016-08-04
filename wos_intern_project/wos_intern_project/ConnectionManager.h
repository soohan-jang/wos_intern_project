//
//  ConnectionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "CommonConstants.h"
#import "ConnectionManagerConstants.h"

#import "MessageSyncManager.h"
#import "ImageUtility.h"

@protocol ConnectionManagerDelegate;

@interface ConnectionManager : NSObject <MCSessionDelegate, CBCentralManagerDelegate>

@property (nonatomic, weak) id<ConnectionManagerDelegate> delegate;

/**
 싱글턴 인스턴스를 가져온다.
 */
+ (ConnectionManager *)sharedInstance;

/**
 ConnectionManager에서 관리되는 MCPeerID를 반환한다.
 */
- (MCPeerID *)getOwnPeerID;

/**
 ConnectionManager에서 관리되는 MCSession를 반환한다.
 */
- (MCSession *)getSession;

/**
 ConnectionManager에서 관리되는 ScreenSize를 반환한다.
 */
- (CGSize)getScreenSize;

/**
 현재 블루투스 하드웨어의 상태를 가져온다. 반환값은 CBCentralManagerState의 값이 전달된다.
 */
- (NSInteger)getBluetoothState;

/**
 ConnectionManager가 관리하는 MCSession 객체를 이용하여 메시지를 보낸다. 메시지의 범위는 연결된 모든 피어를 대상으로 전파된다.
 */
- (void)sendData:(NSData *)sendData;

/**
 ConnectionManager가 관리하는 MCSession 객체를 이용하여 전달받은 이미지 파일을 보낸다. 메시지의 범위는 연결된 모든 피어를 대상으로 전파된다.
 */
- (void)sendPhotoDataWithFilename:(NSString *)filename WithFullscreenImageURL:(NSURL *)fullscreenImageURL WithCroppedImageURL:(NSURL *)croppedImageURL WithIndex:(NSInteger)index;

/**
 Session의 연결을 해제한다.
 */
- (void)disconnectSession;

/**
 ConnectionManager의 모든 값을 삭제한다.
 */
- (void)clear;

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
