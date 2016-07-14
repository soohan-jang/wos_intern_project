//
//  MainViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ConnectionManager.h"
#import "PhotoFrameSelectViewController.h"
#import "WMProgressHUD.h"

@interface MainViewController : UIViewController <MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, UIAlertViewDelegate, CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (nonatomic) BOOL isBluetoothUnsupported;

@property (nonatomic, strong) WMProgressHUD *progressView;
@property (nonatomic, strong) NSArray *invitationHandlerArray;

@property (nonatomic) CGPoint startPoint;

/**
 NotificationCenter에 필요한 Observer를 등록한다.
 세션연결, 세션연결해제를 처리하기 위한 Observer를 등록한다.
 */
- (void)addObservers;

/**
 NotificationCenter에 등록한 Observer를 등록해제한다.
 세션연결, 세션연결해제를 처리하기 위한 Observer를 등록해제한다.
 */
- (void)removeObservers;

/**
 ProgressView의 상태를 완료로 바꾼 뒤에 종료한다.
 Main Thread에서 호출하기 위한 performSelector 용도의 함수이다.
 */
- (void)doneProgress;

/**
 PhotoFrame ViewController를 호출한다.
 Main Thread에서 호출하기 위한 performSelector 용도의 함수이다.
 ...
 NotificationCenter로 호출되는 함수에서 ViewController를 호출헀더니, Thread가 구분되는지 딜레이가 심하게 발생한다.
 이를 방지하기 위하여 main thread에서 ViewController를 호출할 수 있도록 따로 함수를 만들었다.
 */
- (void)loadPhotoFrameViewController;

/**
 세션이 연결되었을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedSessionConnected:(NSNotification *)notification;

/**
 세션이 연결해제되었을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedSessionDisconnected:(NSNotification *)notification;
@end

