//
//  MainViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MainViewController.h"

#import "CommonConstants.h"

#import "ConnectionManager.h"
#import "ValidateCheckUtility.h"

#import "PhotoFrameSelectViewController.h"
#import "PhotoEditorViewController.h"

#import "ProgressHelper.h"
#import "AlertHelper.h"
#import "DispatchAsyncHelper.h"
#import "MessageFactory.h"

@interface MainViewController () <MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, ConnectionManagerSessionConnectDelegate>

@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) WMProgressHUD *progressView;
@property (nonatomic, strong) NSMutableDictionary *invitationHandlers;

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
                                                        discoveryInfo:nil
                                                          serviceType:ApplicationBluetoothServiceType];
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
//    [self performSegueWithIdentifier:SegueMoveToAlbum sender:self];
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
            [self presentViewController:self.browserViewController
                               animated:YES
                             completion:nil];
            return;
        }
        
        
        UIAlertAction *noActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_no" handler:nil];
        UIAlertAction *yesActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_yes"
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                 }];
        
        [AlertHelper showAlertControllerOnViewController:self
                                                titleKey:@"alert_title_album_not_authorized"
                                              messageKey:@"alert_content_album_not_authorized"
                                             firstButton:noActionButton
                                            secondButton:yesActionButton];
    } else {
        UIAlertAction *okActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_ok" handler:nil];
        [AlertHelper showAlertControllerOnViewController:self
                                                titleKey:@"alert_title_bluetooth_off"
                                              messageKey:@"alert_content_bluetooth_off"
                                                  button:okActionButton];
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
//    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

//Session Connect Cancel.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
//    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    [[ConnectionManager sharedInstance] disconnectSession];
}


#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    if (self.invitationHandlers == nil) {
        self.invitationHandlers = [[NSMutableDictionary alloc] init];
    }
    
    if (peerID == nil || invitationHandler == nil) {
        return;
    }
    
    self.invitationHandlers[peerID] = invitationHandler;
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *declineActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_decline"
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                                           __strong typeof(self) self = weakSelf;
                                                                           void (^invitationHandler)(BOOL, MCSession *) = self.invitationHandlers[peerID];
                                                                           
                                                                           if (!self || !invitationHandler) {
                                                                               return;
                                                                           }
                                                                           
                                                                           invitationHandler(NO, [ConnectionManager sharedInstance].ownSession);
                                                                           [self.invitationHandlers removeObjectForKey:peerID];
                                                                       }];
    
    UIAlertAction *acceptActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_accept"
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          __strong typeof(self) self = weakSelf;
                                                                          void (^invitationHandler)(BOOL, MCSession *) = self.invitationHandlers[peerID];
                                                                          
                                                                          if (!self || !invitationHandler) {
                                                                              return;
                                                                          }
                                                                          
                                                                          invitationHandler(YES, [ConnectionManager sharedInstance].ownSession);
                                                                          [self.invitationHandlers removeObjectForKey:peerID];
                                                                          self.progressView = [ProgressHelper showProgressAddedTo:self.view titleKey:@"progress_title_connecting"];
                                                                      }];
    
    [AlertHelper showAlertControllerOnViewController:self
                                               title:NSLocalizedString(@"alert_title_invitation_received", nil)
                                             message:[NSString stringWithFormat:@"\"%@\" %@", peerID.displayName, NSLocalizedString(@"alert_content_invitation_received", nil)]
                                         firstButton:declineActionButton
                                        secondButton:acceptActionButton];
}


#pragma mark - ConnectionManager Delegate Methods

- (void)receivedPeerConnected {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionState = MCSessionStateConnected;
    
    //연결이 완료되면 자신의 단말기 화면 사이즈를 상대방에게 전송한다.
    NSDictionary *message = [MessageFactory MessageGenerateScreenRect:connectionManager.ownScreenSize];
    
    //메시지 큐 사용을 활성화한다.
    [connectionManager setMessageQueueEnabled:YES];
    [connectionManager sendMessage:message];
    
    __weak typeof(self) weakSelf = self;
    if ([self.navigationController presentedViewController] == self.browserViewController) {
        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || !self.browserViewController) {
                return;
            }
            
            [self.browserViewController dismissViewControllerAnimated:YES completion:^{
                if (!self) {
                    return;
                }
                
                [self loadPhotoFrameViewController];
            }];
        }];
    } else {
        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || !self.progressView) {
                return;
            }
            
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_connected" dismissType:DismissWithDone];
        }];
        
        //ProgressView의 상태가 바뀌어서 사용자에게 보여질정도의 충분한 시간(delay) 뒤에 PhotoFrameSelectViewController를 호출하도록 한다.
        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                return;
            }
            
            [self loadPhotoFrameViewController];
        } delay:DelayTime];
    }
}

- (void)receivedPeerDisconnected {
    [ConnectionManager sharedInstance].sessionState = MCSessionStateNotConnected;
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.progressView) {
            return;
        }
        
        if (!self.progressView.isHidden) {
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_rejected" dismissType:DismissWithDone];
        }
        
        [[ConnectionManager sharedInstance] disconnectSession];
    }];
}

@end
