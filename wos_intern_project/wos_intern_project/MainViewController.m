//
//  MainViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MainViewController.h"

#import "CommonConstants.h"
#import "ConnectionManagerConstants.h"

#import "ConnectionManager.h"
#import "MessageSyncManager.h"
#import "ValidateCheckUtility.h"

#import "PhotoFrameSelectViewController.h"
#import "PhotoEditorViewController.h"

#import "ProgressHelper.h"
#import "AlertHelper.h"

@interface MainViewController () <MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, ConnectionManagerSessionConnectDelegate>

@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) WMProgressHUD *progressView;
@property (nonatomic, strong) NSArray *invitationHandlerArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBluetoothBrowser];
    [self setupBluetoothAdvertiser];
    [self setupGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupConnectionManager];
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
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    if ([connectionManager isBluetoothAvailable]) {
        if ([ValidateCheckUtility checkPhotoAlbumAccessAuthority]) {
            [self presentViewController:self.browserViewController animated:YES completion:nil];
            return;
        }
        
        //앨범 접근 권한 없음. 해당 Alert 표시.
        UIAlertController *albumAuthAlert = [AlertHelper createAlertControllerWithTitleKey:@"alert_title_album_not_authorized"
                                                                                messageKey:@"alert_content_album_not_authorized"];
        //NO 버튼 터치 시, 그냥 닫는다.
        [AlertHelper addButtonOnAlertController:albumAuthAlert titleKey:@"alert_button_text_no" handler:^(UIAlertAction * _Nonnull action) {
            [AlertHelper dismissAlertController:albumAuthAlert];
        }];
        //YES 버튼 터치 시, 설정 화면으로 이동한다.
        [AlertHelper addButtonOnAlertController:albumAuthAlert titleKey:@"alert_button_text_yes" handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            [AlertHelper dismissAlertController:albumAuthAlert];
        }];
        //AlertController를 화면에 표시한다.
        [AlertHelper showAlertControllerOnViewController:self alertController:albumAuthAlert];
    }
    
    UIAlertController *bluetoothAlert = [AlertHelper createAlertControllerWithTitleKey:@"alert_title_bluetooth_off"
                                                                            messageKey:@"alert_content_bluetooth_off"];
    //블루투스를 활성화시키라고 알리는 것이 주목적이므로, OK 버튼 터치 시, 그냥 닫는다.
    [AlertHelper addButtonOnAlertController:bluetoothAlert titleKey:@"alert_button_text_ok" handler:^(UIAlertAction * _Nonnull action) {
       [AlertHelper dismissAlertController:bluetoothAlert];
    }];
    //AlertController를 화면에 표시한다.
    [AlertHelper showAlertControllerOnViewController:self alertController:bluetoothAlert];
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
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

//Session Connect Cancel.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    [[ConnectionManager sharedInstance] disconnectSession];
}


#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    self.invitationHandlerArray = [NSArray arrayWithObjects:[invitationHandler copy], nil];
    
    UIAlertController *invitationAlert = [AlertHelper createAlertControllerWithTitle:NSLocalizedString(@"alert_title_invitation_received", nil)
                                                                             message:[NSString stringWithFormat:@"\"%@\" %@", peerID.displayName, NSLocalizedString(@"alert_content_invitation_received", nil)]];
    //NO 버튼 터치 시, 거절 정보를 상대방에게 전송한다.
    [AlertHelper addButtonOnAlertController:invitationAlert titleKey:@"alert_button_text_decline" handler:^(UIAlertAction * _Nonnull action) {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray firstObject];
        invitationHandler(NO, [ConnectionManager sharedInstance].ownSession);
        
        [AlertHelper dismissAlertController:invitationAlert];
    }];
    //YES 버튼 터치 시, 승인 정보를 상대방에게 전송한다.
    [AlertHelper addButtonOnAlertController:invitationAlert titleKey:@"alert_button_text_accept" handler:^(UIAlertAction * _Nonnull action) {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray firstObject];
        invitationHandler(YES, [ConnectionManager sharedInstance].ownSession);
        
        self.progressView = [ProgressHelper showProgressAddedTo:self.view titleKey:@"progress_title_connecting"];
        [AlertHelper dismissAlertController:invitationAlert];
    }];
    //AlertController를 화면에 표시한다.
    [AlertHelper showAlertControllerOnViewController:self alertController:invitationAlert];
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
    
    __weak typeof(self) weakSelf = self;
    if ([self.navigationController presentedViewController] == self.browserViewController) {
        [self.browserViewController dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadPhotoFrameViewController];
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_connected" dismissType:DismissWithDone];
        });
        
        //ProgressView의 상태가 바뀌어서 사용자에게 보여질정도의 충분한 시간(delay) 뒤에 PhotoFrameSelectViewController를 호출하도록 한다.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DelayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadPhotoFrameViewController];
        });
    }
}

- (void)receivedPeerDisconnected {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.progressView.isHidden) {
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_rejected" dismissType:DismissWithDone];
        }
    });
    
    [[ConnectionManager sharedInstance] disconnectSession];
}

@end
