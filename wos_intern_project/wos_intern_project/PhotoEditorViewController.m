//
//  PhotoEditorViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorViewController.h"

#define MAIN_MENU_BACKGROUND_COLOR [UIColor colorWithRed:45 / 255.f green:140 / 255.f blue:213 / 255.f alpha:1]
#define DELAY_TIME                 1.0f

@interface PhotoEditorViewController ()

@property (nonatomic, strong) ConnectionManager *connectionManager;
@property (nonatomic, strong) MessageSyncManager *messageSyncManager;

@property (nonatomic, strong) PhotoFrameCellManager *cellManager;
@property (atomic, strong) DecorateObjectManager *decoObjectManager;

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
- (void)loadPhotoCropViewController;
- (void)reloadData:(NSIndexPath *)indexPath;

@end

@implementation PhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.decoObjectManager = [[DecorateObjectManager alloc] init];
    self.drawObjectDisplayView.delegate = self;
    self.drawPenView.delegate = self;
    
    /**** Set Main Menu ****/
    NSArray *menuItems = @[[UIImage imageNamed:@"MenuSticker"], [UIImage imageNamed:@"MenuText"], [UIImage imageNamed:@"MenuPen"]];
    
    [self.editMenuButton loadButtonWithIcons:menuItems startDegree:-M_PI layoutDegree:M_PI / 2];
    [self.editMenuButton setCenterIcon:[UIImage imageNamed:@"MenuMain"]];
    [self.editMenuButton setCenterIconType:XXXIconTypeCustomImage];
    [self.editMenuButton setDelegate:self];
    
    self.editMenuButton.mainColor = MAIN_MENU_BACKGROUND_COLOR;
    /**** End ****/
    
    self.isMenuAppear = NO;
    
    self.connectionManager = [ConnectionManager sharedInstance];
    self.connectionManager.delegate = self;
    self.messageSyncManager = [MessageSyncManager sharedInstance];
    [self addObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTapped:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnect_ask", nil) message:NSLocalizedString(@"alert_content_data_not_save", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
    alertView.tag = ALERT_NOT_SAVE;
    [alertView show];
}

- (IBAction)saveButtonTapped:(id)sender {
//    [self.connectionManager disconnectSession];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadPhotoCropViewController {
    [self performSegueWithIdentifier:SEGUE_MOVE_TO_CROPPER sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_MOVE_TO_CROPPER]) {
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
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_CELL object:nil];
}

- (void)setPhotoFrameNumber:(NSInteger)frameNumber {
    self.cellManager = [[PhotoFrameCellManager alloc] initWithFrameNumber:frameNumber];
}

- (void)reloadData:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    });
}


#pragma mark - CollectionViewController DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.cellManager getSectionNumber];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.cellManager getItemNumber];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoEditorFrameViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:REUSE_CELL_EDITOR forIndexPath:indexPath];
    [cell setIndexPath:indexPath];
    [cell setTapGestureRecognizer];
    [cell setStrokeBorder];
    [cell setImage:[self.cellManager getCellCroppedImageAtIndex:indexPath.item]];
    [cell setLoadingImage:[self.cellManager getCellStateAtIndex:indexPath.item]];
    
    return cell;
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellManager getCellSizeWithIndex:indexPath.item withCollectionViewSize:collectionView.frame.size];
}


#pragma mark - SphereMenu Delegate Method

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
            
            [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
        }
    }
    
    if (isSendEditCancelMsg) {
        NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                                   KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
        
        [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    }
    
    [sphereMenu dismissMenu];
    self.isMenuAppear = NO;
}


#pragma mark - XXXRoundMenuButton Delegate Method

- (void)xxxRoundMenuButtonDidSelected:(XXXRoundMenuButton *)menuButton WithSelectedIndex:(NSInteger)index {
    //Sticker Menu
    if (index == 0) {
    
    //Text Menu
    } else if (index == 1) {
        
    //Pen Menu
    } else if (index == 2) {
        [self.drawPenView setHidden:NO];
    //Photo Menu
    } else if (index == 3) {
        
    }
    
}


