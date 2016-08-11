//
//  PhotoEditorViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorViewController.h"

#import "CommonConstants.h"

#import "ConnectionManager.h"
#import "ValidateCheckUtility.h"
#import "DecorateDataController.h"

#import "SphereMenu.h"
#import "XXXRoundMenuButton.h"

#import "PhotoFrameCellManager.h"
#import "PhotoEditorFrameViewCell.h"
#import "PhotoCropViewController.h"
#import "PhotoDecorateDataDisplayView.h"
#import "PhotoDrawPenMenuView.h"
#import "PhotoInputTextMenuView.h"

#import "PhotoDecorateImageData.h"
#import "PhotoDecorateTextData.h"

#import "AlertHelper.h"
#import "DispatchAsyncHelper.h"
#import "ImageUtility.h"
#import "MessageFactory.h"

@interface PhotoEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SphereMenuDelegate, XXXRoundMenuButtonDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoCropViewControllerDelegate, PhotoDecorateDataDisplayViewDelegate, PhotoDrawPenMenuViewDelegate, PhotoInputTextMenuViewDelegate, ConnectionManagerSessionConnectDelegate, ConnectionManagerPhotoEditorDelegate>

@property (nonatomic, strong) PhotoFrameCellManager *cellManager;
@property (atomic, strong) DecorateDataController *decoDataController;

@property (atomic, assign) NSIndexPath *selectedIndexPath;
@property (atomic, strong) NSURL *selectedImageURL;

@property (weak, nonatomic) IBOutlet UIView *collectionContainerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *decoDataVisibleToggleButton;
@property (strong, nonatomic) SphereMenu *photoMenu;
@property (weak, nonatomic) IBOutlet XXXRoundMenuButton *editMenuButton;

//그려진 객체들이 위치하는 뷰
@property (weak, nonatomic) IBOutlet PhotoDecorateDataDisplayView *decorateDataDisplayView;
//그려질 객체들이 위치하는 뷰(실제로 그림을 그리는 뷰)
@property (weak, nonatomic) IBOutlet PhotoDrawPenMenuView *drawPenMenuView;
//텍스트를 작성할 수 있는 뷰
@property (weak, nonatomic) IBOutlet PhotoInputTextMenuView *inputTextMenuView;

@end

@implementation PhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupDelegates];
    [self setupMenu];
    [self setupDrawController];
    
    [self addObservers];
}

- (void)setupDelegates {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionConnectDelegate = self;
    connectionManager.photoEditorDelegate = self;
    
    self.drawPenMenuView.delegate = self;
    self.inputTextMenuView.delegate = self;
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
    self.decoDataController = [[DecorateDataController alloc] init];
    self.decorateDataDisplayView.delegate = self;
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

- (void)reloadDataAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.collectionView)
            return;
        
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }];
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
            viewController.fullscreenImage = [self.cellManager getCellFullscreenImageAtIndexPath:self.selectedIndexPath];
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


#pragma mark - DrawPenMenuView & DecorateDataDisplayView's Set Visibility Methods

- (void)setVisibleDrawPenMenuView:(BOOL)visible {
    //그리기 뷰를 표시해야하면, 그려진 객체들을 보여줘야 하므로 DisplayView를 표시 상태로 변경한다.
    //그려진 객체를 숨기거나 표시할 수 있는 토글 버튼과 편집 메뉴 버튼을 숨긴다.
    //그려진 객체가 화면에 표시되므로, 토글 버튼의 상태를 Selected 상태로 변경한다.
    //이후 그림을 그릴 수 있는 DrawingPenView를 표시 상태로 변경한다.
    if (visible) {
        [self.decoDataVisibleToggleButton setHidden:YES];
        [self.editMenuButton setHidden:YES];
        [self.drawPenMenuView setHidden:NO];
    } else {
        [self.decoDataVisibleToggleButton setHidden:NO];
        [self.editMenuButton setHidden:NO];
        [self.drawPenMenuView setHidden:YES];
    }
}

