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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    [self setupConnectionManager];
    [self setupCellManager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startMessageSynchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueMoveToEditor]) {
        PhotoEditorViewController *viewController = [segue destinationViewController];
        [viewController setPhotoFrameNumber:self.cellManager.ownSelectedIndexPath.item];
    }
}

- (void)setupCellManager {
    self.cellManager = [[PhotoFrameSelectCellManager alloc] init];
    self.cellManager.delegate = self;
}

- (void)setupConnectionManager {
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


#pragma mark - Present Other ViewController Methods

- (void)presentPhotoEditorViewController {
    //통신과 관련된 Delegate의 연결을 끊는다.
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    [connectionManager setSessionDelegate:nil];
    [connectionManager setPhotoFrameControlDelegate:nil];
    [connectionManager setPhotoFrameDataDelegate:nil];
    [self.cellManager setDelegate:nil];
    
    //PhotoEditorVC 진입 시, 메시지큐 사용을 활성화한다.
    [connectionManager clearMessageQueue];
    [connectionManager setMessageQueueEnabled:YES];
    [self performSegueWithIdentifier:SegueMoveToEditor sender:self];
}

- (void)presentMainViewController {
    //통신과 관련된 Delegate의 연결을 끊는다.
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    [connectionManager setSessionDelegate:nil];
    [connectionManager setPhotoFrameControlDelegate:nil];
    [connectionManager setPhotoFrameDataDelegate:nil];
    [self.cellManager setDelegate:nil];
    
    //Main VC로 진입 시, 세션 연결을 종료한다.
    [connectionManager disconnectSession];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - EventHandle Methods

- (IBAction)backButtonTapped:(id)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertAction *noActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_no" handler:nil];
    UIAlertAction *yesActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_yes"
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       __strong typeof(weakSelf) self = weakSelf;
                                                                       [self presentMainViewController];
                                                                   }];
                                             
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_session_disconnect_ask"
                                          messageKey:@"alert_content_session_disconnect_ask"
                                         firstButton:noActionButton
                                        secondButton:yesActionButton];
}

- (IBAction)doneButtonTapped:(id)sender {
    self.doneButton.enabled = NO;
    
    //완료 버튼이 눌린 이후에 IndexPath가 변경될 수 있다.
    //따라서 이 곳에서 한번 더 체크를 해준 뒤에 Message를 전송하도록 처리한다.
    if (![self.cellManager isEqualBothSelectedIndexPath]) {
        return;
    }
    
    if (!self.progressView.isHidden) {
        [ProgressHelper dismissProgress:self.progressView];
    }
    
    if (self.progressView) {
        self.progressView = nil;
    }
    
    self.progressView = [ProgressHelper showProgressAddedTo:self.view titleKey:@"progress_title_confirming"];
    
    //만약 ProgressView가 띄워진 후에 값이 바뀌었다면, 값을 복구한다.
    //값을 복구한 뒤에 다시 인덱스를 상대방에게 보내고,
    if (![self.cellManager isEqualBothSelectedIndexPath]) {
        [self collectionView:self.collectionView didSelectItemAtIndexPath:self.cellManager.otherSelectedIndexPath];
    }
    
    //이후에 Confirm Message를 전송한다.
    NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameRequestConfirm:self.cellManager.ownSelectedIndexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
}


#pragma mark - CollectionViewController DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.cellManager getItemNumber];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoFrameSelectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseCellFrameSlt forIndexPath:indexPath];
    cell.frameImageView.image = [self.cellManager getCellImageAtIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.cellManager setSelectedCellAtIndexPath:indexPath isOwnSelection:YES];
    
    NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameSelected:indexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellManager getCellSize:collectionView.bounds.size];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.cellManager getEdgeInsetsOfSection:self.collectionView.bounds.size];
}


#pragma mark - CellManager Delegate

- (void)didUpdateCellStateWithDoneActivate:(BOOL)activate {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
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
        NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameConfirmed:NO];
        [[ConnectionManager sharedInstance] sendMessage:message];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *declineActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_decline"
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                                           __strong typeof(weakSelf) self = weakSelf;
                                                                           if (!self) {
                                                                               return;
                                                                           }
                                                                           
                                                                           NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameConfirmed:NO];
                                                                           [[ConnectionManager sharedInstance] sendMessage:message];
                                                                           
                                                                           self.doneButton.enabled = YES;
                                                                       }];
    
    UIAlertAction *acceptActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_accept"
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          __strong typeof(weakSelf) self = weakSelf;
                                                                          //액자편집화면 진입 시, 동기화 큐 사용을 허가하고 리소스를 정리한다.
                                                                          ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
                                                                          
                                                                          NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameConfirmed:YES];
                                                                          [connectionManager sendMessage:message];
                                                                          
                                                                          [self presentPhotoEditorViewController];
                                                                      }];
    
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_frame_select_confirm"
                                          messageKey:@"alert_content_frame_select_confirm"
                                         firstButton:declineActionButton
                                        secondButton:acceptActionButton];
}


#pragma mark - ConnectionManager Session Connect Delegate Methods

- (void)receivedPeerConnected {
    [ConnectionManager sharedInstance].sessionState = MCSessionStateConnected;
}

- (void)receivedPeerDisconnected {
    [ConnectionManager sharedInstance].sessionState = MCSessionStateNotConnected;
    
    __weak typeof(self) weakSelf = self;
    
    
    
    
    
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        
        UIAlertAction *okActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_ok"
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          if (!self) {
                                                                              return;
                                                                          }
                                                                          
                                                                          [self presentMainViewController];
                                                                      }];
        
        [AlertHelper showAlertControllerOnViewController:self
                                                titleKey:@"alert_title_session_disconnected"
                                              messageKey:@"alert_content_session_disconnected"
                                                  button:okActionButton];
    }];
}


#pragma mark - ConnectionManager Photo Frame Control Delegate Methods

- (void)receivedPhotoFrameConfirmAck:(BOOL)confirmAck {
    __weak typeof(self) weakSelf = self;
    
    if (confirmAck) {
        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
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
        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
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
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        
        [ProgressHelper dismissProgress:self.progressView];
    }];
}

@end
