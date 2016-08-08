//
//  PhotoEditorViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorViewController.h"
#import "UIView+StringTag.h"

#import "CommonConstants.h"
#import "ConnectionManagerConstants.h"

#import "ConnectionManager.h"
#import "MessageSyncManager.h"
#import "ValidateCheckUtility.h"
#import "DecorateObjectController.h"

#import "SphereMenu.h"
#import "XXXRoundMenuButton.h"

#import "PhotoFrameCellManager.h"
#import "PhotoEditorFrameViewCell.h"
#import "PhotoCropViewController.h"
#import "PhotoDrawObjectDisplayView.h"
#import "PhotoDrawPenMenuView.h"

#import "WMPhotoDecorateImageObject.h"
#import "WMPhotoDecorateTextObject.h"

#import "AlertHelper.h"
#import "ImageUtility.h"

@interface PhotoEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SphereMenuDelegate, XXXRoundMenuButtonDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoCropViewControllerDelegate, PhotoDrawObjectDisplayViewDelegate, PhotoDrawPenMenuViewDelegate, ConnectionManagerSessionConnectDelegate, ConnectionManagerPhotoEditorDelegate>

@property (nonatomic, strong) PhotoFrameCellManager *cellManager;
@property (atomic, strong) DecorateObjectController *decoObjectController;

@property (atomic, assign) NSIndexPath *selectedIndexPath;
@property (atomic, strong) NSURL *selectedImageURL;
@property (nonatomic, assign) BOOL isMenuAppear;

@property (weak, nonatomic) IBOutlet UIView *collectionContainerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *decoObjectVisibleToggleButton;
@property (weak, nonatomic) IBOutlet XXXRoundMenuButton *editMenuButton;

//그려진 객체들이 위치하는 뷰
@property (weak, nonatomic) IBOutlet PhotoDrawObjectDisplayView *drawObjectDisplayView;
//그려질 객체들이 위치하는 뷰(실제로 그림을 그리는 뷰)
@property (weak, nonatomic) IBOutlet PhotoDrawPenMenuView *drawPenMenuView;

@end

@implementation PhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupConnectionManager];
    [self setupMenu];
    [self setupDrawController];
    
    self.isMenuAppear = NO;
    [self addObservers];
}

- (void)setupConnectionManager {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionConnectDelegate = self;
    connectionManager.photoEditorDelegate = self;
}

- (void)setupMenu {
    NSArray *menuItems = @[[UIImage imageNamed:@"MenuSticker"], [UIImage imageNamed:@"MenuText"], [UIImage imageNamed:@"MenuPen"]];
    
    [self.editMenuButton loadButtonWithIcons:menuItems
                                 startDegree:-M_PI
                                layoutDegree:M_PI / 2];
    
    [self.editMenuButton setMainColor:[UIColor colorWithRed:45 / 255.f
                                                      green:140 / 255.f
                                                       blue:213 / 255.f
                                                      alpha:1]];
    
    [self.editMenuButton setCenterIcon:[UIImage imageNamed:@"MenuMain"]];
    [self.editMenuButton setCenterIconType:XXXIconTypeCustomImage];
    [self.editMenuButton setDelegate:self];
}

- (void)setupDrawController {
    self.decoObjectController = [[DecorateObjectController alloc] init];
    self.drawObjectDisplayView.delegate = self;
    self.drawPenMenuView.delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.editMenuButton)
        return;
    
    if (!self.editMenuButton.isOpened)
        [self.editMenuButton dismissMenuButton];
}

- (void)setPhotoFrameNumber:(NSInteger)frameNumber {
    self.cellManager = [[PhotoFrameCellManager alloc] initWithFrameNumber:frameNumber];
}