- (void)setVisibleDecorateDataDisplayView:(BOOL)visible {
    //visible이 yes이면 DrawObject가 화면에 표시되는 상태를 의미한다.
    if (visible) {
        [self.decorateDataDisplayView setHidden:NO];
        [self.decoDataVisibleToggleButton setSelected:YES];
    } else {
        [self.decorateDataDisplayView setHidden:YES];
        [self.decoDataVisibleToggleButton setSelected:NO];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedCellAction:)
                                                 name:NOTIFICATION_SELECTED_CELL
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_SELECTED_CELL
                                                  object:nil];
}


#pragma mark - EventHandle Methods

- (IBAction)backButtonTapped:(id)sender {
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    
    if (connectionManager.sessionState == MCSessionStateNotConnected) {
        connectionManager.sessionConnectDelegate = nil;
        connectionManager.photoEditorDelegate = nil;
        [connectionManager disconnectSession];
        
        [self loadMainViewController];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *noActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_no" handler:nil];
    UIAlertAction *yesActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_yes"
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       __strong typeof(weakSelf) self = weakSelf;
                                                                       
                                                                       //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
                                                                       ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
                                                                       connectionManager.sessionConnectDelegate = nil;
                                                                       connectionManager.photoEditorDelegate = nil;
                                                                       [connectionManager disconnectSession];
                                                                       
                                                                       [self loadMainViewController];
                                                                   }];
    
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_session_disconnect_ask"
                                          messageKey:@"alert_content_data_not_save"
                                         firstButton:noActionButton
                                        secondButton:yesActionButton];
}

- (IBAction)saveButtonTapped:(id)sender {
//    [self.connectionManager disconnectSession];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)decoreateVisibleToggled:(id)sender {
    UIButton *view = sender;
    view.selected = !view.selected;
    
    [self setVisibleDecorateDataDisplayView:view.selected];
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
    
    //Cell Initialize
    [cell initializeCell];
    
    [cell setIndexPath:indexPath];
    [cell setTapGestureRecognizer];
    [cell setStrokeBorder];
    [cell setImage:[self.cellManager getCellCroppedImageAtIndexPath:indexPath]];
    [cell setLoadingImage:[self.cellManager getCellStateAtIndexPath:indexPath]];
    
    return cell;
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellManager getCellSizeAtIndexPath:indexPath collectionViewSize:collectionView.frame.size];
}


#pragma mark - SphereMenu Delegate Method

typedef NS_ENUM(NSInteger, PhotoMenu) {
    PhotoMenuTakePhotoAtAlbum  = 0,
    PhotoMenuTakePhotoAtCamera = 1,
    PhotoMenuEditPhoto         = 2,
    PhotoMenuDeletePhoto       = 3
};

- (void)sphereDidSelected:(SphereMenu *)sphereMenu index:(int)index {
    BOOL isSendEditCancelMsg = NO;
    
    if (index < 0) {
        isSendEditCancelMsg = YES;
    } else {
        switch (index) {
            case PhotoMenuTakePhotoAtAlbum:
                isSendEditCancelMsg = [self photoMenuCamera];
                break;
            case PhotoMenuTakePhotoAtCamera:
                isSendEditCancelMsg = [self photoMenuCamera];
                break;
            case PhotoMenuEditPhoto:
                isSendEditCancelMsg = [self photoMenuPhotoEdit];
                break;
            case PhotoMenuDeletePhoto:
                isSendEditCancelMsg = [self photoMenuPhotoDelete];
                break;
        }
    }
    
    if (isSendEditCancelMsg) {
        NSDictionary *message = [MessageFactory MessageGeneratePhotoEditCanceled:self.selectedIndexPath];
        [[ConnectionManager sharedInstance] sendMessage:message];
    }
    
    [sphereMenu dismissMenu];
}

