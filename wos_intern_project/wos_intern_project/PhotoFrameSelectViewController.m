//
//  PhotoFrameSelectViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameSelectViewController.h"

#define DELAY_TIME  1.0f

@interface PhotoFrameSelectViewController ()

@property (nonatomic, strong) ConnectionManager *connectionManager;
@property (nonatomic, strong) MessageSyncManager *messageSyncManager;

@property (nonatomic, strong) NSIndexPath *ownSelectedFrameIndex;
@property (nonatomic, strong) NSIndexPath *connectedPeerSelectedFrameIndex;
@property (nonatomic, strong) WMProgressHUD *progressView;

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

@end

@implementation PhotoFrameSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.ownSelectedFrameIndex = nil;
    self.connectedPeerSelectedFrameIndex = nil;
    
    self.connectionManager = [ConnectionManager sharedInstance];
    self.connectionManager.delegate = self;
    
    self.messageSyncManager = [MessageSyncManager sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //동기화 큐를 사용하지 않음으로 변경하고, 동기화 작업을 수행한다.
    [self.messageSyncManager setMessageQueueEnabled:NO];
    
    //메시지 큐에 메시지가 있다면, 동기화 작업을 수행한다.
    if (![self.messageSyncManager isMessageQueueEmpty]) {
        self.connectedPeerSelectedFrameIndex = [[self.messageSyncManager getMessage] objectForKey:KEY_PHOTO_FRAME_SELECTED];
        
        PhotoFrameSelectViewCell *currentSelectedFrameCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:self.connectedPeerSelectedFrameIndex];
        currentSelectedFrameCell.isConnectedPeerSelected = YES;
        
        [self updateFrameCells:nil currentCell:currentSelectedFrameCell];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (IBAction)backAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnect_ask", nil) message:NSLocalizedString(@"alert_content_session_disconnect_ask", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
    alertView.tag = ALERT_DISCONNECT;
    [alertView show];
}

- (IBAction)doneAction:(id)sender {
    self.doneButton.enabled = NO;
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM)};
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    
    self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:NSLocalizedString(@"progress_title_confirming", nil)];
}

- (void)loadPhotoEditorViewController {
    [self performSegueWithIdentifier:SEGUE_MOVE_TO_EDITOR sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_MOVE_TO_EDITOR]) {
        PhotoEditorViewController *viewController = [segue destinationViewController];
        [viewController setPhotoFrameNumber:self.ownSelectedFrameIndex.item];
    }
}

- (void)sendSelectFrameChanged {
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED),
                               KEY_PHOTO_FRAME_SELECTED: self.ownSelectedFrameIndex};
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
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

- (void)declineProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:NSLocalizedString(@"progress_title_rejected", nil) delay:1 cancel:YES];
    }
}

- (void)acceptProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:NSLocalizedString(@"progress_title_confirmed", nil) delay:1];
    }
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_DISCONNECT) {
        if (buttonIndex == 1) {
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED)};
            
            [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
                [self.messageSyncManager setMessageQueueEnabled:NO];
                [self.messageSyncManager clearMessageQueue];
                
                self.connectionManager.delegate = nil;
                [self.connectionManager disconnectSession];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } else if (alertView.tag == ALERT_DISCONNECTED) {
        //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
        [self.messageSyncManager setMessageQueueEnabled:NO];
        [self.messageSyncManager clearMessageQueue];
        
        self.connectionManager.delegate = nil;
        [self.connectionManager disconnectSession];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView.tag == ALERT_FRAME_CONFIRM) {
        if (buttonIndex == 1) {
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK),
                                       KEY_PHOTO_FRAME_CONFIRM_ACK: @YES};
            
            [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
            
            //액자편집화면 진입 시, 동기화 큐 사용을 허가하고 리소스를 정리한다.
            [self.messageSyncManager setMessageQueueEnabled:YES];
            [self.messageSyncManager clearMessageQueue];
            
            [self loadPhotoEditorViewController];
        } else {
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK),
                                       KEY_PHOTO_FRAME_CONFIRM_ACK: @NO};
            
            [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
        }
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
    PhotoFrameSelectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:REUSE_CELL_FRAME_SLT forIndexPath:indexPath];
    cell.cellIndex = indexPath.item;
    [cell.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%ld", PREFIX_IMAGE_PHOTOFRAME, (long)indexPath.item]]];
    
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
        sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED),
                     KEY_PHOTO_FRAME_SELECTED: [NSNull null]};
    } else {
        sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED),
                     KEY_PHOTO_FRAME_SELECTED: self.ownSelectedFrameIndex};
    }
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_frame_select_confirm", nil) message:NSLocalizedString(@"alert_content_frame_select_confirm", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_decline", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_accept", nil), nil];
        alertView.tag = ALERT_FRAME_CONFIRM;
        [alertView show];
    });
}

- (void)receivedPhotoFrameConfirmAck:(BOOL)confirmAck {
    if (confirmAck) {
        //액자편집화면 진입 시, 동기화 큐 사용을 허가하고 리소스를 정리한다.
        [self.messageSyncManager setMessageQueueEnabled:YES];
        [self.messageSyncManager clearMessageQueue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self acceptProgress];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnected", nil) message:NSLocalizedString(@"alert_content_session_disconnected", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_ok", nil) otherButtonTitles:nil, nil];
        alertView.tag = ALERT_DISCONNECTED;
        [alertView show];
    });
}

@end
