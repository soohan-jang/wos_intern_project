//
//  GeneralSession.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageData.h"

typedef NS_ENUM(NSInteger, SessionType) {
    SessionTypeBluetooth        = 0
};

typedef NS_ENUM(NSInteger, AvailiableStateType) {
    AvailiableStateUnknown      = 0,
    AvailiableStateUnsupported,
    AvailiableStateUnauthorized,
    AvailiableStateResetting,
    AvailiableStatePowerOff,
    AvailiableStatePowerOn
};

typedef NS_ENUM(NSInteger, SessionStateType) {
    SessionStateConnected       = 0,
    SessionStateConnecting,
    SessionStateDisconnected
};

@protocol SessionConnectDelegate;
@protocol SessionDataReceiveDelegate;

@interface GeneralSession : NSObject

@property (nonatomic, weak) id<SessionConnectDelegate> connectDelegate;
@property (nonatomic, weak) id<SessionDataReceiveDelegate> dataReceiveDelegate;

@property (nonatomic, assign) NSInteger sessionType;

@property (nonatomic, assign) NSInteger availiableState;
@property (nonatomic, assign) NSInteger sessionState;

- (NSString *)displayNameOfSession;
- (BOOL)sendMessage:(MessageData *)message;
- (void)sendResource:(MessageData *)message resultBlock:(void (^)(BOOL success))resultHandler;

- (void)disconnect;

@end

@protocol SessionConnectDelegate <NSObject>
@required
- (void)didChangeAvailiableState:(NSInteger)state;
- (void)didChangeSessionState:(NSInteger)state;

@end

@protocol SessionDataReceiveDelegate <NSObject>
@required
- (void)didReceiveData:(MessageData *)message;

@end