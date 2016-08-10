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

#import "PhotoFrameSelectViewCell.h"
#import "PhotoEditorViewController.h"

#import "ProgressHelper.h"
#import "AlertHelper.h"
#import "DispatchAsyncHelper.h"
#import "MessageFactory.h"

@interface PhotoFrameSelectViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ConnectionManagerSessionConnectDelegate, ConnectionManagerPhotoFrameSelectDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong, nonatomic) NSIndexPath *ownSelectedFrameIndex;
@property (strong, nonatomic) NSIndexPath *connectedPeerSelectedFrameIndex;
@property (strong, nonatomic) WMProgressHUD *progressView;

@end

@implementation PhotoFrameSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self setupConnectionManager];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startMessageSynchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueMoveToEditor]) {
        PhotoEditorViewController *viewController = [segue destinationViewController];
        [viewController setPhotoFrameNumber:self.ownSelectedFrameIndex.item];
    }
}

- (void)setupConnectionManager {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionConnectDelegate = self;
    connectionManager.photoFrameSelectDelegate = self;
}

//여기서는 Cell의 정보를 각 Cell들이 가지고 있는데, 이게 문제가 많은 코드다. 수정이 필요할 것으로 보인다.
- (void)changeCurrentSelectedFrameCellAtIndexPath:(NSIndexPath *)indexPath {
    self.connectedPeerSelectedFrameIndex = indexPath;
    
    PhotoFrameSelectViewCell *currentSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    currentSelectedFrameCell.isConnectedPeerSelected = YES;
    
    [self updateFrameCells:nil currentCell:currentSelectedFrameCell];
}

- (void)dealloc {
    [ConnectionManager sharedInstance].photoFrameSelectDelegate = nil;
    self.ownSelectedFrameIndex = nil;
    self.connectedPeerSelectedFrameIndex = nil;
    self.progressView = nil;
}


#pragma mark - Message Synchronize Methods

- (void)startMessageSynchronize {
    //동기화 큐를 사용하지 않음으로 변경하고, 동기화 작업을 수행한다.
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    [connectionManager setMessageQueueEnabled:NO];
    
    //메시지 큐에 메시지가 있다면, 동기화 작업을 수행한다.
    if ([connectionManager isMessageQueueEmpty])
        return;
    
    //지금 단계에서는 메시지큐에 메시지가 하나만 존재한다.
    NSDictionary *message = [connectionManager getMessage];
    [self changeCurrentSelectedFrameCellAtIndexPath:message[kPhotoFrameSelected]];
}


#pragma mark - Load Other ViewController Methods

- (void)loadPhotoEditorViewController {
    [self performSegueWithIdentifier:SegueMoveToEditor sender:self];
}

- (void)loadMainViewController {
    [[ConnectionManager sharedInstance] disconnectSession];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - EventHandle Methods

- (IBAction)backButtonTapped:(id)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertAction *noActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_no" handler:nil];
    UIAlertAction *yesActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_yes"
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       __strong typeof(weakSelf) self = weakSelf;
                                                                       //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
                                                                       ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
                                                                       connectionManager.sessionConnectDelegate = nil;
                                                                       connectionManager.photoFrameSelectDelegate = nil;
                                                                       [connectionManager disconnectSession];
                                                                       
                                                                       [self loadMainViewController];
                                                                   }];
                                             
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_session_disconnect_ask"
                                          messageKey:@"alert_content_session_disconnect_ask"
                                         firstButton:noActionButton
                                        secondButton:yesActionButton];
}

- (IBAction)doneButtonTapped:(id)sender {
    self.doneButton.enabled = NO;
    
    NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameRequestConfirm:self.ownSelectedFrameIndex];
    [[ConnectionManager sharedInstance] sendMessage:message];
    
    if (!self.progressView.isHidden)
        [ProgressHelper dismissProgress:self.progressView];
    
    if (self.progressView)
        self.progressView = nil;
    
    self.progressView = [ProgressHelper showProgressAddedTo:self.view titleKey:@"progress_title_confirming"];
    
    if (self.ownSelectedFrameIndex.item != self.connectedPeerSelectedFrameIndex.item) {
        PhotoFrameSelectViewCell *selectedCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.ownSelectedFrameIndex];
        PhotoFrameSelectViewCell *confirmCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.connectedPeerSelectedFrameIndex];
        
        selectedCell.isConnectedPeerSelected = YES;
        confirmCell.isConnectedPeerSelected = NO;
        
        self.connectedPeerSelectedFrameIndex = self.ownSelectedFrameIndex;
        [self updateFrameCells:selectedCell currentCell:confirmCell];
        self.doneButton.enabled = NO;
    }
}

