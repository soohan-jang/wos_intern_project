//
//  SessionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PESession.h"
#import "PEMessageSender.h"
#import "PEMessageReceiver.h"

@interface PESessionManager : NSObject

@property (nonatomic, strong) PESession *session;
@property (nonatomic, strong) PEMessageSender *messageSender;
@property (nonatomic, strong) PEMessageReceiver *messageReceiver;

+ (instancetype)sharedInstance;

- (void)initializeWithSessionType:(NSInteger)sessionType;
- (void)setMessageBufferEnabled:(BOOL)enabled;
- (void)disconnectSession;

- (BOOL)isSessionNil;

@end
