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
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_CONNECTED;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_DISCONNECTED;

/** Screen Size Data Protocol String ... **/
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_SCREEN_SIZE;

@property (nonatomic, readonly) NSNumber *VALUE_DATA_TYPE_SCREEN_SIZE;

@property (nonatomic, copy, readonly) NSString *KEY_SCREEN_SIZE_WIDTH;
@property (nonatomic, copy, readonly) NSString *KEY_SCREEN_SIZE_HEIGHT;

/** PhotoFrame Data Protocol String ... **/
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_PHOTO_FRAME_INDEX;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_PHOTO_FRAME_LIKED;
@property (nonatomic, copy, readonly) NSString *NOTIFICATION_RECV_PHOTO_FRAME_SELECTED;

@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_FRAME_INDEX;
@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_FRAME_LIKED;
@property (nonatomic, strong, readonly) NSNumber *VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED;

@property (nonatomic, copy, readonly) NSString *KEY_FRAME_INDEX;
@property (nonatomic, copy, readonly) NSString *KEY_FRAME_LIKED;
@property (nonatomic, copy, readonly) NSString *KEY_FRAME_SELECTED;

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

- (void)initInstanceProperties:(NSString *)deviceName screenWidthSize:(CGFloat)width screenHeightSize:(CGFloat)height;

- (void)startAdvertise;
- (void)stopAdvertise;

- (void)setConnectedPeerScreenWidthWith:(NSNumber *)width connectedPeerScreenHeight:(NSNumber *)height;

@end
