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
#import "MessageSyncManager.h"

#import "WMProgressHUD.h"

#import "PhotoFrameSelectViewCell.h"
#import "PhotoEditorViewController.h"

typedef NS_ENUM(NSInteger, AlertType) {
    ALERT_DISCONNECT = 0,
    ALERT_DISCONNECTED = 1,
    ALERT_FRAME_CONFIRM = 2
};

@interface PhotoFrameSelectViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, ConnectionManagerPhotoFrameSelectDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) NSIndexPath *ownSelectedFrameIndex;
@property (nonatomic, strong) NSIndexPath *connectedPeerSelectedFrameIndex;
@property (nonatomic, strong) WMProgressHUD *progressView;

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
    MessageSyncManager *messageSyncManager = [MessageSyncManager sharedInstance];
    [messageSyncManager setMessageQueueEnabled:NO];
    
    //메시지 큐에 메시지가 있다면, 동기화 작업을 수행한다.
    if ([messageSyncManager isMessageQueueEmpty])
        return;
    
    //지금 단계에서는 메시지큐에 메시지가 하나만 존재한다.
    NSDictionary *message = [messageSyncManager getMessage];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnect_ask", nil) message:NSLocalizedString(@"alert_content_session_disconnect_ask", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
    alertView.tag = ALERT_DISCONNECT;
    [alertView show];
}

- (IBAction)doneButtonTapped:(id)sender {
    self.doneButton.enabled = NO;
    
    NSDictionary *sendData = @{kDataType: @(vDataTypePhotoFrameConfirm)};
    [[ConnectionManager sharedInstance] sendData:sendData];
    
    [self showConfirmProgress];
}

- (void)sendSelectFrameChanged {
    NSDictionary *sendData = @{kDataType: @(vDataTypePhotoFrameSelected),
                               kPhotoFrameSelected: self.ownSelectedFrameIndex};
    [[ConnectionManager sharedInstance] sendData:sendData];
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


#pragma mark - Progress Methods

/**
 ProgressView에 승인 대기 중 메시지를 설정하여 띄운다.
 */
- (void)showConfirmProgress {
    self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:NSLocalizedString(@"progress_title_confirming", nil)];
}

/**
 ProgressView의 상태를 거절로 바꾼 뒤에 종료한다.
 */
- (void)declineProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:NSLocalizedString(@"progress_title_rejected", nil) delay:DelayTime cancel:YES];
    }
}

/**
 ProgressView의 상태를 승인으로 바꾼 뒤에 종료한다.
 */
- (void)acceptProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:NSLocalizedString(@"progress_title_confirmed", nil) delay:DelayTime];
    }
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    if (alertView.tag == ALERT_DISCONNECT) {
        if (buttonIndex == 1) {
            NSDictionary *sendData = @{kDataType: @(vDataTypePhotoFrameDisconnected)};
            [connectionManager sendData:sendData];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DelayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
                [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:NO];
                [connectionManager disconnectSession];
                [self loadMainViewController];
            });
        }
    } else if (alertView.tag == ALERT_DISCONNECTED) {
        //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
        [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:NO];
        [connectionManager disconnectSession];
        
        [self loadMainViewController];
    } else if (alertView.tag == ALERT_FRAME_CONFIRM) {
        BOOL confirmAck;
        
        if (buttonIndex == 1) {
            confirmAck = YES;
            
            //액자편집화면 진입 시, 동기화 큐 사용을 허가하고 리소스를 정리한다.
            [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:YES];
            [self loadPhotoEditorViewController];
        } else {
            confirmAck = NO;
            
        }
        
        NSDictionary *sendData = @{kDataType: @(vDataTypePhotoFrameConfirmAck),
                                   kPhotoFrameSelectedConfirmAck: @(confirmAck)};
        [connectionManager sendData:sendData];
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
    
    NSDictionary *sendData;
    
    if (self.ownSelectedFrameIndex == nil) {
        sendData = @{kDataType: @(vDataTypePhotoFrameSelected),
                     kPhotoFrameSelected: [NSNull null]};
    } else {
        sendData = @{kDataType: @(vDataTypePhotoFrameSelected),
                     kPhotoFrameSelected: self.ownSelectedFrameIndex};
    }
    
    [[ConnectionManager sharedInstance] sendData:sendData];
    
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


#pragma mark - ConnectionManager Delegate Methods

- (void)receivedPhotoFrameSelected:(NSIndexPath *)selectedIndexPath {
    NSIndexPath *prevSelectedFrameIndex = self.connectedPeerSelectedFrameIndex;
    self.connectedPeerSelectedFrameIndex = selectedIndexPath;
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFrameCells:prevSelectedFrameCell currentCell:currentSelectedFrameCell];
    });
}

- (void)receivedPhotoFrameRequestConfirm {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_frame_select_confirm", nil)
                                                            message:NSLocalizedString(@"alert_content_frame_select_confirm", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"alert_button_text_decline", nil)
                                                  otherButtonTitles:NSLocalizedString(@"alert_button_text_accept", nil), nil];
        alertView.tag = ALERT_FRAME_CONFIRM;
        [alertView show];
    });
}

- (void)receivedPhotoFrameConfirmAck:(BOOL)confirmAck {
    if (confirmAck) {
        //액자편집화면 진입 시, 동기화 큐 사용을 허가하고 리소스를 정리한다.
        [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self acceptProgress];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DelayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadPhotoEditorViewController];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.doneButton.enabled = YES;
            [self declineProgress];
        });
    }

}

- (void)receivedPhotoFrameDisconnected {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnected", nil)
                                                            message:NSLocalizedString(@"alert_content_session_disconnected", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil)
                                                  otherButtonTitles:nil, nil];
        alertView.tag = ALERT_DISCONNECTED;
        [alertView show];
    });
}

@end
