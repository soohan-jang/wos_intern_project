//
//  MessageInterrupter.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PEMessageInterrupter : NSObject

@property (nonatomic, assign) NSTimeInterval sendMessageTimestamp;
@property (nonatomic, assign) NSTimeInterval recvMessageTimestamp;

@property (nonatomic, strong) NSIndexPath *sendIndexPath;
@property (nonatomic, strong) NSIndexPath *recvIndexPath;

@property (nonatomic, strong) NSUUID *sendUUID;
@property (nonatomic, strong) NSUUID *recvUUID;

+ (instancetype)sharedInstance;

- (BOOL)isInterruptSendMessage:(NSTimeInterval)timestamp;
- (BOOL)isInterruptSendMessage:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath;
- (BOOL)isInterruptSendMessage:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid;

- (BOOL)isInterruptRecvMessage:(NSTimeInterval)timestamp;
- (BOOL)isInterruptRecvMessage:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath;
- (BOOL)isInterruptRecvMessage:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid;

- (void)clearInterrupter;

@end