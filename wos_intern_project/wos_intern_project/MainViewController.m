//
//  MainViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MainViewController.h"

NSString *const NOTIFICATION_POP_ROOT_VIEW_CONTROLLER = @"popRootViewController";

#define DELAY_TIME  1.0f

@interface MainViewController ()

@property (nonatomic, strong) ConnectionManager *connectionManager;

@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) WMProgressHUD *progressView;
@property (nonatomic, strong) NSArray *invitationHandlerArray;

/**
 다른 뷰컨트롤러에서 pop하거나 popRootViewController를 통해 MainViewController로 복귀시에 호출되는 함수이다.
 이 함수는 NSNotificationCenter로 호출되며, Observer를 등록하기 위해 사용된다.
 얘도 이름 바꿔라
 */
- (void)viewDidUnwind:(NSNotification *)notification;
/**
 BrowserViewController를 화면에 표시한다. 블루투스의 현재 상태를 확인하여, 블루투스가 켜지지 않은 상태라면 Alert를 표시한다.
 */
- (void)loadBrowserViewController;
/**
 ProgressView의 상태를 완료로 바꾼 뒤에 종료한다.
 Main Thread에서 호출하기 위한 performSelector 용도의 함수이다.
 */
- (void)doneProgress;
/**
 다른 단말기에 자신의 단말기가 검색되는 것을 허용한다.
 */
- (void)startAdvertise;
/**
 다른 단말기에 자신의 단말기가 검색되는 것을 허용하지 않는다.
 */
- (void)stopAdvertise;
/**
 PhotoFrame ViewController를 호출한다.
 Main Thread에서 호출하기 위한 performSelector 용도의 함수이다.
 ...
 NotificationCenter로 호출되는 함수에서 ViewController를 호출헀더니, Thread가 구분되는지 딜레이가 심하게 발생한다.
 이를 방지하기 위하여 main thread에서 ViewController를 호출할 수 있도록 따로 함수를 만들었다.
 */
- (void)loadPhotoFrameViewController;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectionManager = [ConnectionManager sharedInstance];
    self.connectionManager.delegate = self;
    
    self.browserViewController = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_TYPE session:self.connectionManager.ownSession];
    //1:1 통신이므로 연결할 피어의 수는 하나로 제한한다.
    self.browserViewController.maximumNumberOfPeers = 1;
    self.browserViewController.delegate = self;
    
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.connectionManager.ownPeerId discoveryInfo:nil serviceType:SERVICE_TYPE];
    
    UITapGestureRecognizer *tabGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadBrowserViewController)];
    tabGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tabGestureRecognizer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidUnwind:) name:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
}

- (void)viewDidUnwind:(NSNotification *)notification {
    [ConnectionManager sharedInstance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view setUserInteractionEnabled:YES];
    NSInteger bluetoothState = [self.connectionManager getBluetoothState];
    
    if (bluetoothState == CBCentralManagerStateUnsupported) {
        //Alert and application terminate.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_unsupported", nil) message:NSLocalizedString(@"alert_content_bluetooth_unsupported", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        if (bluetoothState == CBCentralManagerStatePoweredOff) {
            //Alert
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_off", nil) message:NSLocalizedString(@"alert_content_bluetooth_off", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
    self.advertiser.delegate = self;
    [self startAdvertise];
    
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
}

- (void)startAdvertise {
    if (self.advertiser != nil) {
        [self.advertiser startAdvertisingPeer];
    }
}

- (void)stopAdvertise {
    if (self.advertiser != nil) {
        [self.advertiser stopAdvertisingPeer];
    }
}

- (void)loadBrowserViewController {
    if ([self.connectionManager getBluetoothState] == CBCentralManagerStatePoweredOn) {
        if ([self hasAccessPhotoAlbumAuthority]) {
            [self presentViewController:self.browserViewController animated:YES completion:nil];
            [self stopAdvertise];
        }
    } else {
        //Alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_off", nil) message:NSLocalizedString(@"alert_content_bluetooth_off", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (BOOL)hasAccessPhotoAlbumAuthority {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (!(status == ALAuthorizationStatusNotDetermined || status == ALAuthorizationStatusAuthorized)) {
        //앨범 접근 권한 없음. 해당 Alert 표시.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_album_not_authorized", nil) message:NSLocalizedString(@"alert_content_album_not_authorized", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
        alertView.tag = ALERT_ALBUM_AUTH;
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

- (void)loadPhotoFrameViewController {
    [self stopAdvertise];
    self.connectionManager.delegate = nil;
    [self performSegueWithIdentifier:SEGUE_MOVETO_FRAME_SLT sender:self];
}

- (void)doneProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:NSLocalizedString(@"progress_title_connected", nil) delay:1];
    }
}

- (void)rejectProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:NSLocalizedString(@"progress_title_rejected", nil) delay:1 cancel:YES];
    }
}


#pragma mark - MCBrowserViewControllerDelegate Methods

//Session Connecte Done.
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
//    [self loadPhotoFrameViewController];
}

//Session Connect Cancel.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    [[ConnectionManager sharedInstance] disconnectSession];
}


#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    if (self.invitationHandlerArray != nil) {
        self.invitationHandlerArray = nil;
    }
    
    self.invitationHandlerArray = [NSArray arrayWithObjects:[invitationHandler copy], nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_invitation_received", nil) message:[NSString stringWithFormat:@"\"%@\" %@", peerID.displayName, NSLocalizedString(@"alert_content_invitation_received", nil)] delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_decline", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_accept", nil), nil];
    [alertView show];
}


#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Accept
    if (buttonIndex == 1) {
        void (^invitationHandler)(BOOL, MCSession *) = self.invitationHandlerArray[0];
        invitationHandler(YES, [ConnectionManager sharedInstance].ownSession);
        
        self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:NSLocalizedString(@"progress_title_connecting", nil)];
        [self.view setUserInteractionEnabled:NO];
        //Decline
    } else {
        void (^invitationHandler)(BOOL, MCSession *) = self.invitationHandlerArray[0];
        invitationHandler(NO, [ConnectionManager sharedInstance].ownSession);
    }
}


#pragma mark - ConnectionManager Delegate Methods

- (void)receivedPeerConnected {
    //연결이 완료되면 자신의 단말기 화면 사이즈를 상대방에게 전송한다.
    NSDictionary *screenSizeDictionary = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_SCREEN_SIZE),
                                           KEY_SCREEN_SIZE_WIDTH:  [ConnectionManager sharedInstance].ownScreenWidth,
                                           KEY_SCREEN_SIZE_HEIGHT: [ConnectionManager sharedInstance].ownScreenHeight};
    
    //메시지 큐 사용을 활성화한다.
    [[MessageSyncManager sharedInstance] setMessageQueueEnabled:YES];
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:screenSizeDictionary]];
    
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadPhotoFrameViewController];
        });
    }
}

- (void)receivedEditorDisconnected {
    [[ConnectionManager sharedInstance] disconnectSession];
    
    if ([self.navigationController presentedViewController] != self.browserViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rejectProgress];
        });
    }
}

@end