- (BOOL)photoMenuPhotoAlbum {
    if ([ValidateCheckUtility checkPhotoAlbumAccessAuthority]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
//        __weak typeof(self) weakSelf = self;
//        [DispatchAsyncHelper dispatchAsyncWithBlock:^{
//            __strong typeof(weakSelf) self = weakSelf;
//            if (!self)
//                return;
//            
//            [self presentViewController:picker animated:YES completion:nil];
//        }];
        
        return NO;
    }
    
    UIAlertAction *noActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_no" handler:nil];
    UIAlertAction *yesActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_yes"
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                   }];
    
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:@"alert_title_album_not_authorized"
                                          messageKey:@"alert_content_album_not_authorized"
                                         firstButton:noActionButton
                                        secondButton:yesActionButton];
    
    return YES;
}

- (BOOL)photoMenuCamera {
    //camera
    //아래의 코드는 버그 방지를 위해, 임시로 추가시킨 코드이다. 기능이 구현되면 삭제될 예정이다.
    return YES;
}

- (BOOL)photoMenuPhotoEdit {
    self.selectedImageURL = nil;
    [self loadPhotoCropViewController];
    
    return NO;
}

- (BOOL)photoMenuPhotoDelete {
    [self.cellManager clearCellDataAtIndexPath:self.selectedIndexPath];
    [self reloadDataAtIndexPath:self.selectedIndexPath];
    
    NSDictionary *message = [MessageFactory MessageGeneratePhotoDeleted:self.selectedIndexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
    
    return NO;
}


#pragma mark - XXXRoundMenuButton Delegate Method

typedef NS_ENUM(NSInteger, MainMenu) {
    MainMenuSticker     = 0,
    MainMenuText        = 1,
    MainMenuPen         = 2
};

- (void)xxxRoundMenuButtonDidOpened {
    [self.decorateDataDisplayView deselectDecoView];
}

float const WaitUntilAnimationFinish = 0.24 + 0.06;

- (void)xxxRoundMenuButtonDidSelected:(XXXRoundMenuButton *)menuButton WithSelectedIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        
        switch (index) {
            case MainMenuPen:
                [self decorateMainMenuPen];
                break;
            case MainMenuText:
                [self decorateMainMenuText];
                break;
            case MainMenuSticker:
                [self decorateMainMenuSticker];
                break;
        }
    } delay:WaitUntilAnimationFinish];
}

- (void)decorateMainMenuPen {
    [self setVisibleDrawPenMenuView:YES];
    [self setVisibleDecorateDataDisplayView:YES];
}

- (void)decorateMainMenuText {
    
}

- (void)decorateMainMenuSticker {
    
}


