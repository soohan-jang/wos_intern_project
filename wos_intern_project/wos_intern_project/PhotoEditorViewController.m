//
//  PhotoEditorViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorViewController.h"

@interface PhotoEditorViewController ()

@property (nonatomic, strong) PhotoFrameCellManager *cellManager;
@property (atomic, assign) NSIndexPath *selectedIndexPath;
@property (atomic, strong) NSURL *selectedImageURL;
@property (nonatomic, assign) BOOL isMenuAppear;

/**
 NotificationCenter가 알리는 Notification을 처리하기 위한 Observer들을 등록한다.
 */
- (void)addObservers;

/**
 NotificationCenter가 알리는 Notification을 처리하기 위한 Observer들을 등록 해제한다.
 */
- (void)removeObservers;

- (void)reloadData:(NSIndexPath *)indexPath;

/**
 상대방이 사진을 전송할 때 호출되는 함수이다. 상대방이 사진을 보낼 때, 시작되는 시점과 종료되는 시점을 구분하여 로직이 처리된다.
 */
- (void)receivedPhotoInsert:(NSNotification *)notification;

/**
 상대방이 사진 수신을 종료했음을 알릴 때 호출되는 함수이다.
 */
- (void)receivedPhotoInsertAck:(NSNotification *)notification;

- (void)receivedPhotoEdit:(NSNotification *)notification;
- (void)receivedPhotoEditCanceled:(NSNotification *)notification;

/**
 상대방이 사진을 삭제했을 때 호출되는 함수이다.
 */
- (void)receivedPhotoDelete:(NSNotification *)notification;
- (void)receivedSessionDisconnected:(NSNotification *)notification;

@end

@implementation PhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSArray *menuItems = @[[UIImage imageNamed:@"MenuSticker"], [UIImage imageNamed:@"MenuText"], [UIImage imageNamed:@"MenuPen"]];
    [self.editMenuButton loadButtonWithIcons:menuItems startDegree:-M_PI layoutDegree:M_PI/2];
    [self.editMenuButton setCenterIcon:[UIImage imageNamed:@"MenuMain"]];
    [self.editMenuButton setCenterIconType:XXXIconTypeCustomImage];
    [self.editMenuButton setButtonClickBlock:^(NSInteger idx) {
        
    }];
    
    self.editMenuButton.mainColor = [UIColor colorWithRed:45 / 255.f green:140 / 255.f blue:213 / 255.f alpha:1];
    
    self.isMenuAppear = NO;
    [self addObservers];
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

- (void)loadPhotoCropViewController {
    [self performSegueWithIdentifier:@"moveToPhotoCrop" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"moveToPhotoCrop"]) {
        PhotoCropViewController *viewController = [segue destinationViewController];
        viewController.delegate = self;
        viewController.cellSize = [self.collectionView cellForItemAtIndexPath:self.selectedIndexPath].frame.size;
        //picker에서 imageURL을 가져오지 못한 경우엔, 이 구문이 실행되지 않는다.
        //이 구문이 실행되는 경우는, picker를 거치지 않고 직접적으로 CropViewController를 호출한 경우이다.
        //즉, 이미 존재하는 데이터에 대해서 편집을 하고자 할 경우에 해당한다.
        if (self.selectedImageURL == nil) {
            viewController.fullscreenImage = [self.cellManager getCellFullscreenImageAtIndex:self.selectedIndexPath.item];
        } else {
            viewController.imageUrl = self.selectedImageURL;
        }
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCellAction:) name:NOTIFICATION_SELECTED_CELL object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_CELL object:nil];
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

- (void)setPhotoFrameNumber:(NSInteger)frameNumber {
    self.cellManager = [[PhotoFrameCellManager alloc] initWithFrameNumber:frameNumber];
}

- (void)reloadData:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    });
}

/**** CollectionViewController DataSource Methods ****/
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.cellManager getSectionNumber];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.cellManager getItemNumber];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoEditorFrameViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoFrameCell" forIndexPath:indexPath];
    [cell setIndexPath:indexPath];
    [cell setTapGestureRecognizer];
    [cell setStrokeBorder];
    [cell setImage:[self.cellManager getCellCroppedImageAtIndex:indexPath.item]];
    [cell setLoadingImage:[self.cellManager getCellStateAtIndex:indexPath.item]];
    
    return cell;
}

/**** CollectionViewController Delegate Flowlayout Methods ****/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellManager getCellSizeWithIndex:indexPath.item withCollectionViewSize:collectionView.frame.size];
}

