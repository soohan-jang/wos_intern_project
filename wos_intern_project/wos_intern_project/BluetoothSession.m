//
//  BluetoothSession.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "BluetoothSession.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CommonConstants.h"

@interface BluetoothSession () <MCSessionDelegate, CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (strong, nonatomic) MCSession *session;

@end

@implementation BluetoothSession

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.sessionType = SessionTypeBluetooth;
        
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        
        self.session = [[MCSession alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name]];
        self.session.delegate = self;
        
        self.availiableState = AvailiableStateUnknown;
        self.sessionState = SessionStateDisconnected;
    }
    
    return self;
}

- (NSString *)displayNameOfSession {
    return self.session.myPeerID.displayName;
}

- (BOOL)sendMessage:(MessageData *)message {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    NSError *error;
    
    [self.session sendData:data
                   toPeers:self.session.connectedPeers
                  withMode:MCSessionSendDataReliable
                     error:(&error)];
    
    if (error) {
        return NO;
    }
    
    return YES;
}

- (void)sendResource:(MessageData *)message resultBlock:(void (^)(BOOL success))resultHandler {
    if (message.messageType != MessageTypePhotoDataInsert && message.messageType != MessageTypePhotoDataUpdate) {
        return;
    }
    
    void(^sendOriginalImageBlock)(void) = nil;
    
    if (message.messageType == MessageTypePhotoDataInsert) {
        sendOriginalImageBlock = ^{
            NSString *name = [self makeResourceName:message.messageType
                                              index:message.photoDataIndexPath.item
                                          imageType:IdentifierImageOriginal
                                         filterType:message.photoDataFilterType];
            
            for (MCPeerID *peerID in self.session.connectedPeers) {
                [self.session sendResourceAtURL:message.photoDataOriginalImageURL
                                       withName:name toPeer:peerID
                          withCompletionHandler:^(NSError * _Nullable error) {
                              if (error) {
                                  resultHandler(NO);
                              }
                              
                              resultHandler(YES);
                          }
                 ];
            }
        };
    }
    
    NSString *name = [self makeResourceName:message.messageType
                                      index:message.photoDataIndexPath.item
                                  imageType:IdentifierImageCropped
                                 filterType:message.photoDataFilterType];
    
    for (MCPeerID *peerID in self.session.connectedPeers) {
        [self.session sendResourceAtURL:message.photoDataCroppedImageURL
                               withName:name toPeer:peerID
                  withCompletionHandler:^(NSError * _Nullable error) {
                      if (error) {
                          resultHandler(NO);
                      }
                      
                      if (!sendOriginalImageBlock) {
                          resultHandler(YES);
                          return;
                      }
                      
                      sendOriginalImageBlock();
                  }
         ];
    }
}

- (void)disconnect {
    [self.session disconnect];
    
    self.bluetoothManager.delegate = nil;
    self.bluetoothManager = nil;
    
    self.session.delegate = nil;
    self.session = nil;
    
    self.availiableState = AvailiableStateUnknown;
    self.sessionState = SessionStateDisconnected;
}


#pragma mark - Utility Methods

- (NSString *)makeResourceName:(NSInteger)messageType index:(NSInteger)index imageType:(NSString *)imageType filterType:(NSInteger)filterType {
    return [NSString stringWithFormat:@"%ld%@%ld%@%@%@%ld", (long)messageType, Sperator, (long)index, Sperator, imageType, Sperator, (long)filterType];
}


