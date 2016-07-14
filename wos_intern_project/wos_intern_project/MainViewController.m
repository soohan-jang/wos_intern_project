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

    [[ConnectionManager sharedInstance] initInstanceProperties:[UIDevice currentDevice].name screenWidthSize:self.view.frame.size.width screenHeightSize:self.view.frame.size.height];
    [ConnectionManager sharedInstance].browserViewController.delegate = self;
    
    self.isBrowser = NO;
    self.isAdvertiser = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [ConnectionManager sharedInstance].advertiser.delegate = self;
    [[ConnectionManager sharedInstance] startAdvertise];
    
    [self addObservers];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self removeObservers];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.startPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint endPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
    
    if (fabs(endPoint.x - self.startPoint.x) <= 15.0f && fabs(endPoint.y - self.startPoint.y) <= 15.0f) {
        [self presentViewController:[ConnectionManager sharedInstance].browserViewController animated:YES completion:nil];
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSessionConnected:) name:[ConnectionManager sharedInstance].NOTIFICATION_PEER_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSessionDisconnected:) name:[ConnectionManager sharedInstance].NOTIFICATION_PEER_DISCONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedScreenSize:) name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_SCREEN_SIZE object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_PEER_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_PEER_DISCONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_SCREEN_SIZE object:nil];
}

//Session Connecte Done.
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    self.isBrowser = YES;
    self.isAdvertiser = NO;
}

//Session Connect Cancel.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    self.isBrowser = NO;
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    if (self.invitationHandlerArray != nil) {
        self.invitationHandlerArray = nil;
    }
    
    self.invitationHandlerArray = [NSArray arrayWithObjects:[invitationHandler copy], nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"wos_intern_project" message:[NSString stringWithFormat:@"\"%@\" wants to connect.", peerID.displayName] delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Accept
    if (buttonIndex) {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray objectAtIndex:0];
        invitationHandler(YES, [ConnectionManager sharedInstance].ownSession);
        self.isBrowser = NO;
        self.isAdvertiser = YES;
    //Decline
    } else {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationHandlerArray objectAtIndex:0];
        invitationHandler(NO, [ConnectionManager sharedInstance].ownSession);
        self.isAdvertiser = NO;
    }
}

- (void)receivedSessionConnected:(NSNotification *)notification {
    if (self.isBrowser || self.isAdvertiser) {
        //연결이 완료되면 자신의 단말기 화면 사이즈를 상대방에게 전송한다.
        NSDictionary *screenSizeDictionary =
                @{[ConnectionManager sharedInstance].KEY_DATA_TYPE: [ConnectionManager sharedInstance].VALUE_DATA_TYPE_SCREEN_SIZE,
                  [ConnectionManager sharedInstance].KEY_SCREEN_SIZE_WIDTH:  [ConnectionManager sharedInstance].ownScreenWidth,
                  [ConnectionManager sharedInstance].KEY_SCREEN_SIZE_HEIGHT: [ConnectionManager sharedInstance].ownScreenHeight};
        
        [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:screenSizeDictionary]];
    }
}

- (void)receivedSessionDisconnected:(NSNotification *)notification {
    [[ConnectionManager sharedInstance] disconnectSession];
}

//연결된 상대방에게서 화면 사이즈를 전송받으면, 화면을 전환한다.
- (void)receivedScreenSize:(NSNotification *)notification {
    [[ConnectionManager sharedInstance] setConnectedPeerScreenWidthWith:[(NSNumber *)[notification.userInfo objectForKey:[ConnectionManager sharedInstance].KEY_SCREEN_SIZE_WIDTH] copy]
                                  connectedPeerScreenHeight:[(NSNumber *)[notification.userInfo objectForKey:[ConnectionManager sharedInstance].KEY_SCREEN_SIZE_HEIGHT] copy]];
    
    NSLog(@"Received Screen Size : width(%f), height(%f)", [[ConnectionManager sharedInstance].connectedPeerScreenWidth floatValue], [[ConnectionManager sharedInstance].connectedPeerScreenWidth floatValue]);
    
    if (self.isBrowser || self.isAdvertiser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PhotoFrameSelectViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"photoFrameSelectViewController"];
        
        //커넥션이 활성화되는 순간에는, isBrowser 혹은 isAdvertiser 둘 중 하나만 YES 상태이다. 둘 다 NO인 경우는 있을 수 있지만, 둘 다 YES인 경우는 없다.
        if (self.isBrowser) {
            //Browser로 커넥션이 될 경우, 사진 액자를 고를 수 있게 만든다.
            NSLog(@"Browser");
            viewController.isEnableFrameSelect = YES;
        }
        
        if (self.isAdvertiser) {
            //Advertiser로 커넥션이 될 경우, 사진 액자를 고를 수 없게 만든다.
            NSLog(@"Advertiser");
            viewController.isEnableFrameSelect = NO;
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
        [[ConnectionManager sharedInstance] stopAdvertise];
    }
}

@end
