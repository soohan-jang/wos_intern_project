//
//  SelectPhotoFrameViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "SelectPhotoFrameViewController.h"
#import "EditPhotoViewController.h"

#import "PESessionManager.h"
#import "PEMessageReceiver.h"

#import "PEPhotoFrameController.h"

#import "AlertHelper.h"
#import "DispatchAsyncHelper.h"
#import "ProgressHelper.h"

NSString *const SegueMoveToEditor = @"moveToPhotoEditor";

@interface SelectPhotoFrameViewController () <UICollectionViewDelegateFlowLayout, PEPhotoFrameControllerDelegate, PEMessageReceiverStateChangeDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong, nonatomic) PEPhotoFrameController *photoFrameController;
@property (strong, nonatomic) WMProgressHUD *progressView;

@end

@implementation SelectPhotoFrameViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareDataController];
    [self prepareMessagerReceiver];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startSynchronizeMessage];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.photoFrameController clearController];
    self.photoFrameController.delegate = nil;
    self.photoFrameController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueMoveToEditor]) {
        EditPhotoViewController *viewController = [segue destinationViewController];
        [viewController setPhotoFrame:self.photoFrameController.ownSelectedIndexPath.item];
    }
}

- (void)dealloc {
    self.photoFrameController = nil;
    self.progressView = nil;
}


#pragma mark - Check Session State

- (BOOL)checkConnectionState {
    if ([PESessionManager sharedInstance].session.sessionState == SessionStateConnected) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Prepare Methods

- (void)prepareDataController {
    self.photoFrameController = [[PEPhotoFrameController alloc] initWithCollectionViewSize:self.collectionView.bounds.size];
    self.photoFrameController.delegate = self;
    self.collectionView.dataSource = (id<UICollectionViewDataSource>)self.photoFrameController;
    self.collectionView.delegate = self;
}

- (void)prepareMessagerReceiver {
    [PESessionManager sharedInstance].messageReceiver.stateChangeDelegate = self;
}


#pragma mark - Start Synchronize Message Methods

- (void)startSynchronizeMessage {
    [[PESessionManager sharedInstance].messageReceiver startSynchronizeMessage];
}


#pragma mark - Present Other ViewController Methods

- (void)presentEditPhotoViewController {
    [self performSegueWithIdentifier:SegueMoveToEditor sender:self];
}

- (void)presentMainViewController {
    [[PESessionManager sharedInstance] disconnectSession];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - EventHandling

- (IBAction)backButtonTapped:(id)sender {
    __weak typeof(self) weakSelf = self;
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_session_disconnect_ask"
                                          messageKey:@"alert_content_session_disconnect_ask"
                                              button:@"alert_button_text_no"
                                       buttonHandler:nil
                                         otherButton:@"alert_button_text_yes"
                                  otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                      __strong typeof(weakSelf) self = weakSelf;
                                      
                                      if (!self) {
                                          return;
                                      }
                                      
                                      [self presentMainViewController];
                                  }];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self.photoFrameController setEnableCells:NO];
    
    if (!self.progressView.hidden) {
        [ProgressHelper dismissProgress:self.progressView];
    }
    
    if (self.progressView) {
        self.progressView = nil;
    }
    
    self.progressView = [ProgressHelper showProgressAddedTo:self.navigationController.view
                                                   titleKey:@"progress_title_confirming"];
    
    if (![self.photoFrameController isEqualBothSelectedIndexPath]) {
        __weak typeof(self) weakSelf = self;
        [ProgressHelper dismissProgress:self.progressView
                        dismissTitleKey:@"progress_title_error"
                            dismissType:DismissWithCancel
                      completionHandler:^{
                          __strong typeof(weakSelf) self = weakSelf;
                          
                          if (!self) {
                              return;
                          }
                          
                          [self.photoFrameController setEnableCells:YES];
                      }
        ];
        return;
    }
    
    //에러 혹은 인터럽트 발생 시, 위에서 표시했던 ProgressView를 닫는다.
    if (![self.photoFrameController.dataSender sendPhotoFrameConfrimRequestMessage:self.photoFrameController.ownSelectedIndexPath]) {
        [ProgressHelper dismissProgress:self.progressView];
    }
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.photoFrameController sizeOfCell:self.collectionView.bounds.size];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.photoFrameController edgeInsets:self.collectionView.bounds.size];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.photoFrameController.ownSelectedIndexPath.item != indexPath.item) {
        NSIndexPath *prevSelectedIndexPath = self.photoFrameController.ownSelectedIndexPath;
        [self.photoFrameController setSelectedCellAtIndexPath:indexPath isOwnSelection:YES];
        
        //에러 발생 시, 이전 값으로 복원한다.
        if (![self.photoFrameController.dataSender sendSelectPhotoFrameMessage:indexPath]) {
            if (!prevSelectedIndexPath) {
                [self.photoFrameController setDeselectedCellAtIndexPath:indexPath isOwnSelection:YES];
            } else {
                [self.photoFrameController setSelectedCellAtIndexPath:prevSelectedIndexPath isOwnSelection:YES];
            }
        }
    } else {
        [self.photoFrameController setDeselectedCellAtIndexPath:indexPath isOwnSelection:YES];
        
        //에러 발생 시, 이전 값으로 복원한다.
        if (![self.photoFrameController.dataSender sendDeselectPhotoFrameMessage:indexPath]) {
            [self.photoFrameController setSelectedCellAtIndexPath:indexPath isOwnSelection:YES];
        }
    }
}


