//
//  BluetoothAdvertiser.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "BluetoothAdvertiser.h"
#import "ConnectionManager.h"

@interface BluetoothAdvertiser () <MCNearbyServiceAdvertiserDelegate, ConnectionManagerSessionDelegate>

@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) id invitationHandler;

@end

@implementation BluetoothAdvertiser

- (instancetype)initWithServiceType:(NSString *)serviceType peerId:(MCPeerID *)myPeerId {
    self = [super init];
    
    if (self) {
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerId
                                                        discoveryInfo:nil
                                                          serviceType:serviceType];
        _advertiser.delegate = self;
    }
    
    return self;
}


#pragma mark - Start & Stop Advertising

- (void)advertiseStart {
    [ConnectionManager sharedInstance].sessionDelegate = self;
    [_advertiser startAdvertisingPeer];
}

- (void)advertiseStop {
    [ConnectionManager sharedInstance].sessionDelegate = nil;
    [_advertiser stopAdvertisingPeer];
}


#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    if (_delegate) {
        [_delegate didNotStartAdvertising];
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    if (_delegate) {
        [_delegate didReceiveInvitationWithPeerId:peerID invitationHandler:invitationHandler];
    }
}


#pragma mark - ConnectionManagerSessionDelegate

- (void)receivedPeerConnected {
    if (_delegate) {
        [_delegate advertiserSessionConnected];
    }
}

- (void)receivedPeerDisconnected {
    if (_delegate) {
        [_delegate advertiserSessionNotConnected];
    }
}

@end
