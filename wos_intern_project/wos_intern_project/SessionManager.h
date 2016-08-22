//
//  SessionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "BluetoothSession.h"

@interface SessionManager : NSObject

@property (nonatomic, strong, readonly) BluetoothSession *session;

- (instancetype)initWithSession:(BluetoothSession *)session;

- (void)sessionDisconnect;

@end