#pragma mark - PhotoFrameDataController Delegate

- (void)didUpdateCellEnabled:(BOOL)enabled {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        
        if (!self) {
            return;
        }
        
        [self.collectionView reloadData];
    }];
    
}

- (void)didUpdateCellStateWithDoneActivate:(BOOL)activate {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        
        if (!self) {
            return;
        }
        
        [self.collectionView reloadData];
        self.doneButton.enabled = activate;
    }];
}

- (void)didReceiveRequestPhotoFrameConfirm:(NSIndexPath *)indexPath {
    if (self.navigationController.visibleViewController != self) {
        return;
    }
    
    if (self.progressView && !self.progressView.hidden) {
        [ProgressHelper dismissProgress:self.progressView];
    }
    
    __weak typeof(self) weakSelf = self;
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_frame_select_confirm"
                                          messageKey:@"alert_content_frame_select_confirm"
                                              button:@"alert_button_text_decline"
                                       buttonHandler:^(UIAlertAction * _Nonnull action) {
                                           __strong typeof(weakSelf) self = weakSelf;
                                           
                                           if (!self) {
                                               return;
                                           }
                                           
                                           //에러 발생 시, 다시 창을 표시한다. - 근데 계속 에러나면 계속 창이 표시되는데, 다른 방법을 생각해봐야할 듯.
                                           //가령 몇 회 이상 실패하면, 작업을 진행할 수 없는 심각한 상황으로 보고 강제종료시킨다든가.
                                           if (![self.photoFrameController.dataSender sendPhotoFrameConfirmAckMessage:NO]) {
                                               [self didReceiveRequestPhotoFrameConfirm:indexPath];
                                           }
                                           
                                           //거절한 경우, 각 셀을 다시 선택 가능하게 만든다.
                                           [self.photoFrameController setEnableCells:YES];
                                       }
                                         otherButton:@"alert_button_text_accept"
                                  otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                      __strong typeof(weakSelf) self = weakSelf;
                                      
                                      if (!self) {
                                          return;
                                      }
                                      
                                      //에러 발생 시, 다시 창을 표시한다. - 근데 계속 에러나면 계속 창이 표시되는데, 다른 방법을 생각해봐야할 듯.
                                      //가령 몇 회 이상 실패하면, 작업을 진행할 수 없는 심각한 상황으로 보고 강제종료시킨다든가.
                                      if (![self.photoFrameController.dataSender sendPhotoFrameConfirmAckMessage:YES]) {
                                          [self didReceiveRequestPhotoFrameConfirm:indexPath];
                                          return;
                                      }
                                      
                                      [[PESessionManager sharedInstance] setMessageBufferEnabled:YES];
                                      [self presentEditPhotoViewController];
                                  }];
}

- (void)didReceiveRequestPhotoFrameConfirmAck:(BOOL)confirmAck {
    if (confirmAck) {
        [[PESessionManager sharedInstance] setMessageBufferEnabled:YES];
        
        __weak typeof(self) weakSelf = self;
        [ProgressHelper dismissProgress:self.progressView
                        dismissTitleKey:@"progress_title_confirmed"
                            dismissType:DismissWithDone
                      completionHandler:^{
                          __strong typeof(weakSelf) self = weakSelf;
                          
                          if (!self) {
                              return;
                          }
                          
                          [self presentEditPhotoViewController];
                      }
         ];
    } else {
        //reject된 경우, 각 셀을 다시 선택 가능하게 만든다.
        [self.photoFrameController setEnableCells:YES];
        
        [ProgressHelper dismissProgress:self.progressView
                        dismissTitleKey:@"progress_title_rejected"
                            dismissType:DismissWithCancel];
    }
}


#pragma mark - Message Receiver State Change Delegate Methods

- (void)didReceiveChangeSessionState:(NSInteger)state {
    __weak typeof(self) weakSelf = self;
    
    switch (state) {
        case SessionStateConnected:
            //여기선 세션 연결이 일어날 일이 없다.
            //추후에 세션 연결 끊겼다가 다시 복구되는 경우에나 사용할 것 같다.
            break;
        case SessionStateDisconnected:
            [AlertHelper showAlertControllerOnViewController:self
                                                    titleKey:@"alert_title_session_disconnected"
                                                  messageKey:@"alert_content_session_disconnected"
                                                      button:@"alert_button_text_ok"
                                               buttonHandler:^(UIAlertAction * _Nonnull action) {
                                                   __strong typeof(weakSelf) self = weakSelf;
                                                   
                                                   if (!self) {
                                                       return;
                                                   }
                                                   
                                                   [self presentMainViewController];
                                               }];
            break;
    }
}

@end
