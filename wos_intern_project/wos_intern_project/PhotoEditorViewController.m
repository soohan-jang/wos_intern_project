//
//  PhotoEditorViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.collectionView.parentViewController = self;
    self.collectionView.photoFrameNumber = self.photoFrameNumber;
    
    [self addObservers];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //문제의 해결방법을 몰라서, 우선 더미데이터를 하나 보내는 것으로 발생하는 문제를 회피한다.
//        UIImage *dummy = [UIImage imageNamed:@"Done"];
//        NSString *fileName = [[ImageUtility sharedInstance] saveImageAtTemporaryDirectoryForDummy:dummy];
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), fileName]];
//        [[ConnectionManager sharedInstance].ownSession sendResourceAtURL:url withName:@"test" toPeer:[ConnectionManager sharedInstance].ownSession.connectedPeers[0] withCompletionHandler:^(NSError *error){
//            [[ImageUtility sharedInstance] removeAllTempImages];
//        }];
//        //위의 방법은 해결방법이 아니다!! 반드시 해당 문제를 해결해야 한다.
//    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnect_ask", nil) message:NSLocalizedString(@"alert_content_data_not_save", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
    alertView.tag = ALERT_NOT_SAVE;
    [alertView show];
}

- (IBAction)saveAction:(id)sender {
//    [[ConnectionManager sharedInstance] disconnectSession];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)photoButtonAction:(id)sender {
}

- (IBAction)penButtonAction:(id)sender {
}

- (IBAction)textButtonAction:(id)sender {
}

- (IBAction)stickerButtonAction:(id)sender {
}

- (IBAction)eraserButtonAction:(id)sender {
}

- (IBAction)StickerButtonAction:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"moveToPhotoCrop"]) {
        PhotoCropViewController *viewController = [segue destinationViewController];
        viewController.delegate = self;
        //picker에서 imageURL을 가져오지 못한 경우엔, 이 구문이 실행되지 않는다.
        //이 구문이 실행되는 경우는, picker를 거치지 않고 직접적으로 CropViewController를 호출한 경우이다.
        //즉, 이미 존재하는 데이터에 대해서 편집을 하고자 할 경우에 해당한다.
        if (self.collectionView.selectedImageURL == nil) {
            viewController.fullscreenImage = [self.collectionView getCellFullscreenImageOfSelectedIndex];
        }
        else {
            viewController.imageUrl = self.collectionView.selectedImageURL;
        }
        viewController.cellSize = [self.collectionView getSizeOfSelectedCell];
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPhotoInsert:) name:NOTIFICATION_RECV_EDITOR_PHOTO_INSERT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPhotoInsertAck:) name:NOTIFICATION_RECV_EDITOR_PHOTO_INSERT_ACK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPhotoEdit:) name:NOTIFICATION_RECV_EDITOR_PHOTO_EDIT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPhotoEditCanceled:) name:NOTIFICATION_RECV_EDITOR_PHOTO_EDIT_CANCELED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPhotoDelete:) name:NOTIFICATION_RECV_EDITOR_PHOTO_DELETE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSelectFrameChanged:) name:NOTIFICATION_RECV_EDITOR_DRAWING_INSERT object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSelectFrameChanged:) name:NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSelectFrameConfirm:) name:NOTIFICATION_RECV_EDITOR_DRAWING_DELETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSessionDisconnected:) name:NOTIFICATION_RECV_EDITOR_DISCONNECTED object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_PHOTO_INSERT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_PHOTO_INSERT_ACK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_PHOTO_EDIT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_PHOTO_EDIT_CANCELED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_PHOTO_DELETE object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_DRAWING_INSERT object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_DRAWING_DELETE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_DISCONNECTED object:nil];
}

/**** CollectionViewController DataSource Methods ****/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.collectionView numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionView numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

/**** CollectionViewController Delegate Flowlayout Methods ****/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.collectionView insetForCollectionView];
}

