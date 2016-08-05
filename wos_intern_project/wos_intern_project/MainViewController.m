//
//  MainViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MainViewController.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "CommonConstants.h"

#import "ConnectionManager.h"
#import "MessageSyncManager.h"

#import "WMProgressHUD.h"
#import "PhotoFrameSelectViewController.h"
#import "PhotoEditorViewController.h"

typedef NS_ENUM(NSInteger, AlertType) {
    ALERT_ALBUM_AUTH = 0
};

@interface MainViewController () <MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, UIAlertViewDelegate, ConnectionManagerSessionConnectDelegate>

@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) WMProgressHUD *progressView;
@property (nonatomic, strong) NSArray *invitationHandlerArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupConnectionManager];
    [self setupBluetoothBrowser];
    [self setupBluetoothAdvertiser];
    [self setupGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startAdvertise];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopAdvertise];
}

- (void)setupConnectionManager {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionConnectDelegate = self;
}

- (void)setupBluetoothBrowser {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    self.browserViewController = [[MCBrowserViewController alloc] initWithServiceType:ApplicationBluetoothServiceType
                                                                              session:connectionManager.ownSession];
    //1:1 통신이므로 연결할 피어의 수는 하나로 제한한다.
    self.browserViewController.maximumNumberOfPeers = 1;
    self.browserViewController.delegate = self;
}

- (void)setupBluetoothAdvertiser {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:connectionManager.ownPeerId
                                                        discoveryInfo:nil serviceType:ApplicationBluetoothServiceType];
    self.advertiser.delegate = self;
}

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *tabGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(loadBrowserViewController)];
    tabGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tabGestureRecognizer];
    [self.view setUserInteractionEnabled:YES];
}

- (void)dealloc {
    [ConnectionManager sharedInstance].sessionConnectDelegate = nil;
    
    self.browserViewController.delegate = nil;
    self.browserViewController = nil;
    
    self.advertiser.delegate = nil;
    self.advertiser = nil;
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    self.progressView = nil;
    
}

     
#pragma mark - Load Other ViewController Methods

/**
 PhotoAlbumViewController를 호출한다.
 */
- (IBAction)loadPhotoAlbumViewController:(id)sender {
    [self performSegueWithIdentifier:SegueMoveToAlbum sender:self];
}

/**
 PhotoFrameViewController를 호출한다.
 */
- (void)loadPhotoFrameViewController {
    [self performSegueWithIdentifier:SegueMoveToFrameSelect sender:self];
}

/**
 BrowserViewController를 화면에 표시한다. 블루투스의 현재 상태를 확인하여, 블루투스가 켜지지 않은 상태라면 Alert를 표시한다.
 */
- (void)loadBrowserViewController {
    if (![self checkBluetoothState])
        return;
    
    [self presentViewController:self.browserViewController animated:YES completion:nil];
}


#pragma mark - Authority & Validate Check Methods

/**
 */
- (BOOL)checkBluetoothState {
    if ([[ConnectionManager sharedInstance] isBluetoothAvailable])
        return YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_off", nil)
                                                        message:NSLocalizedString(@"alert_content_bluetooth_off", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil)
                                              otherButtonTitles:nil, nil];
    [alertView show];
    
    return NO;
}

/**
 포토 앨범 접근 권한을 가지고 있는지 확인한다.
 */
- (BOOL)checkPhotoAlbumAccessAuthority {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (status == ALAuthorizationStatusNotDetermined || status == ALAuthorizationStatusAuthorized)
        return YES;
    
    //앨범 접근 권한 없음. 해당 Alert 표시.
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_album_not_authorized", nil)
                                                        message:NSLocalizedString(@"alert_content_album_not_authorized", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil)
                                              otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
    alertView.tag = ALERT_ALBUM_AUTH;
    [alertView show];
    
    return NO;
}


#pragma mark - Progress Methods

/**
 ProgressView에 승인 대기 중 메시지를 설정하여 띄운다.
 */
- (void)showWaitProgress {
    self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:NSLocalizedString(@"progress_title_connecting", nil)];
    [self.view setUserInteractionEnabled:NO];
}

/**
 ProgressView의 상태를 완료로 바꾼 뒤에 종료한다.
 */
- (void)doneProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:NSLocalizedString(@"progress_title_connected", nil) delay:DelayTime];
    }
}

/**
 ProgressView의 상태를 거절로 바꾼 뒤에 종료한다.
 */
- (void)rejectProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:NSLocalizedString(@"progress_title_rejected", nil) delay:DelayTime cancel:YES];
    }
}


#pragma mark - Bluetooth Advertiser Methods

/**
 다른 단말기가 자신의 단말기를 찾을 수 있게 하는 신호 송출을 시작한다.
 */
- (void)startAdvertise {
    if (self.advertiser != nil) {
        [self.advertiser startAdvertisingPeer];
    }
}

/**
 다른 단말기가 자신의 단말기를 찾을 수 있게 하는 신호 송출을 중단한다.
 */
- (void)stopAdvertise {
    if (self.advertiser != nil) {
        [self.advertiser stopAdvertisingPeer];
    }
}


#pragma mark - MCBrowserViewControllerDelegate Methods

//Session Connecte Done.
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES
                                              completion:nil];
}

//Session Connect Cancel.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES
                                              completion:nil];
    [[ConnectionManager sharedInstance] disconnectSession];
}


#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    self.invitationHandlerArray = [NSArray arrayWithObjects:[invitationHandler copy], nil];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_invitation_received", nil)
                                                        message:[NSString stringWithFormat:@"\"%@\" %@", peerID.displayName, NSLocalizedString(@"alert_content_invitation_received", nil)]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_text_decline", nil)
                                              otherButtonTitles:NSLocalizedString(@"alert_button_text_accept", nil), nil];
    [alertView show];
}


#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSInteger const Accepted = 1;
    
    //Accept
    if (buttonIndex == Accepted) {
        ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
        
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray firstObject];
        invitationHandler(YES, connectionManager.ownSession);
        
        [self showWaitProgress];
    //Decline
    } else {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray firstObject];
        invitationHandler(NO, [ConnectionManager sharedInstance].ownSession);
    }
}


#pragma mark - ConnectionManager Delegate Methods

- (void)receivedPeerConnected {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    //연결이 완료되면 자신의 단말기 화면 사이즈를 상대방에게 전송한다.
    NSDictionary *sendData = @{kDataType: @(vDataTypeScreenSize),
                                           kScreenWidth: @(connectionManager.ownScreenWidth),
                                           kScreenHeight: @(connectionManager.ownScreenHeight)};
    
    //메시지 큐 사용을 활성화한다.
    [[MessageSyncManager sharedInstance] setMessageQueueEnabled:YES];
    [connectionManager sendData:sendData];
    
    if ([self.navigationController presentedViewController] == self.browserViewController) {
        [self.view setUserInteractionEnabled:NO];
        [self.browserViewController dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadPhotoFrameViewController];
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneProgress];
        });
        
        //ProgressView의 상태가 바뀌어서 사용자에게 보여질정도의 충분한 시간(delay) 뒤에 PhotoFrameSelectViewController를 호출하도록 한다.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DelayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadPhotoFrameViewController];
        });
    }
}

- (void)receivedPeerDisconnected {
    [[ConnectionManager sharedInstance] disconnectSession];
    
    if ([self.navigationController presentedViewController] != self.browserViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rejectProgress];
        });
    }
}

@end
