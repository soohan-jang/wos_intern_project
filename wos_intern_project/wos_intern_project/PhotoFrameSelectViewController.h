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
#import "MessageSyncManager.h"

#import "WMProgressHUD.h"

#import "PhotoFrameSelectViewCell.h"
#import "PhotoEditorViewController.h"

typedef NS_ENUM(NSInteger, PhotoFrameSelectAlertType) {
    ALERT_DISCONNECT = 0,
    ALERT_DISCONNECTED = 1,
    ALERT_FRAME_CONFIRM = 2
};

@interface PhotoFrameSelectViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end