#pragma mark - MCSession Received Data Delegate Methods

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    if (!self.dataReceiveDelegate) {
        return;
    }
    
    [self.dataReceiveDelegate didReceiveData:(MessageData *)[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    if (!self.dataReceiveDelegate) {
        return;
    }
    
    NSArray *array = [resourceName componentsSeparatedByString:Sperator];
    
    if (array == nil || array.count != 4) {
        return;
    }
    
    NSInteger indexOfPhotoData = [array[1] integerValue];
    NSString *fileTypeOfPhotoData = array[2];
    
    if ([fileTypeOfPhotoData isEqualToString:IdentifierImageCropped]) {
        //didReceivedData : receive start photo data
        
        MessageData *data = [[MessageData alloc] init];
        data.messageType = MessageTypePhotoDataInsertStart;
        data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
        
        [self.dataReceiveDelegate didReceiveData:data];
    }
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    if (!self.dataReceiveDelegate) {
        return;
    }
    
    NSArray *array = [resourceName componentsSeparatedByString:Sperator];
    
    if (array == nil || array.count != 4) {
        return;
    }
    
    NSInteger messageTypeOfPhotoData = [array[0] integerValue];
    NSInteger indexOfPhotoData = [array[1] integerValue];
    NSString *fileTypeOfPhotoData = array[2];
    NSInteger filterTypeOfPhotoData = [array[3] integerValue];
    
    NSURL *fileURLOfPhotoData = localURL;
    
    if ([fileTypeOfPhotoData isEqualToString:IdentifierImageCropped]) {
        if (error) {
            //Error.
            return;
        }
        
        //didReceivedData : receive photo data - CroppedImage
        MessageData *data = [[MessageData alloc] init];
        data.messageType = MessageTypePhotoDataInsert;
        data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
        data.photoDataCroppedImageURL = fileURLOfPhotoData;
        data.photoDataFilterType = filterTypeOfPhotoData;
        
        [self.dataReceiveDelegate didReceiveData:data];
        
        if (messageTypeOfPhotoData == MessageTypePhotoDataUpdate) {
            //didReceivedData : receive finish photo data
            data = [[MessageData alloc] init];
            data.messageType = MessageTypePhotoDataInsertFinish;
            data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
        }
        
        return;
    }
    
    if ([fileTypeOfPhotoData isEqualToString:IdentifierImageOriginal]) {
        if (error) {
            //Error.
            return;
        }
        
        //didReceivedData : receive photo data - Original Image
        MessageData *data = [[MessageData alloc] init];
        data.messageType = MessageTypePhotoDataInsert;
        data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
        data.photoDataOriginalImageURL = fileURLOfPhotoData;
        data.photoDataFilterType = filterTypeOfPhotoData;
        
        [self.dataReceiveDelegate didReceiveData:data];
        
        //didReceivedData : receive finish photo data
        data = [[MessageData alloc] init];
        data.messageType = MessageTypePhotoDataInsertFinish;
        data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
        
        [self.dataReceiveDelegate didReceiveData:data];
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}


#pragma mark - MCSession & CoreBluetooth Central Manager Changed State Delegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected:
            self.sessionState = SessionStateConnected;
            break;
        case MCSessionStateConnecting:
            self.sessionState = SessionStateConnecting;
            break;
        case MCSessionStateNotConnected:
            self.sessionState = SessionStateDisconnected;
            break;
    }
    
    if (!self.connectDelegate) {
        return;
    }
    
    [self.connectDelegate didChangeSessionState:self.sessionState];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.availiableState = central.state;
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            self.availiableState = AvailiableStateUnknown;
            break;
        case CBCentralManagerStateUnsupported:
            self.availiableState = AvailiableStateUnsupported;
            break;
        case CBCentralManagerStateUnauthorized:
            self.availiableState = AvailiableStateUnauthorized;
            break;
        case CBCentralManagerStateResetting:
            self.availiableState = AvailiableStateResetting;
            break;
        case CBCentralManagerStatePoweredOff:
            self.availiableState = AvailiableStatePowerOff;
            break;
        case CBCentralManagerStatePoweredOn:
            self.availiableState = AvailiableStatePowerOn;
            break;
    }
    
    if (!self.connectDelegate) {
        return;
    }
    
    [self.connectDelegate didChangeAvailiableState:self.availiableState];
}

@end