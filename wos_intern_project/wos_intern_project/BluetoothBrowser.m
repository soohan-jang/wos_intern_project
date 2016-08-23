//
//  BluetoothBrowser.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "BluetoothBrowser.h"
#import "SessionManager.h"
#import "MessageReceiver.h"

NSInteger const MaximumNumberOfPeers = 1;

@interface BluetoothBrowser () <MCBrowserViewControllerDelegate, MessageReceiverStateChangeDelegate>

@property (strong, nonatomic) MCBrowserViewController *browserController;
@property (strong, nonatomic) MessageReceiver *messageReceiver;

@end

@implementation BluetoothBrowser

#pragma mark - Initialize method

- (instancetype)initWithServiceType:(NSString *)serviceType session:(MCSession *)session {
    self = [super init];
    
    if (self) {
        _browserController = [[MCBrowserViewController alloc] initWithServiceType:serviceType session:session];
        _browserController.maximumNumberOfPeers = MaximumNumberOfPeers;
        _browserController.delegate = self;
        
        [SessionManager sharedInstance].messageReceiver.stateChangeDelegate = self;
    }
    
    return self;
}


#pragma mark - Present & Dismiss Methods

- (BOOL)presentBrowserViewController:(UIViewController *)parentViewController {
    if ([SessionManager sharedInstance].session.availiableState != AvailiableStateEnable) {
        return NO;
    }
    
    __weak typeof(self) weakSelf = self;
    [parentViewController presentViewController:_browserController animated:YES completion:^{
        __strong typeof (weakSelf) self = weakSelf;
        
        if (!self) {
            return;
        }
        
        self.messageReceiver.stateChangeDelegate = self;
        [self.browserController.browser startBrowsingForPeers];
    }];
    return YES;
}

NS_ENUM(NSInteger, DismissType) {
    DismissTypeConnected = 0,
    DismissTypeNotConnected
};

- (void)dismissBrowserViewController:(NSInteger)dismissType {
    _messageReceiver.stateChangeDelegate = nil;
    [_browserController.browser stopBrowsingForPeers];
    _browserController.delegate = nil;
    
    __weak typeof(self) weakSelf = self;
    [_browserController dismissViewControllerAnimated:YES completion:^{
        __strong typeof (weakSelf) self = weakSelf;
        
        if (!self) {
            return;
        }
        
        if (self.delegate) {
            switch (dismissType) {
                case DismissTypeConnected:
                    [self.delegate browserSessionConnected:self];
                    break;
                case DismissTypeNotConnected:
                    [self.delegate browserSessionNotConnected:self];
                    break;
            }
        }
    }];
}


#pragma mark - MCBrowserViewControllerDelegate Methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    //완료 버튼을 눌러도 닫히지 않게 만든다. 세션 연결이 완료되면 자동으로 다음 화면으로 넘어간다.
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    //현재 상태가 연결 중이면, Browser VC를 닫지 않는다.
    if ([SessionManager sharedInstance].session.sessionState == SessionStateConnecting) {
        return;
    }
    
    [self dismissBrowserViewController:DismissTypeNotConnected];
}


#pragma mark - Message Receiver State Change Delegate Methods

- (void)didReceiveChangeSessionState:(NSInteger)state {
    switch (state) {
        case SessionStateConnected:
            [self dismissBrowserViewController:DismissTypeConnected];
            break;
        case SessionStateDisconnected:
            [_browserController.browser startBrowsingForPeers];
            break;
    }
}

@end