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
@property (nonatomic, strong) NSIndexPath *ownSelectedFrameIndex;
@property (nonatomic, strong) NSIndexPath *connectedPeerSelectedFrameIndex;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) WMProgressHUD *progressView;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

/**
 NotificationCenter에 필요한 Observer를 등록한다.
 액자 선택, 액자 선택 해제를 처리하기 위한 Observer를 등록한다.
 */
- (void)addObservers;

/**
 NotificationCenter에 등록한 Observer를 등록해제한다.
 액자 선택, 액자 선택 해제를 처리하기 위한 Observer를 등록해제한다.
 */
- (void)removeObservers;

/**
 ProgressHUD를 거절메시지 표시로 변경한다.
 */
- (void)declineProgress;

/**
 ProgressHUD를 승인메시지 표시로 변경한다.
 */
- (void)acceptProgress;

/**
 PhotoEditorViewController로 이동한다. prepareSegue에서 최종선택된 액자정보를 PhotoEditorViewController에 전달한다.
 */
- (void)loadPhotoEditorViewController;

/**
 상대방에게 액자를 선택헀음을 알리기 위해 호출되는 함수이다.
 */
- (void)sendSelectFrameChanged;

/**
 변경된 셀들의 상태를 갱신하기 위해 호출되는 함수이다.
 */
- (void)updateFrameCells:(PhotoFrameSelectViewCell *)prevCell currentCell:(PhotoFrameSelectViewCell *)currentCell;

/**
 상대방이 액자를 선택했을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedSelectFrameChanged:(NSNotification *)notification;
- (void)receivedSelectFrameConfirm:(NSNotification *)notification;
- (void)receivedSelectFrameConfirmAck:(NSNotification *)notification;
- (void)receivedSessionDisconnected:(NSNotification *)notification;

@end