#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *, id> *)info {
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.selectedImageURL)
            return;
        
        self.selectedImageURL = (NSURL *)info[UIImagePickerControllerReferenceURL];
        
        if (self.selectedImageURL == nil) {
            //Error Alert.
            NSDictionary *message = [MessageFactory MessageGeneratePhotoEditCanceled:self.selectedIndexPath];
            [[ConnectionManager sharedInstance] sendMessage:message];
        } else {
            [self loadPhotoCropViewController];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *message = [MessageFactory MessageGeneratePhotoEditCanceled:self.selectedIndexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
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
    [self.cellManager setCellFullscreenImageAtIndexPath:self.selectedIndexPath fullscreenImage:fullscreenImage];
    [self.cellManager setCellCroppedImageAtIndexPath:self.selectedIndexPath croppedImage:croppedImage];
    [self.cellManager setCellStateAtIndexPath:self.selectedIndexPath state:CellStateUploading];
    [self reloadDataAtIndexPath:self.selectedIndexPath];
    
    //저장된 파일의 경로를 이용하여 파일을 전송한다.
    [[ConnectionManager sharedInstance] sendPhotoDataWithFilename:filename
                                               fullscreenImageURL:fullscreenImageURL
                                                  croppedImageURL:croppedImageURL
                                                            index:self.selectedIndexPath.item];
}

- (void)cropViewControllerDidCancelled:(PhotoCropViewController *)controller {
    NSDictionary *message = [MessageFactory MessageGeneratePhotoEditCanceled:self.selectedIndexPath];
    [[ConnectionManager sharedInstance] sendMessage:message];
}


#pragma mark - PhotoDecorateDataDisplayView Delegate Methods

- (void)decoViewDidSelected:(NSInteger)index {
    NSDictionary *message = [MessageFactory MessageGenerateDecorateDataEdit:index];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)decoViewDidDeselected:(NSInteger)index {
    NSDictionary *message = [MessageFactory MessageGenerateDecorateDataEditCanceled:index];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)decoViewDidMovedAtIndex:(NSInteger)index movedPoint:(CGPoint)point {
    [self.decoDataController updateDecorateDataAtIndex:index point:point];
    
    NSDictionary *message = [MessageFactory MessageGenerateDecorateDataMoved:index movedPoint:point];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)decoViewDidResizedAtIndex:(NSInteger)index resizedRect:(CGRect)rect {
    [self.decoDataController updateDecorateDataAtIndex:index rect:rect];
    
    NSDictionary *message = [MessageFactory MessageGenerateDecorateDataResized:index resizedRect:rect];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)decoViewDidRotatedAtIndex:(NSInteger)index rotatedAngle:(CGFloat)angle {
    [self.decoDataController updateDecorateDataAtIndex:index angle:angle];
    
    NSDictionary *message = [MessageFactory MessageGenerateDecorateDataRotated:index rotatedAngle:angle];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)decoViewDidChangedZOrderAtIndex:(NSInteger)index {
    [self.decoDataController updateDecorateDataZOrderAtIndex:index];
    
    NSDictionary *message = [MessageFactory MessageGenerateDecorateDataChangZOrder:index];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)decoViewDidDeletedAtIndex:(NSInteger)index {
    NSNumber *timestamp = [[self.decoDataController getDecorateDataAtIndex:index].timestamp copy];
    [self.decoDataController deleteDecorateDataAtIndex:index];
    
    NSDictionary *message = [MessageFactory MessageGenerateDecorateDataDeleted:timestamp];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)interuptedDecorateDataEdit:(NSInteger)index {
    
}


#pragma mark - PhotoDrawPenMenuView Delegate Methods

- (void)drawPenMenuViewDidFinished:(PhotoDrawPenMenuView *)drawPenMenuView WithImage:(UIImage *)image {
    [self setVisibleDrawPenMenuView:NO];
    
    if (!image)
        return;
    
    PhotoDecorateImageData *imageData = [[PhotoDecorateImageData alloc] initWithImage:image];
    [self.decoDataController addDecorateData:imageData];
    
    UIView *decoView = [imageData getView];
    [self.decorateDataDisplayView addDecoView:decoView];
    
    NSDictionary *message = [MessageFactory MessageGenerateDecorateDataInserted:imageData.data timestamp:imageData.timestamp];
    [[ConnectionManager sharedInstance] sendMessage:message];
}

- (void)drawPenMenuViewDidCancelled:(PhotoDrawPenMenuView *)drawPenMenuView {
    [self setVisibleDrawPenMenuView:NO];
}


#pragma mark - PhotoInputPenMenuView Delegate Methods

- (void)inputTextMenuViewDidFinished:(PhotoInputTextMenuView *)inputTextMenu WithImage:(UIImage *)image {
    
}

- (void)inputTextMenuViewDidCancelled:(PhotoInputTextMenuView *)inputTextMenu {
    
}


#pragma mark - CollectionViewCell Selected Method

- (void)selectedCellAction:(NSNotification *)notification {
    if (!self.photoMenu.hidden) {
        NSArray *images;
        
        self.selectedIndexPath = (NSIndexPath *)notification.userInfo[KEY_SELECTED_CELL_INDEXPATH];
        if ([self.cellManager getCellCroppedImageAtIndexPath:self.selectedIndexPath] == nil) {
            images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"]];
        } else {
            images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"], [UIImage imageNamed:@"CircleFilter"], [UIImage imageNamed:@"CircleDelete"]];
        }
        
        if (self.photoMenu)
            self.photoMenu = nil;
        
        self.photoMenu = [[SphereMenu alloc] initWithRootView:self.collectionContainerView
                                                       Center:[notification.userInfo[KEY_SELECTED_CELL_CENTER] CGPointValue]
                                                   CloseImage:[UIImage imageNamed:@"CircleClose"] MenuImages:images];
        self.photoMenu.delegate = self;
        [self.photoMenu presentMenu];
        
        NSDictionary *message = [MessageFactory MessageGeneratePhotoEdit:self.selectedIndexPath];
        [[ConnectionManager sharedInstance] sendMessage:message];
    }
}


#pragma mark - ConnectionManager Session Connect Delegate Methods

- (void)receivedPeerConnected {
    [ConnectionManager sharedInstance].sessionState = MCSessionStateConnected;
}

- (void)receivedPeerDisconnected {
    [ConnectionManager sharedInstance].sessionState = MCSessionStateNotConnected;
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *noActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_no"
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
                                                                    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
                                                                    connectionManager.sessionConnectDelegate = nil;
                                                                    connectionManager.photoEditorDelegate = nil;
                                                                    connectionManager.messageQueueEnabled = NO;
                                                                    [connectionManager disconnectSession];
                                                                }];
    
    UIAlertAction *yesActionButton = [AlertHelper createActionWithTitleKey:@"alert_button_text_yes"
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     __strong typeof(weakSelf) self = weakSelf;
                                                                     if (!self)
                                                                         return;
                                                                     
                                                                     //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
                                                                     ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
                                                                     connectionManager.sessionConnectDelegate = nil;
                                                                     connectionManager.photoEditorDelegate = nil;
                                                                     connectionManager.messageQueueEnabled = NO;
                                                                     [connectionManager disconnectSession];
                                                                     
                                                                     [self loadMainViewController];
                                                                 }];
    
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self)
            return;
        
        [AlertHelper showAlertControllerOnViewController:self
                                                titleKey:@"alert_title_session_disconnected"
                                              messageKey:@"alert_content_photo_edit_continue"
                                             firstButton:noActionButton
                                            secondButton:yesActionButton];
    }];
}