/**** SphereMenu Delegate Method ****/
- (void)sphereDidSelected:(SphereMenu *)sphereMenu index:(int)index {
    BOOL isSendEditCancelMsg = NO;
    
    if (index < 0) {
        isSendEditCancelMsg = YES;
    } else {
        if (index == 0) {
            ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
            
            if (status == ALAuthorizationStatusNotDetermined || status == ALAuthorizationStatusAuthorized) {
                //아직 권한이 설정되지 않은 경우엔, System에서 Alert 띄워준다.
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.delegate = self;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self presentViewController:picker animated:YES completion:nil];
                });
            } else {
                //권한 없음. 해당 Alert 표시.
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_album_not_authorized", nil) message:NSLocalizedString(@"alert_content_album_not_authorized", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
                alertView.tag = ALERT_ALBUM_AUTH;
                [alertView show];
                
                isSendEditCancelMsg = YES;
            }
        } else if (index == 1) {
            //camera
            //아래의 코드는 버그 방지를 위해, 임시로 추가시킨 코드이다. 기능이 구현되면 삭제될 예정이다.
            isSendEditCancelMsg = YES;
        } else if (index == 2) {
            //edit
            self.selectedImageURL = nil;
            [self loadPhotoCropViewController];
        } else if (index == 3) {
            [self.cellManager clearCellDataAtIndex:self.selectedIndexPath.item];
            [self reloadData:self.selectedIndexPath];
            
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE),
                                       KEY_EDITOR_PHOTO_DELETE_INDEX: @(self.selectedIndexPath.item)};
            
            [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
        }
    }
    
    if (isSendEditCancelMsg) {
        NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                                   KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
        
        [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    }
    
    [sphereMenu dismissMenu];
    self.isMenuAppear = NO;
}

/**** UIImagePickerController Delegate Methods ****/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.selectedImageURL = (NSURL *)info[UIImagePickerControllerReferenceURL];
        
        if (self.selectedImageURL == nil) {
            //Error Alert.
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                                       KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
            
            [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
        } else {
            [self loadPhotoCropViewController];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                               KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
    
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

/**** PhotoCropViewController Delegate Methods ****/
- (void)photoCropViewController:(PhotoCropViewController *)controller didFinishCropImageWithImage:(UIImage *)fullscreenImage croppedImage:(UIImage *)croppedImage {
    //임시로 전달받은 두개의 파일을 저장한다.
    NSString *filename = [[ImageUtility sharedInstance] saveImageAtTemporaryDirectoryWithFullscreenImage:fullscreenImage withCroppedImage:croppedImage];
    if (filename != nil) {
        NSURL *fullscreenImageURL = [[ImageUtility sharedInstance] getFullscreenImageURLWithFilename:filename];
        NSURL *croppedImageURL = [[ImageUtility sharedInstance] getCroppedImageURLWithFilename:filename];
        
        //CropViewController에서 Fullscreen Img, Cropped Img를 받은 후 저장한다.
        [self.cellManager setCellFullscreenImageAtIndex:self.selectedIndexPath.item withFullscreenImage:fullscreenImage];
        [self.cellManager setCellCroppedImageAtIndex:self.selectedIndexPath.item withCroppedImage:croppedImage];
        [self.cellManager setCellStateAtIndex:self.selectedIndexPath.item withState:CELL_STATE_UPLOADING];
        [self reloadData:self.selectedIndexPath];
        
        //저장된 파일의 경로를 이용하여 파일을 전송한다.
        [[ConnectionManager sharedInstance] sendPhotoDataWithFilename:filename withFullscreenImageURL:fullscreenImageURL withCroppedImageURL:croppedImageURL withIndex:self.selectedIndexPath.item];
    } else {
        //alert.
    }
}

- (void)photoCropViewControllerDidCancel:(PhotoCropViewController *)controller {
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                               KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
    
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
    } else if (alertView.tag == ALERT_CONTINUE) {
        [self removeObservers];
        
        //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
        [[MessageSyncManager sharedInstance] setMessageQueueEnabled:NO];
        [[MessageSyncManager sharedInstance] clearMessageQueue];
        
        [[ConnectionManager sharedInstance] disconnectSession];
        
        //계속하지 않겠다고 응답했으므로, 메인화면으로 돌아간다.
        if (buttonIndex == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POP_ROOT_VIEW_CONTROLLER object:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //사용된 임시 파일을 삭제한다
            [[ImageUtility sharedInstance] removeAllTempImages];
        }
    } else if (alertView.tag == ALERT_ALBUM_AUTH) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

/*** CollectionViewCell Selected Method ****/

- (void)selectedCellAction:(NSNotification *)notification {
    if (!self.isMenuAppear) {
        self.isMenuAppear = YES;
        
        NSArray *images;
        
        self.selectedIndexPath = (NSIndexPath *)notification.userInfo[KEY_SELECTED_CELL_INDEXPATH];
        if ([self.cellManager getCellCroppedImageAtIndex:self.selectedIndexPath.item] == nil) {
            images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"]];
        } else {
            images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"], [UIImage imageNamed:@"CircleFilter"], [UIImage imageNamed:@"CircleDelete"]];
        }
        
        CGPoint sphereMenuCenter = CGPointMake([notification.userInfo[KEY_SELECTED_CELL_CENTER_X] floatValue], [notification.userInfo[KEY_SELECTED_CELL_CENTER_Y] floatValue]);
        CGFloat angleOffset;
        
        //사진 액자가 화면의 중간 범위에 위치할 때,
        if (self.view.center.x - 10 <= sphereMenuCenter.x && sphereMenuCenter.x <= self.view.center.x + 10) {
            if (images.count == 2) {
                angleOffset = M_PI * 1.1f;
            } else {
                angleOffset = M_PI * -1.13f;
            }
        } else {
            //사진 액자가 화면의 왼쪽에 위치할 때,
            if (sphereMenuCenter.x < self.view.center.x) {
                if (images.count == 2) {
                    angleOffset = M_PI * 1.2f;
                } else {
                    angleOffset = M_PI * 1.15f;
                }
                //사진 액자가 화면의 오른쪽에 위치할 때,
            } else if (sphereMenuCenter.x > self.view.center.x) {
                if (images.count == 2) {
                    angleOffset = M_PI * 1.05f;
                } else {
                    angleOffset = M_PI * -1.4f;
                }
            }
        }
        
        SphereMenu *sphereMenu = [[SphereMenu alloc] initWithRootView:self.collectionContainerView Center:sphereMenuCenter CloseImage:[UIImage imageNamed:@"CircleClose"] MenuImages:images StartAngle:angleOffset];
        sphereMenu.delegate = self;
        [sphereMenu presentMenu];
        
        NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT),
                                   KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
        
        [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    }
}

/**** Session Communication Methods ****/
- (void)receivedPhotoInsert:(NSNotification *)notification {
    NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_INDEX];
    NSString *dataType = (NSString *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_DATA_TYPE];
    NSURL *dataUrl = (NSURL *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_DATA];
    
    //Data Receive Started.
    if (dataUrl == nil) {
        [self.cellManager setCellStateAtIndex:item.integerValue withState:CELL_STATE_DOWNLOADING];
    //Data Receive Finished.
    } else {
        if ([dataType isEqualToString:@"_cropped"]) {
            UIImage *croppedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:dataUrl]];
            [self.cellManager setCellCroppedImageAtIndex:item.integerValue withCroppedImage:croppedImage];
        } else if ([dataType isEqualToString:@"_fullscreen"]) {
            UIImage *fullscreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:dataUrl]];
            [self.cellManager setCellStateAtIndex:item.integerValue withState:CELL_STATE_NONE];
            [self.cellManager setCellFullscreenImageAtIndex:item.integerValue withFullscreenImage:fullscreenImage];
        }
    }
    
    [self reloadData:[NSIndexPath indexPathForItem:item.integerValue inSection:0]];
}

