//
//  MessageSyncManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 20..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageSyncManager : NSObject

@property (atomic, strong, readonly) NSMutableArray *messageQueue;

+ (MessageSyncManager *)sharedInstance;
- (instancetype)init;
- (void)putMessage:(NSDictionary *)message;
- (NSDictionary *)getMessage;
- (void)clearMessageQueue;
- (BOOL)isMessageQueueEmpty;
@end
