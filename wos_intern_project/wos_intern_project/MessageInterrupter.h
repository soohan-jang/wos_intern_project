//
//  MessageInterrupter.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageInterrupter : NSObject

@property (nonatomic, assign) NSTimeInterval sendMessageTimestamp;
@property (nonatomic, assign) NSTimeInterval recvMessageTimestamp;

@property (nonatomic, strong) NSIndexPath *sendIndexPath;
@property (nonatomic, strong) NSIndexPath *recvIndexPath;

@property (nonatomic, strong) NSUUID *sendUUID;
@property (nonatomic, strong) NSUUID *recvUUID;

+ (instancetype)sharedInstance;

- (BOOL)isMessageSendInterrupt:(NSTimeInterval)timestamp;
- (BOOL)isMessageSendInterrupt:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath;
- (BOOL)isMessageSendInterrupt:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid;

- (BOOL)isMessageRecvInterrupt:(NSTimeInterval)timestamp;
- (BOOL)isMessageRecvInterrupt:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath;
- (BOOL)isMessageRecvInterrupt:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid;

@end