/**** PhotoCropViewController Delegate Methods ****/
- (void)photoCropViewController:(PhotoCropViewController *)controller didFinishCropImageWithImage:(UIImage *)fullscreenImage croppedImage:(UIImage *)croppedImage {
    //임시로 전달받은 두개의 파일을 저장한다.
    NSString *filename = [[ImageUtility sharedInstance] saveImageAtTemporaryDirectoryWithFullscreenImage:fullscreenImage croppedImage:croppedImage];
    if (filename != nil) {
        NSURL *fullscreenImageURL = [[ImageUtility sharedInstance] getFullscreenImageURLWithFilename:filename];
        NSURL *croppedImageURL = [[ImageUtility sharedInstance] getCroppedImageURLWithFilename:filename];
        
        //저장된 파일의 경로를 이용하여 파일을 전송한다.
        [[ConnectionManager sharedInstance] sendPhotoDataWithFilename:filename fullscreenImageURL:fullscreenImageURL croppedImageURL:croppedImageURL index:self.collectionView.selectedPhotoFrameIndex.item];
        
        //CropViewController에서 Fullscreen Img, Cropped Img를 받은 후 저장한다.
        [self.collectionView setCellFullscreenImageOfSelectedIndex:fullscreenImage];
        [self.collectionView setCellCroppedImageOfSelectedIndex:croppedImage];
        [self.collectionView setCellStateOfSelectedIndex:CELL_STATE_UPLOADING];
        [self.collectionView reloadData];
    }
    else {
        NSLog(@"File saved failed.");
    }
}

- (void)photoCropViewControllerDidCancel:(PhotoCropViewController *)controller {
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                               KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.collectionView.selectedPhotoFrameIndex.item)};
    
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

/**** UIAlertViewDelegate Methods. ****/

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_NOT_SAVE) {
        if (buttonIndex == 1) {
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_DICONNECTED)};
            [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeObservers];
                
                //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
                [[MessageSyncManager sharedInstance] setMessageQueueEnabled:NO];
                [[MessageSyncManager sharedInstance] clearMessageQueue];
                
                [[ConnectionManager sharedInstance] disconnectSession];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                //사용된 임시 파일을 삭제한다
                [[ImageUtility sharedInstance] removeAllTempImages];
            });
        }
    }
    else if (alertView.tag == ALERT_CONTINUE) {
        [self removeObservers];
        
        //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
        [[MessageSyncManager sharedInstance] setMessageQueueEnabled:NO];
        [[MessageSyncManager sharedInstance] clearMessageQueue];
        
        [[ConnectionManager sharedInstance] disconnectSession];
        
        //계속하지 않겠다고 응답했으므로, 메인화면으로 돌아간다.
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //사용된 임시 파일을 삭제한다
            [[ImageUtility sharedInstance] removeAllTempImages];
        }
    }
}

/**** Session Communication Methods ****/
- (void)receivedPhotoInsert:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_INDEX];
        NSString *dataType =(NSString *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_DATA_TYPE];
        NSURL *dataUrl = (NSURL *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_DATA];
        
        //Data Receive Started.
        if (dataUrl == nil) {
            [self.collectionView setCellStateAtIndex:item.integerValue state:CELL_STATE_DOWNLOADING];
            [self.collectionView reloadData];
        }
        //Data Receive Finished.
        else {
            if ([dataType isEqualToString:@"_cropped"]) {
                UIImage *croppedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:dataUrl]];
                [self.collectionView setCellCroppedImageAtIndex:item.integerValue croppedImage:croppedImage];
                [self.collectionView reloadData];
            }
            else if ([dataType isEqualToString:@"_fullscreen"]) {
                UIImage *fullscreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:dataUrl]];
                [self.collectionView setCellStateAtIndex:item.integerValue state:CELL_STATE_NONE];
                [self.collectionView setCellFullscreenImageAtIndex:item.integerValue fullscreenImage:fullscreenImage];
                [self.collectionView reloadData];
            }
        }
    });
}

- (void)receivedPhotoInsertAck:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSNumber *receivedAck = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_ACK];
//        
//        if ([receivedAck boolValue]) {
//        }
//        else {
//        }
        NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_INDEX];
        [self.collectionView setCellStateAtIndex:item.integerValue state:CELL_STATE_NONE];
        [self.collectionView reloadData];
    });
}

- (void)receivedPhotoEdit:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_EDIT_INDEX];
        [self.collectionView setCellStateAtIndex:item.integerValue state:CELL_STATE_EDITING];
        [self.collectionView reloadData];
    });
}

- (void)receivedPhotoEditCanceled:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_EDIT_INDEX];
        [self.collectionView setCellStateAtIndex:item.integerValue state:CELL_STATE_NONE];
        [self.collectionView reloadData];
    });
}

- (void)receivedPhotoDelete:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_DELETE_INDEX];
        [self.collectionView clearCellDataAtIndex:item.integerValue];
        [self.collectionView reloadData];
    });
}

- (void)receivedSessionDisconnected:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnected", nil) message:NSLocalizedString(@"alert_content_photo_edit_continue", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
        alertView.tag = ALERT_CONTINUE;
        [alertView show];
    });
}

@end
