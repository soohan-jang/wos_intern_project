//
//  PhotoFrameSelectViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameSelectViewController.h"

#import "CommonConstants.h"
#import "ConnectionManager.h"
#import "PhotoFrameSelectCellManager.h"

#import "PhotoFrameSelectViewCell.h"
#import "PhotoEditorViewController.h"

#import "ProgressHelper.h"
#import "AlertHelper.h"
#import "DispatchAsyncHelper.h"
#import "MessageFactory.h"

@interface PhotoFrameSelectViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoFrameSelectCellManagerDelegate, ConnectionManagerSessionDelegate, ConnectionManagerPhotoFrameControlDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong, nonatomic) PhotoFrameSelectCellManager *cellManager;
@property (strong, nonatomic) WMProgressHUD *progressView;

@end

@implementation PhotoFrameSelectViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self checkConnectionState]) {
        [self receivedPeerDisconnected];
        return;
    }
    
    [self prepareCellManager];
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
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.photoFrameControlDelegate = nil;
    connectionManager.photoFrameDataDelegate = nil;
    self.cellManager.delegate = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueMoveToEditor]) {
        PhotoEditorViewController *viewController = [segue destinationViewController];
        [viewController setPhotoFrameNumber:self.cellManager.ownSelectedIndexPath.item];
    }
}

- (void)dealloc {
    self.collectionView = nil;
    self.doneButton = nil;
    
    self.cellManager = nil;
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

- (void)prepareCellManager {
    self.cellManager = [[PhotoFrameSelectCellManager alloc] initWithCollectionViewSize:self.collectionView.bounds.size];
    self.cellManager.delegate = self;
}

- (void)prepareConnectionManager {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionDelegate = self;
    connectionManager.photoFrameControlDelegate = self;
}


#pragma mark - Message Synchronize Methods

- (void)startMessageSynchronize {
    //동기화 큐를 사용하지 않음으로 변경하고, 동기화 작업을 수행한다.
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    [connectionManager setMessageQueueEnabled:NO];
    
    while (![connectionManager isMessageQueueEmpty]) {
        NSDictionary *message = [connectionManager getMessage];
        [self.cellManager setSelectedCellAtIndexPath:message[kPhotoFrameIndexPath] isOwnSelection:NO];
    }
}


#pragma mark - Send Screen Size Method

- (void)sendScreenSizeMessage {
    NSDictionary *message = [MessageFactory MessageGenerateScreenSize:[UIScreen mainScreen].bounds.size];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)sendSelectedFrameMessage:(NSIndexPath *)indexPath {
    NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameSelected:indexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)sendConfirmRequestMessage {
    NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameRequestConfirm:self.cellManager.ownSelectedIndexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)sendConfirmAckMessage:(BOOL)ack {
    NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameConfirmed:ack];
    [[ConnectionManager sharedInstance] sendMessage:message];
}


#pragma mark - Present Other ViewController Methods

- (void)presentPhotoEditorViewController {
    [self performSegueWithIdentifier:SegueMoveToEditor sender:self];
}

- (void)presentMainViewController {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    [connectionManager disconnectSession];
    connectionManager.sessionDelegate = nil;
    
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
                                      [self presentMainViewController];
                                  }];
}

- (IBAction)doneButtonTapped:(id)sender {
    self.doneButton.enabled = NO;
    
    //완료 버튼이 눌린 이후에 IndexPath가 변경될 수 있다.
    //따라서 이 곳에서 한번 더 체크를 해준 뒤에 Message를 전송하도록 처리한다.
    if (![self.cellManager isEqualBothSelectedIndexPath]) {
        return;
    }
    
    if (self.progressView || !self.progressView.isHidden) {
        [ProgressHelper dismissProgress:self.progressView];
        self.progressView = nil;
    }
    
    self.progressView = [ProgressHelper showProgressAddedTo:self.view titleKey:@"progress_title_confirming"];
    
    //만약 ProgressView가 띄워진 후에 값이 바뀌었다면, 값을 복구한다.
    //값을 복구한 뒤에 다시 인덱스를 상대방에게 보내고,
    if (![self.cellManager isEqualBothSelectedIndexPath]) {
        [self collectionView:self.collectionView didSelectItemAtIndexPath:self.cellManager.otherSelectedIndexPath];
    }
    
    //이후에 Confirm Message를 전송한다.
    [self sendConfirmRequestMessage];
}


#pragma mark - CollectionViewController DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellManager.numberOfCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoFrameSelectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseCellFrameSlt forIndexPath:indexPath];
    cell.frameImageView.image = [self.cellManager cellImageAtIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.cellManager setSelectedCellAtIndexPath:indexPath isOwnSelection:YES];
    [self sendSelectedFrameMessage:indexPath];
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellManager sizeOfCell:self.collectionView.bounds.size];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.cellManager edgeInsets:self.collectionView.bounds.size];
}


#pragma mark - CellManager Delegate

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

- (void)didRequestConfirmCellWithIndexPath:(NSIndexPath *)indexPath {
    if (self.navigationController.visibleViewController != self) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        
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
                                               self.doneButton.enabled = YES;
                                            }
                                             otherButton:@"alert_button_text_accept"
                                      otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                                __strong typeof(weakSelf) self = weakSelf;
                                                if (!self) {
                                                    return;
                                                }
                                          
                                                [self sendConfirmAckMessage:YES];
                                                [self presentPhotoEditorViewController];
                                            }];
    }];
}


#pragma mark - ConnectionManager Session Connect Delegate Methods

- (void)receivedPeerConnected {
    //여기선 세션 연결이 일어날 일이 없다.
    //추후에 세션 연결 끊겼다가 다시 복구되는 경우에나 사용할 것 같다.
}

- (void)receivedPeerDisconnected {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        [AlertHelper showAlertControllerOnViewController:self
                                                titleKey:@"alert_title_session_disconnected"
                                              messageKey:@"alert_content_session_disconnected"
                                                  button:@"alert_button_text_ok"
                                           buttonHandler:^(UIAlertAction * _Nonnull action) {
                                               if (!self) {
                                                   return;
                                               }
                                               
                                               [self presentMainViewController];
                                           }];
    }];
}


#pragma mark - ConnectionManager Photo Frame Control Delegate Methods

- (void)receivedPhotoFrameConfirmAck:(BOOL)confirmAck {
    __weak typeof(self) weakSelf = self;
    
    if (confirmAck) {
        [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                return;
            }
            
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_confirmed" dismissType:DismissWithDone];
            
            //여기서 딜레이을 준 이유는, ProgressView에 표시되는 "승인됨" 메시지를 보여준 뒤에 이동시키기 위함이다.
            [NSTimer scheduledTimerWithTimeInterval:DelayTime
                                             target:self
                                           selector:@selector(presentPhotoEditorViewController)
                                           userInfo:nil
                                            repeats:NO];
        }];
    } else {
        [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                return;
            }
            
            self.doneButton.enabled = YES;
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_rejected" dismissType:DismissWithCancel];
        }];
    }
}

- (void)interruptedPhotoFrameConfirmProgress {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        
        [ProgressHelper dismissProgress:self.progressView];
    }];
}

@end
