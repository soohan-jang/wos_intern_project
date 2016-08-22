//
//  SelectPhotoFrameViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "SelectPhotoFrameViewController.h"

#import "CommonConstants.h"
#import "ConnectionManager.h"
#import "PhotoFrameDataController.h"

#import "EditPhotoViewController.h"

#import "ProgressHelper.h"
#import "AlertHelper.h"
#import "DispatchAsyncHelper.h"
#import "MessageFactory.h"

NSString *const SegueMoveToEditor = @"moveToPhotoEditor";

@interface SelectPhotoFrameViewController () <UICollectionViewDelegateFlowLayout, ConnectionManagerSessionDelegate, ConnectionManagerPhotoFrameDelegate, PhotoFrameDataControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong, nonatomic) PhotoFrameDataController *dataController;
@property (strong, nonatomic) WMProgressHUD *progressView;

@end

@implementation SelectPhotoFrameViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self checkConnectionState]) {
        [self receivedPeerDisconnected];
        return;
    }
    
    [self prepareDataController];
    [self prepareConnectionManager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //View가 화면에 표시된 이후에 동기화하여, 동기화할 내용이 화면에 제대로 표시될 수 있도록 한다.
    [self startMessageSynchronize];
    
    //동기화 종료 이후, 스크린 정보를 상대방에게 보낸다.
    [self sendScreenSizeMessage];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.dataController clearController];
    self.dataController.delegate = nil;
    self.dataController = nil;
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.photoFrameDelegate = nil;
    connectionManager.photoFrameDataDelegate = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueMoveToEditor]) {
        EditPhotoViewController *viewController = [segue destinationViewController];
        [viewController setPhotoFrameNumber:self.dataController.ownSelectedIndexPath.item];
    }
}

- (void)dealloc {
    self.dataController = nil;
    self.progressView = nil;
}


#pragma mark - Check Session State

- (BOOL)checkConnectionState {
    if ([ConnectionManager sharedInstance].sessionState == MCSessionStateConnected) {
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

- (void)prepareConnectionManager {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionDelegate = self;
    connectionManager.photoFrameDelegate = self;
}


#pragma mark - Message Synchronize Methods

- (void)startMessageSynchronize {
    //동기화 큐를 사용하지 않음으로 변경하고, 동기화 작업을 수행한다.
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    [connectionManager setMessageQueueEnabled:NO];
    
    while (![connectionManager isMessageQueueEmpty]) {
        NSDictionary *message = [connectionManager getMessage];
        [self.dataController setSelectedCellAtIndexPath:message[kPhotoFrameIndexPath] isOwnSelection:NO];
    }
}


#pragma mark - Send Screen Size Method
//이 부분은 ConnectionManager의 MessageSender로 분리할 예정.

- (void)sendScreenSizeMessage {
    NSDictionary *message = [MessageFactory messageGenerateScreenSize:[UIScreen mainScreen].bounds.size];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)sendSelectedFrameMessage:(NSIndexPath *)indexPath {
    NSDictionary *message = [MessageFactory messageGeneratePhotoFrameSelected:indexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)sendConfirmRequestMessage {
    NSDictionary *message = [MessageFactory messageGeneratePhotoFrameRequestConfirm:self.dataController.ownSelectedIndexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)sendConfirmAckMessage:(BOOL)ack {
    NSDictionary *message = [MessageFactory messageGeneratePhotoFrameConfirmed:ack];
    [[ConnectionManager sharedInstance] sendMessage:message];
}


#pragma mark - Present Other ViewController Methods

- (void)presentEditPhotoViewController {
    [self performSegueWithIdentifier:SegueMoveToEditor sender:self];
}

- (void)presentMainViewController {
    [[ConnectionManager sharedInstance] disconnectSession];
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
    [self sendConfirmRequestMessage];
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataController sizeOfCell:self.collectionView.bounds.size];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.dataController edgeInsets:self.collectionView.bounds.size];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.dataController setSelectedCellAtIndexPath:indexPath isOwnSelection:YES];
    [self sendSelectedFrameMessage:indexPath];
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


#pragma mark - ConnectionManager Session Connect Delegate Methods

- (void)receivedPeerConnected {
    //여기선 세션 연결이 일어날 일이 없다.
    //추후에 세션 연결 끊겼다가 다시 복구되는 경우에나 사용할 것 같다.
}

- (void)receivedPeerDisconnected {
    __weak typeof(self) weakSelf = self;
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
}


#pragma mark - ConnectionManager Photo Frame Control Delegate Methods

- (void)receivedPhotoFrameConfirmRequest:(NSIndexPath *)confirmIndexPath {
    if (!confirmIndexPath)
        return;
    
    [self.dataController setEnableCells:NO];
    
    //전달받은 사진액자의 인덱스패스와 자신이 선택한 인덱스패스가 다를 경우, 전달받은 사진액자의 인덱스패스로 복원한다.
    if (![self.dataController isEqualBothSelectedIndexPath]) {
        [self.dataController setSelectedCellAtIndexPath:confirmIndexPath isOwnSelection:YES];
    }
    
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
                                           
                                           [self sendConfirmAckMessage:NO];
                                           //거절한 경우, 각 셀을 다시 선택 가능하게 만든다.
                                           [self.dataController setEnableCells:YES];
                                       }
                                         otherButton:@"alert_button_text_accept"
                                  otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                      __strong typeof(weakSelf) self = weakSelf;
                                      
                                      if (!self) {
                                          return;
                                      }
                                      
                                      [self sendConfirmAckMessage:YES];
                                      [self presentEditPhotoViewController];
                                  }];
}

- (void)receivedPhotoFrameConfirmAck:(BOOL)confirmAck {
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

- (void)interruptedPhotoFrameConfirm {
    [ProgressHelper dismissProgress:self.progressView];
}

@end
