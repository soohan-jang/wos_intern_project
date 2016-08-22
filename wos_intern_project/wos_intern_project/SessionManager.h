//
//  SessionManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneralSession.h"

@interface SessionManager : NSObject

@property (nonatomic, strong, readonly) GeneralSession *session;

+ (instancetype)sharedInstance;

- (instancetype)initWithSession:(GeneralSession *)session;
- (void)sessionDisconnect;

@end
