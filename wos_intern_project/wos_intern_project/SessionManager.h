//
//  SessionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PESession.h"

extern NSString *const SessionServiceType;

@interface SessionManager : NSObject

@property (nonatomic, strong) PESession *session;

+ (instancetype)sharedInstance;

- (void)setSession:(PESession *)session;
- (void)sessionDisconnect;

@end