- (void)reloadData:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueMoveToCropper]) {
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

- (void)dealloc {
    [ConnectionManager sharedInstance].photoEditorDelegate = nil;
    [ImageUtility removeAllTemporaryImages];
    [self removeObservers];
}


#pragma mark - DrawObjectView & DrawObjectDisplayView's Set Visibility Methods

- (void)setVisibleDrawObjectView:(BOOL)visible {
    //그리기 뷰를 표시해야하면, 그려진 객체들을 보여줘야 하므로 DisplayView를 표시 상태로 변경한다.
    //그려진 객체를 숨기거나 표시할 수 있는 토글 버튼과 편집 메뉴 버튼을 숨긴다.
    //그려진 객체가 화면에 표시되므로, 토글 버튼의 상태를 Selected 상태로 변경한다.
    //이후 그림을 그릴 수 있는 DrawingPenView를 표시 상태로 변경한다.
    if (visible) {
        [self.decoObjectVisibleToggleButton setHidden:YES];
        [self.editMenuButton setHidden:YES];
        [self.drawPenMenuView setHidden:NO];
    } else {
        [self.decoObjectVisibleToggleButton setHidden:NO];
        [self.editMenuButton setHidden:NO];
        [self.drawPenMenuView setHidden:YES];
    }
}

- (void)setVisibleDrawObjectDisplayView:(BOOL)visible {
    //visible이 yes이면 DrawObject가 화면에 표시되는 상태를 의미한다.
    if (visible) {
        [self.drawObjectDisplayView setHidden:NO];
        [self.decoObjectVisibleToggleButton setSelected:YES];
    } else {
        [self.drawObjectDisplayView setHidden:YES];
        [self.decoObjectVisibleToggleButton setSelected:NO];
    }
}


#pragma mark - Load Other ViewController Methods

- (void)loadPhotoCropViewController {
    [self performSegueWithIdentifier:SegueMoveToCropper sender:self];
}

- (void)loadMainViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Observer Add & Remove Methods

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCellAction:) name:NOTIFICATION_SELECTED_CELL object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_CELL object:nil];
}


#pragma mark - EventHandle Methods

- (IBAction)backButtonTapped:(id)sender {
    UIAlertController *disconnectAlert = [AlertHelper createAlertControllerWithTitleKey:@"alert_title_session_disconnect_ask"
                                                                             messageKey:@"alert_content_data_not_save"];
    
    [AlertHelper addButtonOnAlertController:disconnectAlert titleKey:@"alert_button_text_no" handler:^(UIAlertAction * _Nonnull action) {
        [AlertHelper dismissAlertController:disconnectAlert];
    }];
    
    __weak typeof(self) weakSelf = self;
    [AlertHelper addButtonOnAlertController:disconnectAlert titleKey:@"alert_button_text_yes" handler:^(UIAlertAction * _Nonnull action) {
        //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
        ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
        connectionManager.sessionConnectDelegate = nil;
        connectionManager.photoEditorDelegate = nil;
        [connectionManager disconnectSession];
        
        [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:NO];
        
        [weakSelf loadMainViewController];
    }];
    
    [AlertHelper showAlertControllerOnViewController:self alertController:disconnectAlert];
}

- (IBAction)saveButtonTapped:(id)sender {
    //    [self.connectionManager disconnectSession];
    //    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)decoreateVisibleToggled:(id)sender {
    UIButton *view = sender;
    view.selected = !view.selected;
    
    [self setVisibleDrawObjectDisplayView:view.selected];
}


#pragma mark - CollectionViewController DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.cellManager getSectionNumber];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.cellManager getItemNumber];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoEditorFrameViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseCellEditor forIndexPath:indexPath];
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

typedef NS_ENUM(NSInteger, PhotoMenu) {
    PhotoMenuTakePhotoAtAlbum  = 0,
    PhotoMenuTakePhotoAtCamera = 1,
    PhotoMenuEditPhoto         = 2,
    PhotoMenuDeletePhoto       = 3
};

- (void)sphereDidSelected:(SphereMenu *)sphereMenu index:(int)index {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    BOOL isSendEditCancelMsg = NO;
    
    if (index < 0) {
        isSendEditCancelMsg = YES;
    } else {
        switch (index) {
            case PhotoMenuTakePhotoAtAlbum:
                if ([ValidateCheckUtility checkPhotoAlbumAccessAuthority]) {
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    picker.delegate = self;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:picker animated:YES completion:nil];
                    });
                } else {
                    //권한 없음. 해당 Alert 표시.
                    UIAlertController *albumAuthAlert = [AlertHelper createAlertControllerWithTitleKey:@"alert_title_album_not_authorized"
                                                                                            messageKey:@"alert_content_album_not_authorized"];
                    
                    [AlertHelper addButtonOnAlertController:albumAuthAlert titleKey:@"alert_button_text_no" handler:^(UIAlertAction * _Nonnull action) {
                        [AlertHelper dismissAlertController:albumAuthAlert];
                    }];
                    
                    [AlertHelper addButtonOnAlertController:albumAuthAlert titleKey:@"alert_button_text_yes" handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        [AlertHelper dismissAlertController:albumAuthAlert];
                    }];
                    
                    [AlertHelper showAlertControllerOnViewController:self alertController:albumAuthAlert];
                    
                    isSendEditCancelMsg = YES;
                }
                break;
            case PhotoMenuTakePhotoAtCamera:
                //camera
                //아래의 코드는 버그 방지를 위해, 임시로 추가시킨 코드이다. 기능이 구현되면 삭제될 예정이다.
                isSendEditCancelMsg = YES;
                break;
            case PhotoMenuEditPhoto:
                //edit
                self.selectedImageURL = nil;
                [self loadPhotoCropViewController];
                break;
            case PhotoMenuDeletePhoto:
                [self.cellManager clearCellDataAtIndex:self.selectedIndexPath.item];
                [self reloadData:self.selectedIndexPath];
                
                NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoDelete),
                                           kEditorPhotoDeleteIndex: @(self.selectedIndexPath.item)};
                
                [connectionManager sendData:sendData];
                break;
        }
    }
    
    if (isSendEditCancelMsg) {
        NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoEditCancel),
                                   kEditorPhotoEditIndex: @(self.selectedIndexPath.item)};
        
        [connectionManager sendData:sendData];
    }
    
    [sphereMenu dismissMenu];
    self.isMenuAppear = NO;
}