#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.selectedImageURL = (NSURL *)info[UIImagePickerControllerReferenceURL];
        
        if (self.selectedImageURL == nil) {
            //Error Alert.
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                                       KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
            
            [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
        } else {
            [self loadPhotoCropViewController];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                               KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}


#pragma mark - PhotoCropViewController Delegate Methods

- (void)cropViewControllerDidFinished:(PhotoCropViewController *)controller withFullscreenImage:(UIImage *)fullscreenImage withCroppedImage:(UIImage *)croppedImage {
    //임시로 전달받은 두개의 파일을 저장한다.
    NSString *filename = [ImageUtility saveImageAtTemporaryDirectoryWithFullscreenImage:fullscreenImage withCroppedImage:croppedImage];
    
    if (filename != nil) {
        NSURL *fullscreenImageURL = [ImageUtility generateFullscreenImageURLWithFilename:filename];
        NSURL *croppedImageURL = [ImageUtility generateCroppedImageURLWithFilename:filename];
        
        //CropViewController에서 Fullscreen Img, Cropped Img를 받은 후 저장한다.
        [self.cellManager setCellFullscreenImageAtIndex:self.selectedIndexPath.item withFullscreenImage:fullscreenImage];
        [self.cellManager setCellCroppedImageAtIndex:self.selectedIndexPath.item withCroppedImage:croppedImage];
        [self.cellManager setCellStateAtIndex:self.selectedIndexPath.item withState:CELL_STATE_UPLOADING];
        [self reloadData:self.selectedIndexPath];
        
        //저장된 파일의 경로를 이용하여 파일을 전송한다.
        [self.connectionManager sendPhotoDataWithFilename:filename WithFullscreenImageURL:fullscreenImageURL WithCroppedImageURL:croppedImageURL WithIndex:self.selectedIndexPath.item];
    } else {
        //alert.
    }
}

- (void)cropViewControllerDidCancelled:(PhotoCropViewController *)controller {
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                               KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedIndexPath.item)};
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}


#pragma mark - PhotoDrawObjectDisplayView Delegate Methods

- (void)decoViewDidMovedWithId:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY {
    [self.decoObjectManager updateDecorateObjectWithId:identifier WithOriginX:originX WithOriginY:originY];
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_MOVED),
                               KEY_EDITOR_DRAWING_UPDATE_ID: identifier,
                               KEY_EDITOR_DRAWING_UPDATE_MOVED_X: @(originX),
                               KEY_EDITOR_DRAWING_UPDATE_MOVED_Y: @(originY)};
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

- (void)decoViewDidResizedWithId:(NSString *)identifier WithResizedWidth:(CGFloat)width WithResizedHeight:(CGFloat)height {
    [self.decoObjectManager updateDecorateObjectWithId:identifier WithWidth:width WithHeight:height];
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_RESIZED),
                               KEY_EDITOR_DRAWING_UPDATE_ID: identifier,
                               KEY_EDITOR_DRAWING_UPDATE_RESIZED_WIDTH: @(width),
                               KEY_EDITOR_DRAWING_UPDATE_RESIZED_HEIGHT: @(height)};
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

- (void)decoViewDidRotatedWithId:(NSString *)identifier WithRotatedAngle:(CGFloat)angle {
    [self.decoObjectManager updateDecorateObjectWithId:identifier WithAngle:angle];
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_ROTATED),
                               KEY_EDITOR_DRAWING_UPDATE_ID: identifier,
                               KEY_EDITOR_DRAWING_UPDATE_ROTATED_ANGLE: @(angle)};
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

- (void)decoViewDidDeletedWithId:(NSString *)identifier {
    [self.decoObjectManager deleteDecorateObjectWithId:identifier];
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_DRAWING_DELETE),
                               KEY_EDITOR_DRAWING_DELETE_ID: identifier};
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

- (void)decoViewDidChangedZOrderWithId:(NSString *)identifier {
    
}


#pragma mark - PhotoDrawPenView Delegate Methods

- (void)drawPenViewDidFinished:(PhotoDrawPenView *)drawPenView WithImage:(UIImage *)image {
    [drawPenView setHidden:YES];
    
    WMPhotoDecorateImageObject *imageObject = [[WMPhotoDecorateImageObject alloc] initWithImage:image];
    [self.decoObjectManager addDecorateObject:imageObject];
    
    UIView *decoView = [imageObject getView];
    decoView.stringTag = [imageObject getID];
    [self.drawObjectDisplayView addDecoView:decoView];
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_DRAWING_INSERT),
                               KEY_EDITOR_DRAWING_INSERT_DATA:[imageObject getData],
                               KEY_EDITOR_DRAWING_INSERT_TIMESTAMP:[imageObject getZOrder]};
    
    [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

- (void)drawPenViewDidCancelled:(PhotoDrawPenView *)drawPenView {
    [drawPenView setHidden:YES];
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_NOT_SAVE) {
        if (buttonIndex == 1) {
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_DICONNECTED)};
            [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.connectionManager.delegate = nil;
                [self removeObservers];
                
                //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
                [self.messageSyncManager setMessageQueueEnabled:NO];
                [self.messageSyncManager clearMessageQueue];
                
                [self.connectionManager disconnectSession];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                //사용된 임시 파일을 삭제한다
                [ImageUtility removeAllTemporaryImages];
            });
        }
    } else if (alertView.tag == ALERT_CONTINUE) {
        self.connectionManager.delegate = nil;
        [self removeObservers];
        
        //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
        [self.messageSyncManager setMessageQueueEnabled:NO];
        [self.messageSyncManager clearMessageQueue];
        
        [self.connectionManager disconnectSession];
        
        //계속하지 않겠다고 응답했으므로, 메인화면으로 돌아간다.
        if (buttonIndex == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //사용된 임시 파일을 삭제한다
            [ImageUtility removeAllTemporaryImages];
        }
    } else if (alertView.tag == ALERT_ALBUM_AUTH) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}


