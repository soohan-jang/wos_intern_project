//
//  MainViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ConnectionManager.h"
#import "PhotoFrameSelectViewController.h"

@interface MainViewController : UIViewController <MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *invitationHandlerArray;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) BOOL isBrowser;
@property (nonatomic) BOOL isAdvertiser;

/**
 NotificationCenter에 필요한 Observer를 등록한다.
 세션연결, 세션연결해제, 상대방 화면크기 수신을 처리하기 위한 Observer를 등록한다.
 */
- (void)addObservers;

/**
 NotificationCenter에 등록한 Observer를 등록해제한다.
 세션연결, 세션연결해제, 상대방 화면크기 수신을 처리하기 위한 Observer를 등록해제한다.
 */
- (void)removeObservers;

/**
 세션이 연결되었을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedSessionConnected:(NSNotification *)notification;

/**
 세션이 연결해제되었을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedSessionDisconnected:(NSNotification *)notification;

/**
 상대방 단말의 화면크기를 수신했을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedScreenSize:(NSNotification *)notification;
@end

