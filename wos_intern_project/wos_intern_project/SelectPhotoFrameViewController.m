//
//  SelectPhotoFrameViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "SelectPhotoFrameViewController.h"
#import "EditPhotoViewController.h"

#import "CommonConstants.h"

#import "PhotoFrameDataController.h"
#import "SessionManager.h"
#import "MessageReceiver.h"

#import "ProgressHelper.h"
#import "AlertHelper.h"
#import "DispatchAsyncHelper.h"

NSString *const SegueMoveToEditor = @"moveToPhotoEditor";

@interface SelectPhotoFrameViewController () <UICollectionViewDelegateFlowLayout, PhotoFrameDataControllerDelegate, MessageReceiverStateChangeDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong, nonatomic) PhotoFrameDataController *dataController;
@property (strong, nonatomic) WMProgressHUD *progressView;

@property (strong, nonatomic) MessageReceiver *messageReceiver;

@end

@implementation SelectPhotoFrameViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self checkConnectionState]) {
        [self didReceiveChangeSessionState:SessionStateDisconnected];
        return;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self prepareDataController];
    [self prepareMessagerReceiver];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.dataController clearController];
    self.dataController.delegate = nil;
    self.dataController = nil;
    
    self.messageReceiver.stateChangeDelegate = nil;
    self.messageReceiver = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueMoveToEditor]) {
        [[SessionManager sharedInstance] setMessageBufferEnabled:YES];
        
        EditPhotoViewController *viewController = [segue destinationViewController];
        [viewController setPhotoFrameNumber:self.dataController.ownSelectedIndexPath.item];
    }
}

- (void)dealloc {
    self.dataController = nil;
    self.progressView = nil;
    self.messageReceiver = nil;
}


#pragma mark - Check Session State

- (BOOL)checkConnectionState {
    if ([SessionManager sharedInstance].session.sessionState == SessionStateConnected) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Prepare Methods

- (void)prepareDataController {
    self.dataController = [[PhotoFrameDataController alloc] initWithCollectionViewSize:self.collectionView.bounds.size];
    self.dataController.delegate = self;
    self.collectionView.dataSource = (id<UICollectionViewDataSource>)self.dataController;
    self.collectionView.delegate = self;
}

- (void)prepareMessagerReceiver {
    MessageReceiver *messageReceiver = [SessionManager sharedInstance].messageReceiver;
    messageReceiver.stateChangeDelegate = self;
}


#pragma mark - Present Other ViewController Methods

- (void)presentEditPhotoViewController {
    [self performSegueWithIdentifier:SegueMoveToEditor sender:self];
}

- (void)presentMainViewController {
    [[SessionManager sharedInstance] disconnectSession];
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
    [self.dataController setEnableCells:NO];
    
    if (![self.dataController isEqualBothSelectedIndexPath]) {
        __weak typeof(self) weakSelf = self;
        [ProgressHelper dismissProgress:self.progressView
                        dismissTitleKey:@"progress_title_error"
                            dismissType:DismissWithCancel
                      completionHandler:^{
                          __strong typeof(weakSelf) self = weakSelf;
                          
                          if (!self) {
                              return;
                          }
                          
                          [self.dataController setEnableCells:YES];
                      }
        ];
        return;
    }
    
    if (self.progressView || !self.progressView.isHidden) {
        [ProgressHelper dismissProgress:self.progressView];
        self.progressView = nil;
    }
    
    self.progressView = [ProgressHelper showProgressAddedTo:self.navigationController.view
                                                   titleKey:@"progress_title_confirming"];
    
    [self.dataController.dataSender sendPhotoFrameConfrimRequestMessage:self.dataController.ownSelectedIndexPath];
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataController sizeOfCell:self.collectionView.bounds.size];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.dataController edgeInsets:self.collectionView.bounds.size];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.dataController.ownSelectedIndexPath.item) {
        [self.dataController setSelectedCellAtIndexPath:indexPath isOwnSelection:YES];
        [self.dataController.dataSender sendSelectPhotoFrameMessage:indexPath];
    } else {
        [self.dataController setSelectedCellAtIndexPath:indexPath isOwnSelection:YES];
        [self.dataController.dataSender sendDeselectPhotoFrameMessage:indexPath];
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
                                           
                                           [self.dataController.dataSender sendPhotoFrameConfirmAckMessage:NO];
                                           //거절한 경우, 각 셀을 다시 선택 가능하게 만든다.
                                           [self.dataController setEnableCells:YES];
                                       }
                                         otherButton:@"alert_button_text_accept"
                                  otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                      __strong typeof(weakSelf) self = weakSelf;
                                      
                                      if (!self) {
                                          return;
                                      }
                                      
                                      [self.dataController.dataSender sendPhotoFrameConfirmAckMessage:YES];
                                      [self presentEditPhotoViewController];
                                  }];
}

- (void)didReceivePhotoFrameConfirmAck:(BOOL)confirmAck {
    if (confirmAck) {
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
        [self.dataController setEnableCells:YES];
        [ProgressHelper dismissProgress:self.progressView
                        dismissTitleKey:@"progress_title_rejected"
                            dismissType:DismissWithCancel];
    }
}

- (void)didInterruptRequestConfirm {
    [ProgressHelper dismissProgress:self.progressView];
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
