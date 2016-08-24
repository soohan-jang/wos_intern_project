//
//  PEBluetoothSession.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PESession.h"

@interface PEBluetoothSession : PESession


#pragma mark - Bluetooth Browser Methods

- (BOOL)presentBrowserController:(UIViewController *)viewController delegate:(id)delegate;
- (void)clearBluetoothBrowser;

#pragma mark - Bluetooth Advertiser Methods

- (void)setAdvertiserDelegate:(id)delegate;
- (void)startAdvertise;
- (void)stopAdvertise;
- (void)clearBluetoothAdvertiser;

@end