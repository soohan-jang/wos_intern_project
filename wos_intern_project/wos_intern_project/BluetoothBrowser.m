//
//  BluetoothBrowser.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "BluetoothBrowser.h"
#import "ConnectionManager.h"

NSInteger const MaximumNumberOfPeers = 1;

@interface BluetoothBrowser () <MCBrowserViewControllerDelegate, ConnectionManagerSessionDelegate>

@property (strong, nonatomic) MCBrowserViewController *browser;

@end

@implementation BluetoothBrowser


#pragma mark - Initialize method

- (instancetype)initWithServiceType:(NSString *)serviceType session:(MCSession *)session {
    self = [super init];
    
    if (self) {
        _browser = [[MCBrowserViewController alloc] initWithServiceType:serviceType session:session];
        _browser.maximumNumberOfPeers = MaximumNumberOfPeers;
        _browser.delegate = self;
    }
    
    return self;
}


#pragma mark - Present & Dismiss Methods

- (BOOL)presentBrowserViewController:(UIViewController *)parentViewController {
    if (![[ConnectionManager sharedInstance] isBluetoothAvailable]) {
        return NO;
    }
    
    __weak typeof(self) weakSelf = self;
    [parentViewController presentViewController:_browser animated:YES completion:^{
        __strong typeof (weakSelf) self = weakSelf;
        [ConnectionManager sharedInstance].sessionDelegate = self;
    }];
    return YES;
}

NS_ENUM(NSInteger, DismissType) {
    DismissTypeConnected = 0,
    DismissTypeNotConnected
};

- (void)dismissBrowserViewController:(NSInteger)dismissType {
    [ConnectionManager sharedInstance].sessionDelegate = nil;
    
    __weak typeof(_delegate) weakDelegate = _delegate;
    [_browser dismissViewControllerAnimated:YES completion:^{
        __strong typeof(weakDelegate) delegate = weakDelegate;
        if (delegate) {
            switch (dismissType) {
                case DismissTypeConnected:
                    [delegate browserSessionConnected];
                    break;
                case DismissTypeNotConnected:
                    [delegate browserSessionNotConnected];
                    break;
            }
        }
    }];
}


#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    //완료 버튼을 눌러도 닫히지 않게 만든다. 세션 연결이 완료되면 자동으로 다음 화면으로 넘어간다.
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    //현재 상태가 연결 중이면, Browser VC를 닫지 않는다.
    if ([ConnectionManager sharedInstance].sessionState == MCSessionStateConnecting) {
        return;
    }
    
    [self dismissBrowserViewController:DismissTypeNotConnected];
}


#pragma mark - ConnectionManagerSessionDelegate

- (void)receivedPeerConnected {
    //메시지 큐 사용을 활성화한다.
    [[ConnectionManager sharedInstance] setMessageQueueEnabled:YES];
    [self dismissBrowserViewController:DismissTypeConnected];
}

- (void)receivedPeerDisconnected {
    //메시지 큐 사용을 비활성화한다.
    [[ConnectionManager sharedInstance] setMessageQueueEnabled:NO];
}

@end