- (void)updateFrameCells:(PhotoFrameSelectViewCell *)prevCell currentCell:(PhotoFrameSelectViewCell *)currentCell {
    if (prevCell != nil) {
        [prevCell changeFrameImage];
    }
    
    if (currentCell != nil) {
        [currentCell changeFrameImage];
    }
    
    if (self.ownSelectedFrameIndex != nil && self.connectedPeerSelectedFrameIndex != nil && self.ownSelectedFrameIndex.item == self.connectedPeerSelectedFrameIndex.item) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}


#pragma mark - CollectionViewController DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoFrameSelectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseCellFrameSlt forIndexPath:indexPath];
    cell.cellIndex = indexPath.item;
    [cell.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%ld", PrefixImagePhotoFrame, (long)indexPath.item]]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *prevSelectedFrameIndex = self.ownSelectedFrameIndex;
    self.ownSelectedFrameIndex = indexPath;
    
    PhotoFrameSelectViewCell *prevSelectedFrameCell;
    PhotoFrameSelectViewCell *currentSelectedFrameCell;
    
    //이미 선택한 액자가 있는 경우,
    if (prevSelectedFrameIndex != nil) {
        //선택된 액자와 현재 선택된 액자의 인덱스가 같으면, 선택해제에 해당한다.
        if (prevSelectedFrameIndex.item == self.ownSelectedFrameIndex.item) {
            currentSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.ownSelectedFrameIndex];
            currentSelectedFrameCell.isOwnSelected = NO;
            //현재 선택된 액자가 없으므로, nil을 할당한다.
            self.ownSelectedFrameIndex = nil;
        //인덱스가 다르면, 이전 셀의 선택을 해제하여 상태를 변경하고 현재 셀을 선택 상태로 변경한다.
        } else {
            prevSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:prevSelectedFrameIndex];
            currentSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.ownSelectedFrameIndex];
            
            prevSelectedFrameCell.isOwnSelected = NO;
            currentSelectedFrameCell.isOwnSelected = YES;
        }
    //이미 선택된 액자가 없으면, 현재 선택된 셀을 선택 상태로 변경한다.
    } else {
        currentSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.ownSelectedFrameIndex];
        currentSelectedFrameCell.isOwnSelected = YES;
    }
    
    [prevSelectedFrameCell changeFrameImage];
    [currentSelectedFrameCell changeFrameImage];
    
    NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameSelected:self.ownSelectedFrameIndex];
    [[ConnectionManager sharedInstance] sendMessage:message];
    
    if (self.ownSelectedFrameIndex != nil && self.connectedPeerSelectedFrameIndex != nil && self.ownSelectedFrameIndex.item == self.connectedPeerSelectedFrameIndex.item) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //한 라인에 셀 3개를 배치한다. 따라서 셀 간의 간격은 2곳이 생긴다.
    CGFloat cellBetweenSpace = 20.0f * 2.0f;
    CGFloat cellWidth = (self.collectionView.bounds.size.width - cellBetweenSpace) / 3.0f;
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //셀의 높이는 너비와 같다. 셀은 가로로 4개가 배치되므로, 셀 너비값의 4배가 각 셀의 높이를 합한 값이 된다.
    CGFloat cellBetweenSpace = 20.0f * 2.0f;
    CGFloat cellsHeight = ((self.collectionView.bounds.size.width - cellBetweenSpace) / 3.0f) * 4.0f;
    //셀 간의 간격은 3곳이 생기며, 라인 간 간격은 20으로 정의되어 있다.
    CGFloat cellsBetweenSpace = 20.0f * 3.0f;
    //남은 공간의 절반을 상단의 inset으로 지정하면, 수직으로 중간에 정렬시킬 수 있다.
    CGFloat topInset = (self.collectionView.bounds.size.height - cellsHeight - cellsBetweenSpace) / 2.0f;
    
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}


#pragma mark - ConnectionManager Session Connect Delegate Methods

- (void)receivedPeerConnected {
    
}

- (void)receivedPeerDisconnected {
    __weak typeof(self) weakSelf = self;
    UIAlertAction *okActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_ok"
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      __strong typeof(weakSelf) self = weakSelf;
                                                                      //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
                                                                      ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
                                                                      connectionManager.sessionConnectDelegate = nil;
                                                                      connectionManager.photoFrameSelectDelegate = nil;
                                                                      [connectionManager disconnectSession];
                                                                      
                                                                      [self loadMainViewController];
                                                                  }];
    
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self)
            return;
        
        [AlertHelper showAlertControllerOnViewController:self
                                                titleKey:@"alert_title_session_disconnected"
                                              messageKey:@"alert_content_session_disconnected"
                                             firstButton:okActionButton secondButton:nil];
    }];
}


#pragma mark - ConnectionManager Photo Frame Select Delegate Methods