#pragma mark - XXXRoundMenuButton Delegate Method

typedef NS_ENUM(NSInteger, MainMenu) {
    MainMenuSticker     = 0,
    MainMenuText        = 1,
    MainMenuPen         = 2
};

- (void)xxxRoundMenuButtonDidOpened {
    [self.drawObjectDisplayView deselectDrawObject];
}

float const WaitUntilAnimationFinish = 0.24 + 0.06;

- (void)xxxRoundMenuButtonDidSelected:(XXXRoundMenuButton *)menuButton WithSelectedIndex:(NSInteger)index {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WaitUntilAnimationFinish * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        switch (index) {
            case MainMenuPen:
                [self setVisibleDrawObjectView:YES];
                [self setVisibleDrawObjectDisplayView:YES];
                break;
            case MainMenuText:
                
                break;
            case MainMenuSticker:
                
                break;
        }
    });
}


#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.selectedImageURL = (NSURL *)info[UIImagePickerControllerReferenceURL];
        
        if (self.selectedImageURL == nil) {
            //Error Alert.
            NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoEditCancel),
                                       kEditorPhotoEditIndex: @(self.selectedIndexPath.item)};
            
            [[ConnectionManager sharedInstance] sendData:sendData];
        } else {
            [self loadPhotoCropViewController];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoEditCancel),
                               kEditorPhotoEditIndex: @(self.selectedIndexPath.item)};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}


#pragma mark - PhotoCropViewController Delegate Methods

- (void)cropViewControllerDidFinished:(PhotoCropViewController *)controller withFullscreenImage:(UIImage *)fullscreenImage withCroppedImage:(UIImage *)croppedImage {
    if (!fullscreenImage || !croppedImage) {
        //Alert. 사진 가져오지 못함.
        return;
    }
    
    //임시로 전달받은 두개의 파일을 저장한다.
    NSString *filename = [ImageUtility saveImageAtTemporaryDirectoryWithFullscreenImage:fullscreenImage withCroppedImage:croppedImage];
    
    if (!filename) {
        //Alert. 사진 저장 실패.
        return;
    }
    
    NSURL *fullscreenImageURL = [ImageUtility generateFullscreenImageURLWithFilename:filename];
    NSURL *croppedImageURL = [ImageUtility generateCroppedImageURLWithFilename:filename];
    
    //CropViewController에서 Fullscreen Img, Cropped Img를 받은 후 저장한다.
    [self.cellManager setCellFullscreenImageAtIndex:self.selectedIndexPath.item withFullscreenImage:fullscreenImage];
    [self.cellManager setCellCroppedImageAtIndex:self.selectedIndexPath.item withCroppedImage:croppedImage];
    [self.cellManager setCellStateAtIndex:self.selectedIndexPath.item withState:CellStateUploading];
    [self reloadData:self.selectedIndexPath];
    
    //저장된 파일의 경로를 이용하여 파일을 전송한다.
    [[ConnectionManager sharedInstance] sendPhotoDataWithFilename:filename
                                               fullscreenImageURL:fullscreenImageURL
                                                  croppedImageURL:croppedImageURL
                                                            index:self.selectedIndexPath.item];
}

- (void)cropViewControllerDidCancelled:(PhotoCropViewController *)controller {
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoEditCancel),
                               kEditorPhotoEditIndex: @(self.selectedIndexPath.item)};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}


#pragma mark - PhotoDrawObjectDisplayView Delegate Methods

