//
//  BluetoothHardwareControlManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 12..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "BluetoothHardwareControlManager.h"

@implementation BluetoothHardwareControlManager

+ (instancetype)init {
    BluetoothHardwareControlManager *bluetoothHardwareManager = [[super alloc] init];
    bluetoothHardwareManager.centralManager = [[CBCentralManager alloc] init];
    
    return bluetoothHardwareManager;
}

- (BOOL) isSupported {
    if (self.centralManager.state == CBCentralManagerStateUnsupported) {
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL) isActivated {
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
