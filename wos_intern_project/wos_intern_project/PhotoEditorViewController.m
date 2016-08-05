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

#import "ConnectionManager.h"
#import "MessageSyncManager.h"
#import "DecorateObjectController.h"

#import "SphereMenu.h"
#import "XXXRoundMenuButton.h"

#import "PhotoFrameCellManager.h"
#import "PhotoEditorFrameViewCell.h"
#import "PhotoCropViewController.h"
#import "PhotoDrawObjectDisplayView.h"
#import "PhotoDrawPenView.h"

#import "WMPhotoDecorateImageObject.h"
#import "WMPhotoDecorateTextObject.h"

typedef NS_ENUM(NSInteger, AlertType) {
    ALERT_NOT_SAVE   = 0,
    ALERT_CONTINUE   = 1,
    ALERT_ALBUM_AUTH = 2
};

@interface PhotoEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SphereMenuDelegate, XXXRoundMenuButtonDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoCropViewControllerDelegate, PhotoDrawObjectDisplayViewDelegate, PhotoDrawPenViewDelegate, UIAlertViewDelegate, ConnectionManagerPhotoEditorDelegate>

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
@property (weak, nonatomic) IBOutlet PhotoDrawPenView *drawPenView;

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
    connectionManager.photoEditorDelegate = self;
}

- (void)setupMenu {
    NSArray *menuItems = @[[UIImage imageNamed:@"MenuSticker"], [UIImage imageNamed:@"MenuText"], [UIImage imageNamed:@"MenuPen"]];
    
    [self.editMenuButton loadButtonWithIcons:menuItems
                                 startDegree:-M_PI
                                layoutDegree:M_PI / 2];
    
    [self.editMenuButton setCenterIcon:[UIImage imageNamed:@"MenuMain"]];
    [self.editMenuButton setCenterIconType:XXXIconTypeCustomImage];
    [self.editMenuButton setDelegate:self];
    
    self.editMenuButton.mainColor = [UIColor colorWithRed:45 / 255.f
                                                    green:140 / 255.f
                                                     blue:213 / 255.f
                                                    alpha:1];
}

- (void)setupDrawController {
    self.decoObjectController = [[DecorateObjectController alloc] init];
    self.drawObjectDisplayView.delegate = self;
    self.drawPenView.delegate = self;
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
        [self.drawPenView setHidden:NO];
    } else {
        [self.decoObjectVisibleToggleButton setHidden:NO];
        [self.editMenuButton setHidden:NO];
        [self.drawPenView setHidden:YES];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnect_ask", nil)
                                                        message:NSLocalizedString(@"alert_content_data_not_save", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil)
                                              otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
    alertView.tag = ALERT_NOT_SAVE;
    [alertView show];
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

- (void)sphereDidSelected:(SphereMenu *)sphereMenu index:(int)index {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_album_not_authorized", nil)
                                                                    message:NSLocalizedString(@"alert_content_album_not_authorized", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil)
                                                          otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
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
            
            NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoDelete),
                                       kEditorPhotoDeleteIndex: @(self.selectedIndexPath.item)};
            
            [connectionManager sendData:sendData];
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

- (void)xxxRoundMenuButtonDidOpened {
    [self.drawObjectDisplayView deselectDrawObject];
}

- (void)xxxRoundMenuButtonDidSelected:(XXXRoundMenuButton *)menuButton WithSelectedIndex:(NSInteger)index {
    //Sticker Menu
    if (index == 0) {
        
        //Text Menu
    } else if (index == 1) {
        
        //Pen Menu
    } else if (index == 2) {
        [self setVisibleDrawObjectView:YES];
        [self setVisibleDrawObjectDisplayView:YES];
    }
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
        [[ConnectionManager sharedInstance] sendPhotoDataWithFilename:filename
                                                   fullscreenImageURL:fullscreenImageURL
                                                      croppedImageURL:croppedImageURL
                                                                index:self.selectedIndexPath.item];
    } else {
        //alert.
    }
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


#pragma mark - PhotoDrawPenView Delegate Methods

- (void)drawPenViewDidFinished:(PhotoDrawPenView *)drawPenView WithImage:(UIImage *)image {
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

- (void)drawPenViewDidCancelled:(PhotoDrawPenView *)drawPenView {
    [self setVisibleDrawObjectView:NO];
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    if (alertView.tag == ALERT_NOT_SAVE) {
        if (buttonIndex == 1) {
            NSDictionary *sendData = @{kDataType: @(vDataTypeEditorDisconnected)};
            [connectionManager sendData:sendData];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DelayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
                [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:NO];
                [connectionManager disconnectSession];
                
                [self loadMainViewController];
            });
        }
    } else if (alertView.tag == ALERT_CONTINUE) {
        //세션 종료 시, 동기화 큐 사용을 막고 리소스를 정리한다.
        [[MessageSyncManager sharedInstance] initializeMessageSyncManagerWithEnabled:NO];
        [connectionManager disconnectSession];
        
        //계속하지 않겠다고 응답했으므로, 메인화면으로 돌아간다.
        if (buttonIndex == 1) {
            [self loadMainViewController];
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
        
        NSDictionary *sendData = @{kDataType: @(vDataTypeEditorPhotoEdit),
                                   kEditorPhotoEditIndex: @(self.selectedIndexPath.item)};
        
        [[ConnectionManager sharedInstance] sendData:sendData];
    }
}


#pragma mark - ConnectionManagerDelegate Methods

- (void)receivedEditorPhotoInsert:(NSInteger)targetFrameIndex type:(NSString *)type url:(NSURL *)url {
    //Data Receive Started.
    if (url == nil) {
        [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CELL_STATE_DOWNLOADING];
        //Data Receive Finished.
    } else {
        if ([type isEqualToString:PostfixImageCropped]) {
            UIImage *croppedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [self.cellManager setCellCroppedImageAtIndex:targetFrameIndex withCroppedImage:croppedImage];
        } else if ([type isEqualToString:PostfixImageFullscreen]) {
            UIImage *fullscreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [self.cellManager setCellStateAtIndex:targetFrameIndex withState:CELL_STATE_NONE];
            [self.cellManager setCellFullscreenImageAtIndex:targetFrameIndex withFullscreenImage:fullscreenImage];
        }
    }
    
    [self reloadData:[NSIndexPath indexPathForItem:targetFrameIndex inSection:0]];
}

- (void)receivedEditorPhotoInsertAck:(NSInteger)targetFrameIndex ack:(BOOL)insertAck {
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

- (void)receivedEditorDisconnected {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_session_disconnected", nil) message:NSLocalizedString(@"alert_content_photo_edit_continue", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_text_no", nil) otherButtonTitles:NSLocalizedString(@"alert_button_text_yes", nil), nil];
        alertView.tag = ALERT_CONTINUE;
        [alertView show];
    });
}

@end