- (void)decoViewDidSelected:(NSString *)identifier {
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorDrawingEdit),
                               kEditorDrawingEditID: identifier};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}

- (void)decoViewDidDeselected:(NSString *)identifier {
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorDrawingEditCancel),
                               kEditorDrawingEditID: identifier};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}

- (void)decoViewDidMovedWithId:(NSString *)identifier originX:(CGFloat)originX originY:(CGFloat)originY {
    [self.decoObjectController updateDecorateObjectWithId:identifier originX:originX originY:originY];
    
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorDrawingUpdateMoved),
                               kEditorDrawingUpdateID: identifier,
                               kEditorDrawingUpdateMovedX: @(originX),
                               kEditorDrawingUpdateMovedY: @(originY)};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}

- (void)decoViewDidResizedWithId:(NSString *)identifier originX:(CGFloat)originX originY:(CGFloat)originY resizedWidth:(CGFloat)width resizedHeight:(CGFloat)height {
    [self.decoObjectController updateDecorateObjectWithId:identifier originX:originX originY:originY width:width height:height];
    
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorDrawingUpdateResized),
                               kEditorDrawingUpdateID: identifier,
                               kEditorDrawingUpdateResizedX: @(originX),
                               kEditorDrawingUpdateResizedY: @(originY),
                               kEditorDrawingUpdateResizedWidth: @(width),
                               kEditorDrawingUpdateResizedHeight: @(height)};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}

- (void)decoViewDidRotatedWithId:(NSString *)identifier rotatedAngle:(CGFloat)angle {
    [self.decoObjectController updateDecorateObjectWithId:identifier angle:angle];
    
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorDrawingUpdateRotated),
                               kEditorDrawingUpdateID: identifier,
                               kEditorDrawingUpdateRotatedAngle: @(angle)};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}

- (void)decoViewDidDeletedWithId:(NSString *)identifier {
    [self.decoObjectController deleteDecorateObjectWithId:identifier];
    
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorDrawingDelete),
                               kEditorDrawingDeleteID: identifier};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}

- (void)decoViewDidChangedZOrderWithId:(NSString *)identifier {
    
}


#pragma mark - PhotoDrawPenMenuView Delegate Methods

- (void)drawPenMenuViewDidFinished:(PhotoDrawPenMenuView *)drawPenMenuView WithImage:(UIImage *)image {
    [self setVisibleDrawObjectView:NO];
    
    if (!image)
        return;
    
    WMPhotoDecorateImageObject *imageObject = [[WMPhotoDecorateImageObject alloc] initWithImage:image];
    [self.decoObjectController addDecorateObject:imageObject];
    
    UIView *decoView = [imageObject getView];
    decoView.stringTag = [imageObject getID];
    [self.drawObjectDisplayView addDecoView:decoView];
    
    NSDictionary *sendData = @{kDataType: @(vDataTypeEditorDrawingInsert),
                               kEditorDrawingInsertData:[imageObject getData],
                               kEditorDrawingInsertTimestamp:[imageObject getZOrder]};
    
    [[ConnectionManager sharedInstance] sendData:sendData];
}

- (void)drawPenMenuViewDidCancelled:(PhotoDrawPenMenuView *)drawPenMenuView {
    [self setVisibleDrawObjectView:NO];
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

        SphereMenu *sphereMenu = [[SphereMenu alloc] initWithRootView:self.collectionContainerView Center:sphereMenuCenter CloseImage:[UIImage imageNamed:@"CircleClose"] MenuImages:images];
        sphereMenu.delegate = self;
        [sphereMenu presentMenu];
        
        NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoEdit),
                                   kEditorPhotoEditIndex: @(self.selectedIndexPath.item)};
        
        [[ConnectionManager sharedInstance] sendData:sendData];
    }
}


#pragma mark - ConnectionManager Session Connect Delegate Methods

- (void)receivedPeerConnected {
    
}

- (void)receivedPeerDisconnected {
    UIAlertController *diconnectedAlert = [AlertHelper createAlertControllerWithTitleKey:@"alert_title_session_disconnected"
                                                                              messageKey:@"alert_content_photo_edit_continue"];
    
    [AlertHelper addButtonOnAlertController:diconnectedAlert titleKey:@"alert_button_text_no" handler:^(UIAlertAction * _Nonnull action) {
        //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
        ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
        connectionManager.sessionConnectDelegate = nil;
        connectionManager.photoEditorDelegate = nil;
        [connectionManager disconnectSession];
        
        [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:NO];

        
        [AlertHelper dismissAlertController:diconnectedAlert];
    }];
    
    [AlertHelper addButtonOnAlertController:diconnectedAlert titleKey:@"alert_button_text_yes" handler:^(UIAlertAction * _Nonnull action) {
        //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
        ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
        connectionManager.sessionConnectDelegate = nil;
        connectionManager.photoEditorDelegate = nil;
        [connectionManager disconnectSession];
        
        [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:NO];
        
        [self loadMainViewController];
    }];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [AlertHelper showAlertControllerOnViewController:weakSelf alertController:diconnectedAlert];
    });
}


