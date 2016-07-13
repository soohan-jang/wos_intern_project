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

    self.connectionManager = [ConnectionManager sharedInstance];
    [self.connectionManager initInstanceProperties:[UIDevice currentDevice].name screenWidthSize:self.view.frame.size.width screenHeightSize:self.view.frame.size.height];
    
    self.connectionManager.browserViewController.delegate = self;
    
    self.isBrowser = NO;
    self.isAdvertiser = NO;
    
    self.notificationCenter = [NSNotificationCenter defaultCenter];
}

- (void)viewDidAppear:(BOOL)animated {
    self.connectionManager.advertiser.delegate = self;
    [self.connectionManager startAdvertise];
    
    [self.notificationCenter addObserver:self selector:@selector(sessionConnected:) name:self.connectionManager.NOTIFICATION_CONNECTED object:nil];
    [self.notificationCenter addObserver:self selector:@selector(sessionDisconnected:) name:self.connectionManager.NOTIFICATION_DISCONNECTED object:nil];
    [self.notificationCenter addObserver:self selector:@selector(receivedScreenSize:) name:self.connectionManager.NOTIFICATION_RECV_SCREEN_SIZE object:nil];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.notificationCenter removeObserver:self name:self.connectionManager.NOTIFICATION_CONNECTED object:nil];
    [self.notificationCenter removeObserver:self name:self.connectionManager.NOTIFICATION_DISCONNECTED object:nil];
    [self.notificationCenter removeObserver:self name:self.connectionManager.NOTIFICATION_RECV_SCREEN_SIZE object:nil];
    
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
    
    if (fabs(endPoint.x - self.startPoint.x) <= 10.0f && fabs(endPoint.y - self.startPoint.y) <= 10.0f) {
        [self presentViewController:self.connectionManager.browserViewController animated:YES completion:nil];
    }
}

//Session Connected!
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    self.isBrowser = YES;
}

//Session Not Connected!
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    self.isBrowser = NO;
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    self.invitationArray = [NSArray arrayWithObjects:[invitationHandler copy], nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"wos_intern_project" message:[NSString stringWithFormat:@"\"%@\" wants to connect.", peerID.displayName] delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Accept
    if (buttonIndex) {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationArray objectAtIndex:0];
        invitationHandler(YES, self.connectionManager.ownSession);
        self.isAdvertiser = YES;
    //Decline
    } else {
        void (^invitationHandler)(BOOL, MCSession *) = [self.invitationArray objectAtIndex:0];
        invitationHandler(NO, self.connectionManager.ownSession);
        self.isAdvertiser = NO;
    }
}

- (void)sessionConnected:(NSNotification *)notification {
    if (self.isBrowser || self.isAdvertiser) {
        //연결이 완료되면 자신의 단말기 화면 사이즈를 상대방에게 전송한다.
        NSDictionary *screenSizeDictionary =
                @{self.connectionManager.KEY_DATA_TYPE: self.connectionManager.VALUE_DATA_TYPE_SCREEN_SIZE,
                  self.connectionManager.KEY_SCREEN_SIZE_WIDTH:  self.connectionManager.ownScreenWidth,
                  self.connectionManager.KEY_SCREEN_SIZE_HEIGHT: self.connectionManager.ownScreenHeight};
        NSError *error;
        [self.connectionManager.ownSession sendData:[NSKeyedArchiver archivedDataWithRootObject:screenSizeDictionary] toPeers:self.connectionManager.ownSession.connectedPeers withMode:MCSessionSendDataReliable error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

- (void)sessionDisconnected:(NSNotification *)notification {
    [self.connectionManager.ownSession disconnect];
}

//연결된 상대방에게서 화면 사이즈를 전송받으면, 화면을 전환한다.
- (void)receivedScreenSize:(NSNotification *)notification {
    [self.connectionManager setConnectedPeerScreenWidthWith:[(NSNumber *)[notification.userInfo objectForKey:self.connectionManager.KEY_SCREEN_SIZE_WIDTH] copy]
                                  connectedPeerScreenHeight:[(NSNumber *)[notification.userInfo objectForKey:self.connectionManager.KEY_SCREEN_SIZE_HEIGHT] copy]];
    
    NSLog(@"Received Screen Size : width(%f), height(%f)", [self.connectionManager.connectedPeerScreenWidth floatValue], [self.connectionManager.connectedPeerScreenWidth floatValue]);
    
    if (self.isBrowser || self.isAdvertiser) {
        if (self.isBrowser) {
            NSLog(@"Browser");
            //Browser로 커넥션이 될 경우, 사진 액자를 고를 수 있게 만든다.
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PhotoFrameSelectViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"photoFrameSelectViewController"];
            viewController.isEnableFrameSelect = YES;
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else {
            if (self.isAdvertiser) {
                NSLog(@"Advertiser");
                //Advertiser로 커넥션이 될 경우, 사진 액자를 고를 수 없게 만든다.
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                PhotoFrameSelectViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"photoFrameSelectViewController"];
                viewController.isEnableFrameSelect = NO;
                
                [self.navigationController pushViewController:viewController animated:YES];
                
            }
        }
        
        [self.connectionManager stopAdvertise];
    }
}

@end
