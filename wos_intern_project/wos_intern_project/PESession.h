//
//  PESession.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEMessage.h"

typedef NS_ENUM(NSInteger, SessionType) {
    SessionTypeBluetooth        = 0
};

typedef NS_ENUM(NSInteger, AvailiableStateType) {
    AvailiableStateUnknown      = 0,
    AvailiableStateDisable,
    AvailiableStateEnable
};

typedef NS_ENUM(NSInteger, SessionStateType) {
    SessionStateConnected       = 0,
    SessionStateConnecting,
    SessionStateDisconnected
};

@protocol SessionConnectDelegate;
@protocol SessionDataReceiveDelegate;

@interface PESession : NSObject

@property (nonatomic, weak) id<SessionConnectDelegate> connectDelegate;
@property (nonatomic, weak) id<SessionDataReceiveDelegate> dataReceiveDelegate;

@property (nonatomic, assign) NSInteger sessionType;

@property (nonatomic, assign) NSInteger availiableState;
@property (nonatomic, assign) NSInteger sessionState;

@property (nonatomic, assign) NSTimeInterval differenceTimestamp;

- (id)instanceOfSession;
- (NSString *)displayNameOfSession;

- (BOOL)sendMessage:(PEMessage *)message;
- (void)sendResource:(PEMessage *)message;

- (void)disconnectSession;

@end

@protocol SessionConnectDelegate <NSObject>
@required
- (void)didChangeSessionState:(NSInteger)state;

@end

@protocol SessionDataReceiveDelegate <NSObject>
@required
- (void)didReceiveData:(PEMessage *)message;

@end