#pragma mark - CollectionViewCell Selected Method

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
        
        [self.connectionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    }
}


#pragma mark - ConnectionManagerDelegate Methods

- (void)receivedEditorPhotoInsert:(NSInteger)targetFrameIndex WithType:(NSString *)type WithURL:(NSURL *)url {
    //Data Receive Started.
    if (url == nil) {
        [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CELL_STATE_DOWNLOADING];
        //Data Receive Finished.
    } else {
        if ([type isEqualToString:POSTFIX_IMAGE_CROPPED]) {
            UIImage *croppedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [self.cellManager setCellCroppedImageAtIndex:targetFrameIndex withCroppedImage:croppedImage];
        } else if ([type isEqualToString:POSTFIX_IMAGE_FULLSCREEN]) {
            UIImage *fullscreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CELL_STATE_NONE];
            [self.cellManager setCellFullscreenImageAtIndex:targetFrameIndex withFullscreenImage:fullscreenImage];
        }
    }
    
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorPhotoInsertAck:(NSInteger)targetFrameIndex WithAck:(BOOL)insertAck {
    if (insertAck) {
        [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CELL_STATE_NONE];
        [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
    } else {
        //error
    }
}

- (void)receivedEditorPhotoEditing:(NSInteger)targetFrameIndex {
    [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CELL_STATE_EDITING];
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorPhotoEditingCancelled:(NSInteger)targetFrameIndex {
    [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CELL_STATE_NONE];
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorPhotoDelete:(NSInteger)targetFrameIndex {
    [self.cellManager clearCellDataAtIndex:targetFrameIndex];
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorDecorateObjectInsert:(id)insertData WithTimestamp:(NSNumber *)timestamp {
    WMPhotoDecorateObject *decoObject;
    
    if ([insertData isKindOfClass:[UIImage class]]) {
        NSLog(@"I'm Image.");
        decoObject = [[WMPhotoDecorateImageObject alloc] initWithImage:insertData WithTimestamp:timestamp];
    } else if ([insertData isKindOfClass:[NSString class]]) {
        NSLog(@"I'm Text.");
        decoObject = [[WMPhotoDecorateTextObject alloc] initWithText:insertData WithTimestamp:timestamp];
    }
    
    [self.decoObjectManager addDecorateObject:decoObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *decoView = [decoObject getView];
        decoView.stringTag = [decoObject getID];
        [self.drawObjectDisplayView addDecoView:decoView];
    });
}

- (void)receivedEditorDecorateObjectMoved:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY {
    [self.decoObjectManager updateDecorateObjectWithId:identifier WithOriginX:originX WithOriginY:originY];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView updateDecoViewWithId:identifier WithOriginX:originX WithOriginY:originY];
    });
}

- (void)receivedEditorDecorateObjectResized:(NSString *)identifier WithWidth:(CGFloat)width WithHeight:(CGFloat)height {
    [self.decoObjectManager updateDecorateObjectWithId:identifier WithWidth:width WithHeight:height];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView updateDecoViewWithId:identifier WithWidth:width WithHeight:height];
    });
}

- (void)receivedEditorDecorateObjectRotated:(NSString *)identifier WithAngle:(CGFloat)angle {
    [self.decoObjectManager updateDecorateObjectWithId:identifier WithAngle:angle];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView updateDecoViewWithId:identifier WithAngle:angle];
    });
}

- (void)receivedEditorDecorateObjectZOrderChanged:(NSString *)identifier {
    [self.decoObjectManager updateDecorateObjectZOrderWithId:identifier];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView updateDecoViewZOrderWithId:identifier];
    });
}

- (void)receivedEditorDecorateObjectDelete:(NSString *)identifier {
    [self.decoObjectManager deleteDecorateObjectWithId:identifier];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView deleteDecoViewWithId:identifier];
    });
}

- (void)receivedEditorDisconnected {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnected", nil) message:NSLocalizedString(@"alert_content_photo_edit_continue", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
        alertView.tag = ALERT_CONTINUE;
        [alertView show];
    });
}

@end
