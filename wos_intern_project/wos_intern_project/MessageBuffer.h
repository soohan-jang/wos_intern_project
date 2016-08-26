//
//  MessageBuffer.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PESession.h"
#import "PEMessage.h"

@interface MessageBuffer : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

- (void)putMessage:(PEMessage *)message;
- (PEMessage *)getMessage;
- (void)clearMessageBuffer;

- (BOOL)isMessageBufferEmpty;
- (BOOL)isMessageBufferEnabled;

@end