//
//  MainViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ConnectionManager.h"
#import "PhotoFrameSelectViewController.h"

@interface MainViewController : UIViewController <MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) ConnectionManager *connectionManager;
@property (nonatomic, weak) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) NSArray *invitationArray;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) BOOL isBrowser;
@property (nonatomic) BOOL isAdvertiser;

- (void)sessionConnected:(NSNotification *)notification;
- (void)sessionDisconnected:(NSNotification *)notification;

@end