#pragma mark - ConnectionManager Photo Editor Delegate Methods - Photo Part

- (void)receivedEditorPhotoEditing:(NSIndexPath *)indexPath {
    [self.cellManager setCellStateAtIndexPath:indexPath state:CellStateEditing];
    [self reloadDataAtIndexPath:indexPath];
}

- (void)receivedEditorPhotoEditingCancelled:(NSIndexPath *)indexPath {
    [self.cellManager setCellStateAtIndexPath:indexPath state:CellStateNone];
    [self reloadDataAtIndexPath:indexPath];
}

- (void)receivedEditorPhotoInsert:(NSIndexPath *)indexPath type:(NSString *)type url:(NSURL *)url {
    //Data Receive Started.
    if (url == nil) {
        [self.cellManager setCellStateAtIndexPath:indexPath state:CellStateDownloading];
        //Data Receive Finished.
    } else {
        if ([type isEqualToString:PostfixImageCropped]) {
            UIImage *croppedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [self.cellManager setCellCroppedImageAtIndexPath:indexPath croppedImage:croppedImage];
        } else if ([type isEqualToString:PostfixImageFullscreen]) {
            UIImage *fullscreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [self.cellManager setCellStateAtIndexPath:indexPath state:CellStateNone];
            [self.cellManager setCellFullscreenImageAtIndexPath:indexPath fullscreenImage:fullscreenImage];
        }
    }
    
    [self reloadDataAtIndexPath:indexPath];
}

- (void)receivedEditorPhotoInsertAck:(NSIndexPath *)indexPath ack:(BOOL)insertAck {
    if (insertAck) {
        [self.cellManager setCellStateAtIndexPath:indexPath state:CellStateNone];
        [self reloadDataAtIndexPath:indexPath];
    } else {
        //error
    }
}

- (void)receivedEditorPhotoDeleted:(NSIndexPath *)indexPath {
    [self.cellManager clearCellDataAtIndexPath:indexPath];
    [self reloadDataAtIndexPath:indexPath];
}

- (void)interruptedEditorPhotoEditing:(NSIndexPath *)indexPath {
    if (!self.photoMenu && !self.photoMenu.isHidden)
        return;
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self)
            return;
        
        [self.photoMenu dismissMenu];
    }];
}


