//
//  MainViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "CommonConstants.h"

#import "ConnectionManager.h"
#import "MessageSyncManager.h"

#import "WMProgressHUD.h"
#import "PhotoFrameSelectViewController.h"

extern NSString *const NOTIFICATION_POP_ROOT_VIEW_CONTROLLER;

@interface MainViewController : UIViewController <MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, UIAlertViewDelegate, ConnectionManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *albumButton;

@end

