//
//  BluetoothAdvertiser.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol BluetoothAdvertiserDelegate;

@interface BluetoothAdvertiser : NSObject

@property (weak, nonatomic) id<BluetoothAdvertiserDelegate> delegate;

/**
 * @brief Advertiser 객체를 초기화한다.
 * @param serviceType : 검색 신호 발신 시, 사용할 서비스타입 문자열
 * @param session : 연결에 사용할 세션 객체
 * @return BluetoothAdvertiser : 생성된 Advertiser 객체
 */
- (instancetype)initWithServiceType:(NSString *)serviceType session:(MCSession *)session;

/**
 * @brief Advertising를 시작해서 주위에 검색 신호를 발신한다.
 */
- (void)startAdvertise;

/**
 * @brief Advertising를 중지한다.
 */
- (void)stopAdvertise;

@end

/**
 * @brief BluetoothAdvertiser의 델리게이트 프로토콜이다.
 *        MCNearbyServiceAdvertiser의 델리게이트 메소드가 호출되었을 때, 이를 외부로 전파하기 위하여 사용한다.
 *          didNotStartAdvertising         : didNotStartAdvertisingPeer에 대응된다. adverising에 실패했을 때 호출된다.
 *          didReceiveInvitationWithPeerId : didReceiveInvitationFromPeer에 대응된다. 초대장을 받았을 때 호출된다.
 *
 *        ConnectionManagerSessionDelegate의 델리게이트 메소드가 호출되었을 때, 이를 외부로 전파하기 위하여 사용된다.
 *          advertiserSessionConnected     : receviedPeerConnected애 대응된다. 세션이 연결되었을 때 호출된다.
 *          advertiserSessionNotConnected  : receviedPeerDisconnected애 대응된다. 세션 연결이 되지 않았을 때 호출된다.
 */
@protocol BluetoothAdvertiserDelegate <NSObject>
@required
- (void)didNotStartAdvertising;
- (void)didReceiveInvitationWithPeerName:(NSString *)peerName
                     invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler;
- (void)advertiserSessionConnected;
- (void)advertiserSessionNotConnected;

@end