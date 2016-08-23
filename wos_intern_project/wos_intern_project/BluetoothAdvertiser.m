//
//  BluetoothAdvertiser.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "BluetoothAdvertiser.h"
#import "SessionManager.h"
#import "MessageReceiver.h"

@interface BluetoothAdvertiser () <MCNearbyServiceAdvertiserDelegate, MessageReceiverStateChangeDelegate>

@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MessageReceiver *messageReceiver;

@end

@implementation BluetoothAdvertiser

- (instancetype)initWithServiceType:(NSString *)serviceType session:(MCSession *)session {
    self = [super init];
    
    if (self) {
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:session.myPeerID
                                                        discoveryInfo:nil
                                                          serviceType:serviceType];
        _advertiser.delegate = self;
        
        [SessionManager sharedInstance].messageReceiver.stateChangeDelegate = self;
    }
    
    return self;
}


#pragma mark - Start & Stop Advertising

- (void)startAdvertise {
    _messageReceiver.stateChangeDelegate = self;
    [_advertiser startAdvertisingPeer];
}

- (void)stopAdvertise {
    _messageReceiver.stateChangeDelegate = nil;
    [_advertiser stopAdvertisingPeer];
}


#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if (_delegate) {
        [_delegate didNotStartAdvertising];
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    if (_delegate) {
        [_delegate didReceiveInvitationWithPeerName:peerID.displayName
                                  invitationHandler:invitationHandler];
    }
}


#pragma mark - Message Receiver State Change Delegate Methods

- (void)didReceiveChangeSessionState:(NSInteger)state {
    switch (state) {
        case SessionStateConnected:
            [_delegate advertiserSessionConnected];
            break;
        case SessionStateDisconnected:
            [_delegate advertiserSessionNotConnected];
            break;
    }
}

@end
