//
//  BluetoothBrowser.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "PEBluetoothSession.h"

@protocol BluetoothBrowserDelegate;

@interface BluetoothBrowser : NSObject

@property (weak, nonatomic) id<BluetoothBrowserDelegate> delegate;

/**
 * @brief Browser 객체를 초기화한다.
 * @param serviceType : 검색 시에 사용할 서비스타입 문자열
 * @param session : 연결에 사용할 세션 객체
 * @return BluetoothBrowser : 생성된 Browser 객체
 */
- (instancetype)initWithServiceType:(NSString *)serviceType session:(PEBluetoothSession *)session;

/**
 * @brief 단말을 검색하고 연결을 시도할 수 있는 BrowserVC를 표시한다.
 * @param parentViewController : 표시될 BrowserVC의 부모 VC
 * @return BOOL : 현재 블루투스의 상태를 확인한 뒤, 정상적으로 표시가 되면 YES를 리턴한다. 아닐 경우 NO를 리턴한다.
 */
- (BOOL)presentBrowserViewController:(UIViewController *)parentViewController;

@end

/**
 * @brief BluetoothBrowser의 델리게이트 프로토콜이다.
 *        ConnectionManagerSessionDelegate의 델리게이트 메소드가 호출되었을 때, 이를 외부로 전파하기 위하여 사용한다.
 *        browserSessionConnected    : receviedPeerConnected애 대응된다. 세션이 연결되었을 때 호출된다.
 *        browserSessionNotConnected : receviedPeerDisconnected애 대응된다. 세션 연결이 되지 않았을 때 호출된다.
 */
@protocol BluetoothBrowserDelegate <NSObject>
@required
- (void)browserSessionConnected;
- (void)browserSessionNotConnected;

@end