#pragma mark - ConnectionManager Photo Editor Delegate Methods - DecorateData Part

- (void)receivedEditorDecorateDataEditing:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;
        
        [self.decorateDataDisplayView setDecoViewEditableAtIndex:index enable:NO];
    }];
}

- (void)receivedEditorDecorateDataEditCancelled:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;
        
        [self.decorateDataDisplayView setDecoViewEditableAtIndex:index enable:YES];
    }];
}

- (void)receivedEditorDecorateDataInsert:(id)insertData timestamp:(NSNumber *)timestamp {
    PhotoDecorateData *decorateData;
    
    if ([insertData isKindOfClass:[UIImage class]]) {
        NSLog(@"I'm Image.");
        decorateData = [[PhotoDecorateImageData alloc] initWithImage:insertData timestamp:timestamp];
    } else if ([insertData isKindOfClass:[NSString class]]) {
        NSLog(@"I'm Text.");
        decorateData = [[PhotoDecorateTextData alloc] initWithText:insertData timestamp:timestamp];
    }
    
    [self.decoDataController addDecorateData:decorateData];
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;
        
        UIView *decoView = [decorateData getView];
        
        //위에서 하나 추가했으니까, 무조건 하나는 있다.
        if ([self.decoDataController getCount] == 1) {
            //하나만 있을 때는 일반적인 추가 절차를 따른다.
            [self.decorateDataDisplayView addDecoView:decoView];
            return;
        }
        
        //하나 이상있을 때는, 방금 추가된 객체의 동기화된 인덱스를 확인한 뒤 결정한다.
        NSUInteger index = [self.decoDataController getIndexOfDecorateData:decorateData];
        //에외처리.
        if (index == NSNotFound)
            return;
        
        if (index == [self.decoDataController getCount] - 1) {
            //정렬된 배열에서의 위치가 맨 마지막일 경우, 일반적인 추가 절차를 따른다.
            [self.decorateDataDisplayView addDecoView:decoView];
        } else {
            //정렬된 배열에서의 위치가 맨 마지막이 아닐 경우, 하나 이상의 객체가 이미 추가되어 있음을 의미한다.
            //들어갈 인덱스의 값을 지정하여 보내준다.
            [self.decorateDataDisplayView addDecoView:decoView index:index];
        }
    }];
}

- (void)receivedEditorDecorateDataMoved:(NSInteger)index movedPoint:(CGPoint)point {
    [self.decoDataController updateDecorateDataAtIndex:index point:point];
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;
        
        [self.decorateDataDisplayView updateDecoViewAtIndex:index point:point];
    }];
}

- (void)receivedEditorDecorateDataResized:(NSInteger)index resizedRect:(CGRect)rect {
    [self.decoDataController updateDecorateDataAtIndex:index rect:rect];
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;

        [self.decorateDataDisplayView updateDecoViewAtIndex:index rect:rect];
    }];
}

- (void)receivedEditorDecorateDataRotated:(NSInteger)index rotatedAngle:(CGFloat)angle {
    [self.decoDataController updateDecorateDataAtIndex:index angle:angle];
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;

        [self.decorateDataDisplayView updateDecoViewAtIndex:index angle:angle];
    }];
}

- (void)receivedEditorDecorateDataZOrderChanged:(NSInteger)index {
    [self.decoDataController updateDecorateDataZOrderAtIndex:index];
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;

        [self.decorateDataDisplayView updateDecoViewZOrderAtIndex:index];
    }];
}

- (void)receivedEditorDecorateDataDeleted:(NSNumber *)timestamp {
    NSUInteger index = [self.decoDataController getIndexOfTimestamp:timestamp];
    
    if (index == NSNotFound)
        return;
    
    [self.decoDataController deleteDecorateDataAtIndex:index];
    
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;

        [self.decorateDataDisplayView deleteDecoViewAtIndex:index];
    }];
}

- (void)interruptedEditorDecorateDataEditing:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    
    [DispatchAsyncHelper dispatchAsyncWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.decorateDataDisplayView)
            return;
        
        [self.decorateDataDisplayView deselectDecoView];
    }];
}

@end
