
//
//  PEBluetoothSession.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "PEBluetoothSession.h"
#import "PEMessageReceiver.h"

#import "BluetoothBrowser.h"
#import "BluetoothAdvertiser.h"

#import "ImageUtility.h"

NSString *const SessionServiceType = @"Co-PhotoEditor";

@interface PEBluetoothSession () <MCSessionDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@property (strong, nonatomic) MCSession *session;

@property (strong, nonatomic) BluetoothBrowser *browser;
@property (strong, nonatomic) BluetoothAdvertiser *advertiser;

@end

@implementation PEBluetoothSession

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.sessionType = SessionTypeBluetooth;
        
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        
        self.session = [[MCSession alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name]];
        self.session.delegate = self;
        
        self.availiableState = AvailiableStateUnknown;
        self.sessionState = SessionStateDisconnected;
        
        self.advertiser = [[BluetoothAdvertiser alloc] initWithServiceType:SessionServiceType session:self.session];
    }
    
    return self;
}

- (id)instanceOfSession {
    return self.session;
}

- (NSString *)displayNameOfSession {
    return self.session.myPeerID.displayName;
}

- (BOOL)sendMessage:(PEMessage *)message {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    NSError *error;
    
    [self.session sendData:data
                   toPeers:self.session.connectedPeers
                  withMode:MCSessionSendDataReliable
                     error:(&error)];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

- (void)sendResource:(PEMessage *)message resultBlock:(void (^)(BOOL success))resultHandler {
    if (message.messageType != MessageTypePhotoDataInsert && message.messageType != MessageTypePhotoDataUpdate) {
        return;
    }
    
    void(^sendOriginalImageBlock)(void) = nil;
    
    if (message.messageType == MessageTypePhotoDataInsert) {
        sendOriginalImageBlock = ^{
            NSString *name = [self makeResourceName:message.messageType
                                              index:message.photoDataIndexPath.item
                                          imageType:PhotoTypeOriginal
                                         filterType:message.photoDataFilterType];
            
            for (MCPeerID *peerID in self.session.connectedPeers) {
                [self.session sendResourceAtURL:message.photoDataOriginalImageURL
                                       withName:name toPeer:peerID
                          withCompletionHandler:^(NSError * _Nullable error) {
                              if (error) {
                                  NSLog(@"%@", [error localizedDescription]);
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
                                  imageType:PhotoTypeCropped
                                 filterType:message.photoDataFilterType];
    
    for (MCPeerID *peerID in self.session.connectedPeers) {
        [self.session sendResourceAtURL:message.photoDataCroppedImageURL
                               withName:name toPeer:peerID
                  withCompletionHandler:^(NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"%@", [error localizedDescription]);
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
    
    [self clearBluetoothBrowser];
    [self clearBluetoothAdvertiser];
    
    self.sessionState = SessionStateDisconnected;
}


#pragma mark - Bluetooth Browser Methods

- (BOOL)presentBrowserController:(UIViewController *)viewController delegate:(id)delegate {
    self.browser = [[BluetoothBrowser alloc] initWithServiceType:SessionServiceType session:self.session];
    self.browser.delegate = delegate;
    
    if ([self.browser presentBrowserViewController:viewController]) {
        [self.advertiser stopAdvertise];
        return YES;
    }
    
    self.browser.delegate = nil;
    self.browser = nil;
    
    return NO;
}

- (void)clearBluetoothBrowser {
    self.browser.delegate = nil;
    self.browser = nil;
}


#pragma mark - Bluetooth Advertiser Methods

- (void)setAdvertiserDelegate:(id)delegate {
    self.advertiser.delegate = delegate;
}

- (void)startAdvertise {
    [self.advertiser startAdvertise];
}

- (void)stopAdvertise {
    [self.advertiser stopAdvertise];
}

- (void)clearBluetoothAdvertiser {
    self.advertiser.delegate = nil;
    self.advertiser = nil;
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
    
    [self.dataReceiveDelegate didReceiveData:(PEMessage *)[NSKeyedUnarchiver unarchiveObjectWithData:data]];
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
    
    if ([fileTypeOfPhotoData isEqualToString:PhotoTypeCropped]) {
        //didReceivedData : receive start photo data
        
        PEMessage *data = [[PEMessage alloc] init];
        data.messageType = MessageTypePhotoDataReceiveStart;
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
    NSString *dataTypeOfPhotoData = array[2];
    NSInteger filterTypeOfPhotoData = [array[3] integerValue];
    
    NSURL *fileURLOfPhotoData = localURL;
    
    if ([dataTypeOfPhotoData isEqualToString:PhotoTypeCropped]) {
        if (error) {
            //Error.
            NSLog(@"%@", [error localizedDescription]);
            PEMessage *data = [[PEMessage alloc] init];
            data.messageType = MessageTypePhotoDataReceiveError;
            data.photoDataType = dataTypeOfPhotoData;
            data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
            
            [self.dataReceiveDelegate didReceiveData:data];
            return;
        }
        
        if (messageTypeOfPhotoData == MessageTypePhotoDataUpdate) {
            PEMessage *data = [[PEMessage alloc] init];
            data.messageType = MessageTypePhotoDataUpdate;
            data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
            data.photoDataType = dataTypeOfPhotoData;
            data.photoDataCroppedImageURL = fileURLOfPhotoData;
            data.photoDataFilterType = filterTypeOfPhotoData;
            
            [self.dataReceiveDelegate didReceiveData:data];
            
            data = [[PEMessage alloc] init];
            data.messageType = MessageTypePhotoDataReceiveFinish;
            data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
            
            [self.dataReceiveDelegate didReceiveData:data];
            
            return;
        }
        
        //didReceivedData : receive photo data - CroppedImage
        PEMessage *data = [[PEMessage alloc] init];
        data.messageType = MessageTypePhotoDataInsert;
        data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
        data.photoDataType = dataTypeOfPhotoData;
        data.photoDataCroppedImageURL = fileURLOfPhotoData;
        data.photoDataFilterType = filterTypeOfPhotoData;
        
        [self.dataReceiveDelegate didReceiveData:data];
        
        return;
    }
    
    if ([dataTypeOfPhotoData isEqualToString:PhotoTypeOriginal]) {
        if (error) {
            //Error.
            NSLog(@"%@", [error localizedDescription]);
            PEMessage *data = [[PEMessage alloc] init];
            data.messageType = MessageTypePhotoDataReceiveError;
            data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
            data.photoDataType = dataTypeOfPhotoData;
            
            [self.dataReceiveDelegate didReceiveData:data];
            return;
        }
        
        //didReceivedData : receive photo data - Original Image
        PEMessage *data = [[PEMessage alloc] init];
        data.messageType = MessageTypePhotoDataInsert;
        data.photoDataIndexPath = [NSIndexPath indexPathForItem:indexOfPhotoData inSection:0];
        data.photoDataType = dataTypeOfPhotoData;
        data.photoDataOriginalImageURL = fileURLOfPhotoData;
        data.photoDataFilterType = filterTypeOfPhotoData;
        
        [self.dataReceiveDelegate didReceiveData:data];
        
        //didReceivedData : receive finish photo data
        data = [[PEMessage alloc] init];
        data.messageType = MessageTypePhotoDataReceiveFinish;
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
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStatePoweredOff:
            self.availiableState = AvailiableStateDisable;
            break;
        case CBCentralManagerStatePoweredOn:
            self.availiableState = AvailiableStateEnable;
            break;
    }
}

@end