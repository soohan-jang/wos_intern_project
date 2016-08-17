//
//  MainViewController.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MainViewController.h"

#import "CommonConstants.h"

#import "ConnectionManager.h"
#import "BluetoothBrowser.h"
#import "BluetoothAdvertiser.h"
#import "ValidateCheckUtility.h"

#import "PhotoFrameSelectViewController.h"
#import "PhotoEditorViewController.h"

#import "ProgressHelper.h"
#import "AlertHelper.h"
#import "DispatchAsyncHelper.h"
#import "MessageFactory.h"

@interface MainViewController () <BluetoothBrowserDelegate, BluetoothAdvertiserDelegate>

@property (strong, nonatomic) BluetoothBrowser *browser;
@property (strong, nonatomic) BluetoothAdvertiser *advertiser;

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
    
    [self prepareAdvertiser];
    [self.view setUserInteractionEnabled:YES];
}

- (void)dealloc {
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    self.browser.delegate = nil;
    self.browser = nil;
    
    self.advertiser.delegate = nil;
    self.advertiser = nil;
    
    self.progressView = nil;
}


#pragma mark - Prepare & Clear Bluetooth Connection

/**
 * @brief 장비를 검색하고 연결을 시도할 때 사용하는 Browser를 생성하고, delegate를 등록한다.
 */
- (void)prepareBrowser {
    if (self.browser) {
        return;
    }
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    self.browser = [[BluetoothBrowser alloc] initWithServiceType:ConnectionManagerServiceType
                                                     session:connectionManager.ownSession];
    self.browser.delegate = self;
}

/**
 * @brief 장비 검색을 활성화시키는 Advertiser를 생성하고, delegate를 등록한다.
 */
- (void)prepareAdvertiser {
    if (self.advertiser) {
        return;
    }
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    self.advertiser = [[BluetoothAdvertiser alloc] initWithServiceType:ConnectionManagerServiceType
                                                            peerId:connectionManager.ownPeerId];
    self.advertiser.delegate = self;
    
    [self.advertiser advertiseStart];
}

/**
 * @brief 장비를 검색하고 연결을 시도할 때 사용하는 Browser를 제거한다.
 */
- (void)clearBrowser {
    self.browser.delegate = nil;
    self.browser = nil;
}

/**
 * @brief 장비 검색을 활성화시키는 Advertiser를 제거한다.
 */
- (void)clearAdvertiser {
    self.advertiser.delegate = nil;
    self.advertiser = nil;
}


#pragma mark - EventHandling

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
    [self prepareBrowser];
    if ([self.browser presentBrowserViewController:self]) {
        [self.advertiser advertiseStop];
        return;
    }
    
    //블루투스가 비활성화된 경우 NO를 리턴하며, 이에 대한 처리가 필요하다.
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_bluetooth_off"
                                          messageKey:@"alert_content_bluetooth_off"
                                              button:@"alert_button_text_ok"
                                       buttonHandler:nil];
}

/**
 * @brief 사진액자를 선택할 VC를 화면에 표시한다.
 */
- (void)presentFrameSelectViewController {
    [self clearBrowser];
    [self clearAdvertiser];
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    [connectionManager clearMessageQueue];
    [connectionManager setMessageQueueEnabled:YES];
    
    [self performSegueWithIdentifier:SegueMoveToFrameSelect sender:self];
}


#pragma mark - Bluetooth Browser Methods

- (void)browserSessionConnected {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self presentFrameSelectViewController];
    }];
}

- (void)browserSessionNotConnected {
    [self.advertiser advertiseStart];
}


#pragma mark - Bluetooth Advertiser Methods

//Error Handling Method
- (void)didNotStartAdvertising {
    //Alert 표시하고, 확인 누르면 Assert.
}

- (void)didReceiveInvitationWithPeerId:(MCPeerID *)peerID invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    NSString *message = [NSString stringWithFormat:@"\"%@\" %@", peerID.displayName,
                                                                 NSLocalizedString(@"alert_content_invitation_received", nil)];
    
    __weak typeof(self) weakSelf = self;
    [AlertHelper showAlertControllerOnViewController:self
                                               title:NSLocalizedString(@"alert_title_invitation_received", nil)
                                             message:message
                                              button:@"alert_button_text_decline"
                                       buttonHandler:^(UIAlertAction * _Nonnull action) {
                                           invitationHandler(NO, [ConnectionManager sharedInstance].ownSession);
                                       }
                                         otherButton:@"alert_button_text_accept"
                                  otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                      __strong typeof(weakSelf) self = weakSelf;
                                      invitationHandler(YES, [ConnectionManager sharedInstance].ownSession);
                                      self.progressView = [ProgressHelper showProgressAddedTo:self.view titleKey:@"progress_title_connecting"];
                                      [self.view setUserInteractionEnabled:NO];
                                  }];
}

- (void)advertiserSessionConnected {
    //ProgressView가 nil이거나 숨겨진 상태라면, 초대장을 받은 정상적인 Advertiser가 아님.
    //BrowserVC 진입 후, 초대장 발송한 뒤 바로 취소버튼을 눌러 MainVC로 돌아온 뒤에 상대방에게 보냈던 초대장에 대한 응답을 받은 경우에 해당함.
    if (!self.progressView || self.progressView.hidden) {
        ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
        [connectionManager setMessageQueueEnabled:NO];
        [connectionManager disconnectSession];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        
        [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_connected" dismissType:DismissWithDone];
    }];
    
    //ProgressView의 상태가 바뀌어서 사용자에게 보여질정도의 충분한 시간(delay) 뒤에 PhotoFrameSelectViewController를 호출하도록 한다.
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        
        [self presentFrameSelectViewController];
    } delay:DelayTime];
}

- (void)advertiserSessionNotConnected {
    if (!_progressView || _progressView.hidden) {
        ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
        [connectionManager setMessageQueueEnabled:NO];
        [connectionManager disconnectSession];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        
        if (!self.progressView.isHidden) {
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_rejected" dismissType:DismissWithDone];
        }
        
        [[ConnectionManager sharedInstance] disconnectSession];
    }];
}

@end
