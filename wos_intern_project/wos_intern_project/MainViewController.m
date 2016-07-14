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
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.bluetoothManager.state == CBCentralManagerStateUnsupported) {
        //Alert and application terminate.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Unsupported" message:@"Your device is not support a bluetooth 4.0." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        self.isBluetoothUnsupported = YES;
    }
    else {
        self.isBluetoothUnsupported = NO;
        
        if (self.bluetoothManager.state == CBCentralManagerStatePoweredOff) {
            //Alert
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Off" message:@"This application use a bluetooth.\nPlz, turn on bluetooth." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.bluetoothManager.state == CBCentralManagerStatePoweredOn) {
        self.startPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
    }
    else {
        //Alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Off" message:@"This application use a bluetooth.\nPlz, turn on bluetooth." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.bluetoothManager.state == CBCentralManagerStatePoweredOn) {
        CGPoint endPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
        
        if (fabs(endPoint.x - self.startPoint.x) <= 15.0f && fabs(endPoint.y - self.startPoint.y) <= 15.0f) {
            [self presentViewController:[ConnectionManager sharedInstance].browserViewController animated:YES completion:nil];
            [[ConnectionManager sharedInstance] stopAdvertise];
        }
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSessionConnected:) name:[ConnectionManager sharedInstance].NOTIFICATION_PEER_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSessionDisconnected:) name:[ConnectionManager sharedInstance].NOTIFICATION_PEER_DISCONNECTED object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_PEER_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_PEER_DISCONNECTED object:nil];
}

//Session Connecte Done.
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

//Session Connect Cancel.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    if (self.invitationHandlerArray != nil) {
        self.invitationHandlerArray = nil;
    }
    
    self.invitationHandlerArray = [NSArray arrayWithObjects:[invitationHandler copy], nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invitation Received" message:[NSString stringWithFormat:@"\"%@\" wants to connect.", peerID.displayName] delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Accept
    if (buttonIndex == 1) {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray objectAtIndex:0];
        invitationHandler(YES, [ConnectionManager sharedInstance].ownSession);
        
        self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:@"Connecting..."];
        //Decline
    } else {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray objectAtIndex:0];
        invitationHandler(NO, [ConnectionManager sharedInstance].ownSession);
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central { /** Do nothing... **/ }

- (void)doneProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:@"Connected!" delay:1];
    }
}

- (void)loadPhotoFrameViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhotoFrameSelectViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"photoFrameSelectViewController"];
    
    //원래는 1:n 통신이 가능하므로, MCBrowserViewController에서 커넥션을 맺은 뒤에 DONE 버튼을 눌러야 이동되도록 해야한다.
    //그런데 일단은 .. 1:1 통신으로 구현하므로, 연결되면 바로 PhotoFrameSelecteViewController로 이동하도록 구현한다.
    if ([[ConnectionManager sharedInstance].browserViewController isViewLoaded]) {
        NSLog(@"This terminal is Browser.");
        //Browser ViewController Dismiss
        [[ConnectionManager sharedInstance].browserViewController dismissViewControllerAnimated:YES completion:nil];
        
        //Browser로 커넥션이 될 경우, 사진 액자를 고를 수 있게 만든다.
        viewController.isEnableFrameSelect = YES;
    }
    else {
        NSLog(@"This terminal is Advertiser.");
        //Advertiser로 커넥션이 될 경우, 사진 액자를 고를 수 없게 만든다.
        viewController.isEnableFrameSelect = NO;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
    [[ConnectionManager sharedInstance] stopAdvertise];
    [self removeObservers];
}

- (void)receivedSessionConnected:(NSNotification *)notification {
    //연결이 완료되면 자신의 단말기 화면 사이즈를 상대방에게 전송한다.
    NSDictionary *screenSizeDictionary =
    @{[ConnectionManager sharedInstance].KEY_DATA_TYPE: [ConnectionManager sharedInstance].VALUE_DATA_TYPE_SCREEN_SIZE,
      [ConnectionManager sharedInstance].KEY_SCREEN_SIZE_WIDTH:  [ConnectionManager sharedInstance].ownScreenWidth,
      [ConnectionManager sharedInstance].KEY_SCREEN_SIZE_HEIGHT: [ConnectionManager sharedInstance].ownScreenHeight};
    
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:screenSizeDictionary]];
    
    [self performSelectorOnMainThread:@selector(doneProgress) withObject:nil waitUntilDone:YES];
    //ProgressView의 상태가 바뀌어서 사용자에게 보여질정도의 충분한 시간(delay + 0.5 * 1000 * 1000, usleep은 microseconds 단위) 뒤에 PhotoFrameSelectViewController를 호출하도록 한다.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSelectorOnMainThread:@selector(loadPhotoFrameViewController) withObject:nil waitUntilDone:YES];
    });
}

- (void)receivedSessionDisconnected:(NSNotification *)notification {
    [[ConnectionManager sharedInstance] disconnectSession];
}

@end
