//
//  PhotoFrameSelectViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "PhotoEditorViewController.h"

@interface PhotoFrameSelectViewController : UIPageViewController <UIPageViewControllerDelegate>

@property (nonatomic, weak) ConnectionManager *connectionManager;
@property (nonatomic, weak) NSNotificationCenter *notificationCenter;
@property (nonatomic, getter=isEnableFrameSelect) BOOL isEnableFrameSelect;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

- (void)receivedFrameIndexChanged:(NSNotification *)notification;
- (void)receivedFrameLiked:(NSNotification *)notification;
- (void)receivedFrameSelected:(NSNotification *)notification;

@end