#pragma mark - ConnectionManager Photo Editor Delegate Methods

- (void)receivedEditorPhotoInsert:(NSInteger)targetFrameIndex type:(NSString *)type url:(NSURL *)url {
    //Data Receive Started.
    if (url == nil) {
        [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CellStateDownloading];
        //Data Receive Finished.
    } else {
        if ([type isEqualToString:PostfixImageCropped]) {
            UIImage *croppedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [self.cellManager setCellCroppedImageAtIndex:targetFrameIndex withCroppedImage:croppedImage];
        } else if ([type isEqualToString:PostfixImageFullscreen]) {
            UIImage *fullscreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CellStateNone];
            [self.cellManager setCellFullscreenImageAtIndex:targetFrameIndex withFullscreenImage:fullscreenImage];
        }
    }
    
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorPhotoInsertAck:(NSInteger)targetFrameIndex ack:(BOOL)insertAck {
    if (insertAck) {
        [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CellStateNone];
        [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
    } else {
        //error
    }
}

- (void)receivedEditorPhotoEditing:(NSInteger)targetFrameIndex {
    [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CellStateEditing];
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorPhotoEditingCancelled:(NSInteger)targetFrameIndex {
    [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CellStateNone];
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorPhotoDelete:(NSInteger)targetFrameIndex {
    [self.cellManager clearCellDataAtIndex:targetFrameIndex];
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorDecorateObjectEditing:(NSString *)identifier {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView setEnableWithId:identifier enable:NO];
    });
}

- (void)receivedEditorDecorateObjectEditCancelled:(NSString *)identifier {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView setEnableWithId:identifier enable:YES];
    });
}

- (void)receivedEditorDecorateObjectInsert:(id)insertData timestamp:(NSNumber *)timestamp {
    WMPhotoDecorateObject *decoObject;
    
    if ([insertData isKindOfClass:[UIImage class]]) {
        NSLog(@"I'm Image.");
        decoObject = [[WMPhotoDecorateImageObject alloc] initWithImage:insertData timestamp:timestamp];
    } else if ([insertData isKindOfClass:[NSString class]]) {
        NSLog(@"I'm Text.");
        decoObject = [[WMPhotoDecorateTextObject alloc] initWithText:insertData timestamp:timestamp];
    }
    
    [self.decoObjectController addDecorateObject:decoObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *decoView = [decoObject getView];
        decoView.stringTag = [decoObject getID];
        [self.drawObjectDisplayView addDecoView:decoView];
    });
}

- (void)receivedEditorDecorateObjectMoved:(NSString *)identifier originX:(CGFloat)originX originY:(CGFloat)originY {
    [self.decoObjectController updateDecorateObjectWithId:identifier originX:originX originY:originY];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView updateDecoViewWithId:identifier originX:originX originY:originY];
    });
}

- (void)receivedEditorDecorateObjectResized:(NSString *)identifier originX:(CGFloat)originX originY:(CGFloat)originY width:(CGFloat)width height:(CGFloat)height {
    [self.decoObjectController updateDecorateObjectWithId:identifier originX:originX originY:originY width:width height:height];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView updateDecoViewWithId:identifier originX:originX originY:originY width:width height:height];
    });
}

- (void)receivedEditorDecorateObjectRotated:(NSString *)identifier angle:(CGFloat)angle {
    [self.decoObjectController updateDecorateObjectWithId:identifier angle:angle];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView updateDecoViewWithId:identifier angle:angle];
    });
}

- (void)receivedEditorDecorateObjectZOrderChanged:(NSString *)identifier {
    [self.decoObjectController updateDecorateObjectZOrderWithId:identifier];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView updateDecoViewZOrderWithId:identifier];
    });
}

- (void)receivedEditorDecorateObjectDelete:(NSString *)identifier {
    [self.decoObjectController deleteDecorateObjectWithId:identifier];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawObjectDisplayView deleteDecoViewWithId:identifier];
    });
}

@end
