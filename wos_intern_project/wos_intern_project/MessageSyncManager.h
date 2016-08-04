//
//  MessageSyncManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 20..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionManager.h"

@interface MessageSyncManager : NSObject

@property (nonatomic, setter=setMessageQueueEnabled:, getter=isMessageQueueEnabled) BOOL messageQueueEnabled;

+ (MessageSyncManager *)sharedInstance;

/**
 Message Queue에 메시지를 저장한다. 메시지는 MessageQueue의 맨 끝에 저장된다.
 */
- (void)putMessage:(NSDictionary *)message;

/**
 Message Queue에서 메시지를 가져온다. 맨 앞의 정보(index 0)를 가져오며, 가져온 정보는 Message Queue에서 제거한다.
 */
- (NSDictionary *)getMessage;

/**
 Message Queue에 저장된 메시지를 비운다.
 */
- (void)clearMessageQueue;

/**
 Message Queue가 비어있는지 여부를 반환한다.
 */
- (BOOL)isMessageQueueEmpty;

@end