- (void)receivedPhotoInsertAck:(NSNotification *)notification {
    NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_INDEX];
//    NSNumber *receivedAck = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_INSERT_ACK];
//    if ([receivedAck boolValue]) {
//    }
//    else {
//    }
    
    [self.cellManager setCellStateAtIndex:item.integerValue withState:CELL_STATE_NONE];
    [self reloadData:[NSIndexPath indexPathForItem:item.integerValue inSection:0]];
}

- (void)receivedPhotoEdit:(NSNotification *)notification {
    NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_EDIT_INDEX];
    [self.cellManager setCellStateAtIndex:item.integerValue withState:CELL_STATE_EDITING];
    [self reloadData:[NSIndexPath indexPathForItem:item.integerValue inSection:0]];
}

- (void)receivedPhotoEditCanceled:(NSNotification *)notification {
    NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_EDIT_INDEX];
    [self.cellManager setCellStateAtIndex:item.integerValue withState:CELL_STATE_NONE];
    [self reloadData:[NSIndexPath indexPathForItem:item.integerValue inSection:0]];
}

- (void)receivedPhotoDelete:(NSNotification *)notification {
    NSNumber *item = (NSNumber *)notification.userInfo[KEY_EDITOR_PHOTO_DELETE_INDEX];
    [self.cellManager clearCellDataAtIndex:item.integerValue];
    [self reloadData:[NSIndexPath indexPathForItem:item.integerValue inSection:0]];
}

- (void)receivedSessionDisconnected:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnected", nil) message:NSLocalizedString(@"alert_content_photo_edit_continue", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
        alertView.tag = ALERT_CONTINUE;
        [alertView show];
    });
}

@end
