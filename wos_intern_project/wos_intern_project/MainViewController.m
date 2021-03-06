//
//  MainViewController.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MainViewController.h"
#import "SelectPhotoFrameViewController.h"

#import "PESessionManager.h"
#import "PEBluetoothSession.h"

#import "BluetoothBrowser.h"
#import "BluetoothAdvertiser.h"

#import "AlertHelper.h"
#import "ProgressHelper.h"

NSString *const SegueMoveToFrameSelect = @"moveToPhotoFrameSelect";

@interface MainViewController () <BluetoothBrowserDelegate, BluetoothAdvertiserDelegate>

@property (nonatomic, strong) WMProgressHUD *progressView;

@end

@implementation MainViewController


#pragma mark - Life Cyle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTapGestureRecognizerOnBackgroundView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self prepareSession];
    [self.view setUserInteractionEnabled:YES];
}

- (void)dealloc {
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    self.progressView = nil;
}


#pragma mark - Prepare Session

- (void)prepareSession {
    PESessionManager *sessionManager = [PESessionManager sharedInstance];
    
    if ([sessionManager isSessionNil]) {
        [sessionManager initializeWithSessionType:SessionTypeBluetooth];
        
        if (sessionManager.session.sessionType == SessionTypeBluetooth) {
            PEBluetoothSession *session = (PEBluetoothSession *)sessionManager.session;
            
            if ([session prepareAdvertiser:self]) {
                [session startBluetoothAdvertise];
                return;
            }
            
            //블루투스가 비활성화된 경우 NO를 리턴하며, 이에 대한 처리가 필요하다.
            [AlertHelper showAlertControllerOnViewController:self
                                                    titleKey:@"alert_title_bluetooth_disabled"
                                                  messageKey:@"alert_content_bluetooth_disabled"
                                                      button:@"alert_button_text_ok"
                                               buttonHandler:nil];
        }
    }
}


#pragma mark - EventHandling

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self.view setUserInteractionEnabled:NO];
        [self presentBrowserViewController];
    }
}

/**
 * @brief 백그라운드 뷰(self.view)를 탭했을 때 대응할 EventHandler를 등록한다.
 */
- (void)addTapGestureRecognizerOnBackgroundView {
    UIView *view = self.view;
    
    UITapGestureRecognizer *tabGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(presentBrowserViewController)];
    [view addGestureRecognizer:tabGestureRecognizer];
    [view setUserInteractionEnabled:YES];
}


#pragma mark - Present ViewController

/**
 * @brief 장비를 검색하고 연결할 VC를 화면에 표시한다.
 */
- (void)presentBrowserViewController {
    PEBluetoothSession *session = (PEBluetoothSession *)[PESessionManager sharedInstance].session;
    if ([session presentBrowserController:self delegate:self]) {
        return;
    }
    
    //블루투스가 비활성화된 경우 NO를 리턴하며, 이에 대한 처리가 필요하다.
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_bluetooth_disabled"
                                          messageKey:@"alert_content_bluetooth_disabled"
                                              button:@"alert_button_text_ok"
                                       buttonHandler:nil];
}

/**
 * @brief 사진액자를 선택할 VC를 화면에 표시한다.
 */
- (void)presentSelectPhotoFrameViewController {
    PESessionManager *sessionManager = [PESessionManager sharedInstance];
    [sessionManager.messageReceiver setMessageBufferEnabled:YES];
    
    PEBluetoothSession *session = (PEBluetoothSession *)sessionManager.session;
    [session clearBluetoothBrowser];
    
    [session stopBluetoothAdvertise];
    [session clearBluetoothAdvertiser];
    
    [self performSegueWithIdentifier:SegueMoveToFrameSelect sender:self];
}


#pragma mark - Bluetooth Browser Delegate Methods

- (void)browserSessionConnected:(BluetoothBrowser *)browser {
    __weak typeof(self) weakSelf = self;
    [browser dismissBrowserViewController:^{
        __strong typeof(weakSelf) self = weakSelf;
        
        if (!self) {
            return;
        }
        
        [self presentSelectPhotoFrameViewController];
    }];
}

- (void)browserSessionConnectCancel:(BluetoothBrowser *)browser {
    [browser dismissBrowserViewController:^{
        PESessionManager *sessionManager = [PESessionManager sharedInstance];
        [sessionManager disconnectSession];
        [self prepareSession];
    }];
}


#pragma mark - Bluetooth Advertiser Delegate Methods

//Error Handling Method
- (void)didNotStartAdvertising {
    //Alert 표시하고, 확인 누르면 Assert.
}

- (void)didReceiveInvitationWithPeerName:(NSString *)peerName invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    NSString *message = [NSString stringWithFormat:@"\"%@\" %@", peerName,
                         NSLocalizedString(@"alert_content_invitation_received", nil)];
    
    __weak typeof(self) weakSelf = self;
    [AlertHelper showAlertControllerOnViewController:self
                                               title:NSLocalizedString(@"alert_title_invitation_received", nil)
                                             message:message
                                              button:@"alert_button_text_decline"
                                       buttonHandler:^(UIAlertAction * _Nonnull action) {
                                           PEBluetoothSession *session = (PEBluetoothSession *)[PESessionManager sharedInstance].session;
                                           invitationHandler(NO, [session instanceOfSession]);
                                       }
                                         otherButton:@"alert_button_text_accept"
                                  otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                      __strong typeof(weakSelf) self = weakSelf;
                                      
                                      if (!self) {
                                          return;
                                      }
                                      
                                      PEBluetoothSession *session = (PEBluetoothSession *)[PESessionManager sharedInstance].session;
                                      invitationHandler(YES, [session instanceOfSession]);
                                      
                                      self.progressView = [ProgressHelper showProgressAddedTo:self.navigationController.view titleKey:@"progress_title_connecting"];
                                      [self.view setUserInteractionEnabled:NO];
                                  }];
}

- (void)advertiserSessionConnected {
    //ProgressView가 nil이거나 숨겨진 상태라면, 초대장을 받은 정상적인 Advertiser가 아님.
    //BrowserVC 진입 후, 초대장 발송한 뒤 바로 취소버튼을 눌러 MainVC로 돌아온 뒤에 상대방에게 보냈던 초대장에 대한 응답을 받은 경우에 해당함.
    if (!self.progressView || self.progressView.hidden) {
        [[PESessionManager sharedInstance] disconnectSession];
        
        [self prepareSession];
        [self.view setUserInteractionEnabled:YES];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [ProgressHelper dismissProgress:self.progressView
                    dismissTitleKey:@"progress_title_connected"
                        dismissType:DismissWithDone completionHandler:^{
                            __strong typeof(weakSelf) self = weakSelf;
                            
                            if (!self) {
                                return;
                            }
                            
                            if ([PESessionManager sharedInstance].session.sessionState != SessionStateConnected) {
                                return;
                            }
                            
                            [self presentSelectPhotoFrameViewController];
                        }
     ];
}

- (void)advertiserSessionNotConnected {
    if (!self.progressView || self.progressView.hidden) {
        [[PESessionManager sharedInstance] disconnectSession];
        
        [self prepareSession];
        [self.view setUserInteractionEnabled:YES];
        return;
    }
    
    [ProgressHelper dismissProgress:self.progressView
                    dismissTitleKey:@"progress_title_cancelled"
                        dismissType:DismissWithCancel
                  completionHandler:^{
                      PESessionManager *sessionManager = [PESessionManager sharedInstance];
                      [sessionManager disconnectSession];
                      
                      [self prepareSession];
                      [self.view setUserInteractionEnabled:YES];
                  }
     ];
}

@end
