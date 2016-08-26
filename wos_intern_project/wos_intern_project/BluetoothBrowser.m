//
//  BluetoothBrowser.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "BluetoothBrowser.h"

#import "PESessionManager.h"
#import "PEBluetoothSession.h"

#import "PEMessageReceiver.h"

NSInteger const MaximumNumberOfPeers = 1;

@interface BluetoothBrowser () <MCBrowserViewControllerDelegate, PEMessageReceiverStateChangeDelegate>

@property (strong, nonatomic) MCBrowserViewController *browserController;

@end

@implementation BluetoothBrowser

#pragma mark - Initialize method

- (instancetype)initWithServiceType:(NSString *)serviceType session:(MCSession *)session {
    self = [super init];
    
    if (self) {
        _browserController = [[MCBrowserViewController alloc] initWithServiceType:serviceType session:session];
        _browserController.maximumNumberOfPeers = MaximumNumberOfPeers;
        _browserController.delegate = self;
    }
    
    return self;
}

- (void)dealloc {
    [PESessionManager sharedInstance].messageReceiver.stateChangeDelegate = nil;
    _browserController.delegate = nil;
    _browserController = nil;
}


#pragma mark - Present & Dismiss Methods

- (BOOL)presentBrowserViewController:(UIViewController *)parentViewController {
    if ([PESessionManager sharedInstance].session.availiableState != AvailiableStateEnable) {
        return NO;
    }
    
    [_browserController.browser stopBrowsingForPeers];
    
    __weak typeof(self) weakSelf = self;
    [parentViewController presentViewController:_browserController animated:YES completion:^{
        __strong typeof (weakSelf) self = weakSelf;
        
        if (!self) {
            return;
        }
        
        [self.browserController.browser startBrowsingForPeers];
        [PESessionManager sharedInstance].messageReceiver.stateChangeDelegate = self;
    }];
    return YES;
}

- (void)dismissBrowserViewController:(void (^)(void))completion {
    [_browserController dismissViewControllerAnimated:YES completion:completion];
}


#pragma mark - MCBrowserViewControllerDelegate Methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    //완료 버튼을 눌러도 닫히지 않게 만든다. 세션 연결이 완료되면 자동으로 다음 화면으로 넘어간다.
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    //현재 상태가 연결 중이면, Browser VC를 닫지 않는다.
    if ([PESessionManager sharedInstance].session.sessionState == SessionStateConnecting) {
        return;
    }
    
    if (_delegate) {
        [_delegate browserSessionConnectCancel:self];
    }
}


#pragma mark - Message Receiver State Change Delegate Methods

- (void)didReceiveChangeSessionState:(NSInteger)state {
    switch (state) {
        case SessionStateConnected:
            if (_delegate) {
                [_delegate browserSessionConnected:self];
            }
            break;
        case SessionStateDisconnected:
            //Do Nothing.
            break;
    }
}

@end