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
#import "PhotoEditorViewController.h"

@interface MainViewController : UIViewController <MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, UIAlertViewDelegate, ConnectionManagerDelegate>

/**
 PhotoAlbum ViewController를 호출한다.
 Storyboard와 연결된 함수이다.
 */
- (IBAction)albumButtonTapped:(id)sender;

@end

