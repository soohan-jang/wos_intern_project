//
//  BluetoothHardwareControlManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothHardwareControlManager : NSObject

@property (nonatomic, strong) CBCentralManager *centralManager;

+ (instancetype)init;
- (BOOL)isSupported;
- (BOOL)isActivated;

@end
