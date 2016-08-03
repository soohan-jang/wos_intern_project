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

@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (nonatomic) BOOL isBluetoothUnsupported;

@property (nonatomic, strong) WMProgressHUD *progressView;
@property (nonatomic, strong) NSArray *invitationHandlerArray;

- (void)findDeviceAction;

/**
 다른 뷰컨트롤러에서 pop하거나 popRootViewController를 통해 MainViewController로 복귀시에 호출되는 함수이다.
 이 함수는 NSNotificationCenter로 호출되며, Observer를 등록하기 위해 사용된다.
 */
- (void)viewDidUnwind:(NSNotification *)notification;

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

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [[ConnectionManager sharedInstance] initInstanceProperties:[UIDevice currentDevice].name withScreenWidthSize:self.view.frame.size.width withScreenHeightSize:self.view.frame.size.height];
    [ConnectionManager sharedInstance].browserViewController.delegate = self;
    
    UITapGestureRecognizer *tabGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findDeviceAction)];
    tabGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tabGestureRecognizer];
    
    [ConnectionManager sharedInstance].delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidUnwind:) name:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
}

- (void)viewDidUnwind:(NSNotification *)notification {
    NSLog(@"Unwinded, addObservers.");
    [ConnectionManager sharedInstance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view setUserInteractionEnabled:YES];
    if (self.bluetoothManager.state == CBCentralManagerStateUnsupported) {
        //Alert and application terminate.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_unsupported", nil) message:NSLocalizedString(@"alert_content_bluetooth_unsupported", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
        [alertView show];
        self.isBluetoothUnsupported = YES;
    } else {
        self.isBluetoothUnsupported = NO;
        
        if (self.bluetoothManager.state == CBCentralManagerStatePoweredOff) {
            //Alert
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_off", nil) message:NSLocalizedString(@"alert_content_bluetooth_off", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
    [ConnectionManager sharedInstance].advertiser.delegate = self;
    [[ConnectionManager sharedInstance] startAdvertise];
    
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)findDeviceAction {
    if (self.bluetoothManager.state == CBCentralManagerStatePoweredOn) {
        if ([self hasAccessPhotoAlbumAuthority]) {
            [self presentViewController:[ConnectionManager sharedInstance].browserViewController animated:YES completion:nil];
            [[ConnectionManager sharedInstance] stopAdvertise];
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
    [[ConnectionManager sharedInstance] stopAdvertise];
    [ConnectionManager sharedInstance].delegate = nil;
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


#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central { /** Do nothing... **/ }


#pragma mark - ConnectionManager Delegate Methods

- (void)receivedPeerConnected {
    //연결이 완료되면 자신의 단말기 화면 사이즈를 상대방에게 전송한다.
    NSDictionary *screenSizeDictionary = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_SCREEN_SIZE),
                                           KEY_SCREEN_SIZE_WIDTH:  [ConnectionManager sharedInstance].ownScreenWidth,
                                           KEY_SCREEN_SIZE_HEIGHT: [ConnectionManager sharedInstance].ownScreenHeight};
    
    //메시지 큐 사용을 활성화한다.
    [[MessageSyncManager sharedInstance] setMessageQueueEnabled:YES];
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:screenSizeDictionary]];
    
    if ([self.navigationController presentedViewController] == [ConnectionManager sharedInstance].browserViewController) {
        [self.view setUserInteractionEnabled:NO];
        [[ConnectionManager sharedInstance].browserViewController dismissViewControllerAnimated:YES completion:^{
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
    
    if ([self.navigationController presentedViewController] != [ConnectionManager sharedInstance].browserViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rejectProgress];
        });
    }
}

@end