- (void)receivedPhotoFrameSelected:(NSIndexPath *)indexPath {
    NSIndexPath *prevSelectedFrameIndex = self.connectedPeerSelectedFrameIndex;
    self.connectedPeerSelectedFrameIndex = indexPath;
    
    PhotoFrameSelectViewCell *prevSelectedFrameCell;
    PhotoFrameSelectViewCell *currentSelectedFrameCell;
    
    //이미 선택한 액자가 있는 경우,
    if (prevSelectedFrameIndex != nil) {
        //전달받은 액자의 인덱스값이 nil이면 선택해제된 것으로 간주한다.
        if (self.connectedPeerSelectedFrameIndex == nil) {
            currentSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:prevSelectedFrameIndex];
            currentSelectedFrameCell.isConnectedPeerSelected = NO;
            //전달받은 액자의 값이 있다면, 액자가 선택된 것으로 간주한다.
        } else {
            prevSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:prevSelectedFrameIndex];
            currentSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.connectedPeerSelectedFrameIndex];
            
            prevSelectedFrameCell.isConnectedPeerSelected = NO;
            currentSelectedFrameCell.isConnectedPeerSelected = YES;
        }
        //이미 선택된 액자가 없으면, 현재 선택된 셀을 선택 상태로 변경한다.
    } else {
        currentSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.connectedPeerSelectedFrameIndex];
        currentSelectedFrameCell.isConnectedPeerSelected = YES;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self)
            return;
        
        [self updateFrameCells:prevSelectedFrameCell currentCell:currentSelectedFrameCell];
    });
}

- (void)receivedPhotoFrameRequestConfirm:(NSIndexPath *)confirmIndexPath {
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *declineActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_decline"
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                                           __strong typeof(weakSelf) self = weakSelf;
                                                                           if (!self || !self.doneButton)
                                                                               return;
                                                                           
                                                                           NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameConfirmed:NO];
                                                                           [[ConnectionManager sharedInstance] sendMessage:message];
                                                                           self.doneButton.enabled = YES;
                                                                       }];
    
    UIAlertAction *acceptActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_accept"
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          //액자편집화면 진입 시, 동기화 큐 사용을 허가하고 리소스를 정리한다.
                                                                          ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
                                                                          NSDictionary *message = [MessageFactory MessageGeneratePhotoFrameConfirmed:YES];
                                                                          
                                                                          [connectionManager sendMessage:message];
                                                                          [connectionManager clearMessageQueue];
                                                                          [connectionManager setMessageQueueEnabled:YES];
                                                                          
                                                                          [DispatchAsyncHelper dispatchAsyncWithBlock:^{
                                                                              __strong typeof(weakSelf) self = weakSelf;
                                                                              if (!self)
                                                                                  return;
                                                                              
                                                                              [self loadPhotoEditorViewController];
                                                                          } delay:DelayTime];
                                                                      }];
    
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self)
            return;
        
        [AlertHelper showAlertControllerOnViewController:self
                                                titleKey:@"alert_title_frame_select_confirm"
                                              messageKey:@"alert_content_frame_select_confirm"
                                             firstButton:declineActionButton secondButton:acceptActionButton];
        
        //액자 선택 Alert이 표시된 이후에 액자 변경이 일어났는지를 확인하고, 일어났다면 복원한다.
        if (self.ownSelectedFrameIndex != confirmIndexPath) {
            PhotoFrameSelectViewCell *selectedCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.ownSelectedFrameIndex];
            PhotoFrameSelectViewCell *confirmCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:confirmIndexPath];
            
            selectedCell.isOwnSelected = NO;
            confirmCell.isOwnSelected = YES;
            
            self.ownSelectedFrameIndex = confirmIndexPath;
            [self updateFrameCells:selectedCell currentCell:confirmCell];
            self.doneButton.enabled = NO;
        }
    }];
}

- (void)receivedPhotoFrameConfirmAck:(BOOL)confirmAck {
    __weak typeof(self) weakSelf = self;
    
    if (confirmAck) {
        //액자편집화면 진입 시, 동기화 큐 사용을 허가하고 리소스를 정리한다.
        ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
        [connectionManager clearMessageQueue];
        [connectionManager setMessageQueueEnabled:YES];
        
        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || !self.progressView)
                return;
            
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_confirmed" dismissType:DismissWithDone];
        }];
        
        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self)
                return;
            
            [self loadPhotoEditorViewController];
        } delay:DelayTime];
    } else {
        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || !self.doneButton || !self.progressView)
                return;
            
            self.doneButton.enabled = YES;
            [ProgressHelper dismissProgress:self.progressView dismissTitleKey:@"progress_title_rejected" dismissType:DismissWithCancel];
        }];
    }
}

- (void)interruptedPhotoFrameConfirmProgress {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.progressView)
            return;
        
        [ProgressHelper dismissProgress:self.progressView];
    }];
}

@end
