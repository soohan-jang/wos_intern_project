//
//  PEBluetoothSession.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PESession.h"

#import "BluetoothBrowser.h"
#import "BluetoothAdvertiser.h"

@interface PEBluetoothSession : PESession


#pragma mark - Bluetooth Browser Methods

- (BOOL)presentBrowserController:(UIViewController *)viewController delegate:(id<BluetoothBrowserDelegate>)delegate;
- (void)clearBluetoothBrowser;

#pragma mark - Bluetooth Advertiser Methods

- (BOOL)prepareAdvertiser:(id<BluetoothAdvertiserDelegate>)delegate;
- (void)startBluetoothAdvertise;
- (void)stopBluetoothAdvertise;
- (void)clearBluetoothAdvertiser;

@end