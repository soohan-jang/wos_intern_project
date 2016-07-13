//
//  PhotoEditorViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@interface PhotoEditorViewController : UIViewController

@property (nonatomic, weak) ConnectionManager *connectionManager;
@property (nonatomic, weak) NSNotificationCenter *notificationCenter;

- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
