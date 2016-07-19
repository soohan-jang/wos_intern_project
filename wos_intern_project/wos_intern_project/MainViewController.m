//
//  MainViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [[ConnectionManager sharedInstance] initInstanceProperties:[UIDevice currentDevice].name screenWidthSize:self.view.frame.size.width screenHeightSize:self.view.frame.size.height];
    [ConnectionManager sharedInstance].browserViewController.delegate = self;
    
    UITapGestureRecognizer *tabGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findDeviceAction)];
    tabGestureRecognizer.numberOfTapsRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tabGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.bluetoothManager.state == CBCentralManagerStateUnsupported) {
        //Alert and application terminate.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_unsupported", nil) message:NSLocalizedString(@"alert_content_bluetooth_unsupported", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
        [alertView show];
        self.isBluetoothUnsupported = YES;
    }
    else {
        self.isBluetoothUnsupported = NO;
        
        if (self.bluetoothManager.state == CBCentralManagerStatePoweredOff) {
            //Alert
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_off", nil) message:NSLocalizedString(@"alert_content_bluetooth_off", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
    [ConnectionManager sharedInstance].advertiser.delegate = self;
    [[ConnectionManager sharedInstance] startAdvertise];
    
    [self addObservers];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)findDeviceAction {
    if (self.bluetoothManager.state == CBCentralManagerStatePoweredOn) {
        [self presentViewController:[ConnectionManager sharedInstance].browserViewController animated:YES completion:nil];
        [[ConnectionManager sharedInstance] stopAdvertise];
    }
    else {
        //Alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_bluetooth_off", nil) message:NSLocalizedString(@"alert_content_bluetooth_off", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSessionConnected:) name:NOTIFICATION_PEER_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSessionDisconnected:) name:NOTIFICATION_PEER_DISCONNECTED object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PEER_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PEER_DISCONNECTED object:nil];
}

/**** MCBrowserViewControllerDelegate Methods. ****/

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

/**** MCNearbyServiceAdvertiserDelegate Methods. ****/

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    if (self.invitationHandlerArray != nil) {
        self.invitationHandlerArray = nil;
    }
    
    self.invitationHandlerArray = [NSArray arrayWithObjects:[invitationHandler copy], nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_invitation_received", nil) message:[NSString stringWithFormat:@"\"%@\" %@", peerID.displayName, NSLocalizedString(@"alert_content_invitation_received", nil)] delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_decline", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_accept", nil), nil];
    [alertView show];
}

/**** UIAlertViewDelegate Methods. ****/

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Accept
    if (buttonIndex == 1) {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray objectAtIndex:0];
        invitationHandler(YES, [ConnectionManager sharedInstance].ownSession);
        
        self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:NSLocalizedString(@"progress_title_connecting", nil)];
        //Decline
    } else {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray objectAtIndex:0];
        invitationHandler(NO, [ConnectionManager sharedInstance].ownSession);
    }
}

/**** CBCentralManagerDelegate Methods. ****/

- (void)centralManagerDidUpdateState:(CBCentralManager *)central { /** Do nothing... **/ }

/**** PerformSelector Methods. ****/

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

- (void)loadPhotoFrameViewController {
    [[ConnectionManager sharedInstance] stopAdvertise];
    [self performSegueWithIdentifier:@"moveToPhotoFrameSelect" sender:self];
    [self removeObservers];
}

/**** Session Communication Methods. ****/

- (void)receivedSessionConnected:(NSNotification *)notification {
    //연결이 완료되면 자신의 단말기 화면 사이즈를 상대방에게 전송한다.
    NSDictionary *screenSizeDictionary =
    @{KEY_DATA_TYPE: [NSNumber numberWithInteger:VALUE_DATA_TYPE_SCREEN_SIZE],
      KEY_SCREEN_SIZE_WIDTH:  [ConnectionManager sharedInstance].ownScreenWidth,
      KEY_SCREEN_SIZE_HEIGHT: [ConnectionManager sharedInstance].ownScreenHeight};
    
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:screenSizeDictionary]];
    
    if ([self.navigationController presentedViewController] == [ConnectionManager sharedInstance].browserViewController) {
        [[ConnectionManager sharedInstance].browserViewController dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadPhotoFrameViewController];
            });
        }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneProgress];
        });
        
        //ProgressView의 상태가 바뀌어서 사용자에게 보여질정도의 충분한 시간(delay + 0.5) 뒤에 PhotoFrameSelectViewController를 호출하도록 한다.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadPhotoFrameViewController];
            });
        });
    }
}

- (void)receivedSessionDisconnected:(NSNotification *)notification {
    [[ConnectionManager sharedInstance] disconnectSession];
    
    if ([self.navigationController presentedViewController] != [ConnectionManager sharedInstance].browserViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rejectProgress];
        });
    }
}

@end
