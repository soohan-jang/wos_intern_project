//
//  MessageBuffer.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageData.h"

@interface MessageBuffer : NSObject

@property (nonatomic, assign) BOOL enabled;

+ (instancetype)sharedInstance;

- (void)putMessage:(MessageData *)message;
- (MessageData *)getMessage;
- (void)clearMessageBuffer;
- (BOOL)isMessageBufferEmpty;

@end
