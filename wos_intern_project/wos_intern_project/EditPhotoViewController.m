//
//  EditPhotoViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "EditPhotoViewController.h"
#import "CropPhotoViewController.h"

#import "PESessionManager.h"
#import "PEMessageReceiver.h"

#import "PEPhotoController.h"
#import "PEDecorateController.h"

#import "XXXRoundMenuButton.h"
#import "SphereMenu.h"

#import "PhotoCollectionViewCell.h"
#import "DecorateDisplayView.h"
#import "DecoratePenMenuView.h"
#import "DecorateTextMenuView.h"
#import "DecorateStickerMenuView.h"

#import "AlertHelper.h"
#import "AuthorityCheckUtility.h"
#import "ColorUtility.h"
#import "DispatchAsyncHelper.h"
#import "ImageUtility.h"
#import "ProgressHelper.h"

NSString *const SegueMoveToCropper  = @"moveToPhotoCrop";
NSString *const SeguePopupSticker   = @"popupPhotoSticker";

@interface EditPhotoViewController () <XXXRoundMenuButtonDelegate, SphereMenuDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropPhotoViewControllerDelegate, PEPhotoControllerDelegate, UICollectionViewDelegateFlowLayout, DecorateDisplayViewDelegate, PEDecorateControllerDelegate, DecoratePenMenuViewDelegate, DecorateTextMenuViewDelegate, DecorateStickerMenuViewDelegate, PEMessageReceiverStateChangeDelegate>

@property (weak, nonatomic) IBOutlet UIButton *decorateDisplayToggleButton;
@property (weak, nonatomic) IBOutlet XXXRoundMenuButton *mainMenuButton;
@property (strong, nonatomic) SphereMenu *photoMenu;

@property (weak, nonatomic) IBOutlet UICollectionView *photoDisplayCollectionView;  //사진들이 위치하는 뷰
@property (strong, atomic) PEPhotoController *photoController;

@property (weak, nonatomic) IBOutlet DecorateDisplayView *decorateDisplayView; //그려진 객체들이 위치하는 뷰
@property (strong, atomic) PEDecorateController *decorateController;

@property (weak, nonatomic) IBOutlet DecoratePenMenuView *penMenuView; //그려질 객체들이 위치하는 뷰(실제로 그림을 그리는 뷰)
@property (weak, nonatomic) IBOutlet DecorateTextMenuView *textMenuView; //텍스트를 작성할 수 있는 뷰
@property (weak, nonatomic) IBOutlet DecorateStickerMenuView *stickerMenuView; //스티커를 선택할 수 있는 뷰

@property (strong, nonatomic) PEMessageReceiver *messageReceiver;

//For CropViewController
@property (strong, nonatomic) NSURL *pickedImageURL;
@property (strong, nonatomic) UIImage *takePhotoImage;

@property (assign, nonatomic) BOOL isEnteredOtherPeer;

@end

@implementation EditPhotoViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDelegates];
    [self setupMainMenu];
    
    self.isEnteredOtherPeer = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startSynchronizeMessage];
}

- (void)dealloc {
    self.photoMenu = nil;
    self.photoController = nil;
    self.decorateController = nil;
    self.messageReceiver = nil;
    
    [ImageUtility removeAllTemporaryImages];
}

//CropView의 호출은 PhotoDataDisplayView에서 일어난다.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueMoveToCropper]) {
        CropPhotoViewController *viewController = [segue destinationViewController];
        viewController.delegate = self;
        
        UICollectionViewCell *cell = [self.photoDisplayCollectionView cellForItemAtIndexPath:self.photoController.selectedIndexPath];
        [viewController setCropAreaSize:cell.bounds.size];
        
        if (self.pickedImageURL) {
            [viewController setImageUrl:self.pickedImageURL];
            return;
        }
        
        if (self.takePhotoImage) {
            [viewController setImage:self.takePhotoImage];
            return;
        }
        
        PEPhoto *photoData = [self.photoController photoDataOfCellAtSelectedIndexPath];
        if (photoData) {
            [viewController setImage:photoData.fullscreenImage filiterType:photoData.filterType];
            return;
        }
    }
}


#pragma mark - Setup Methods

//이 함수는 EditPhotoVC를 호출하는 VC에서 값을 전달하기 위해 호출하는 함수이다.
//내부적으로 setupControllers를 호출하여, EditPhotoVC에서 사용하는 DataController를 생성한다.
- (void)setPhotoFrame:(NSInteger)selectPhotoFrame {
    [self prepareDataControllers:selectPhotoFrame];
}

- (void)prepareDataControllers:(NSInteger)selectPhotoFrame {
    self.photoController = [[PEPhotoController alloc] initWithFrameNumber:selectPhotoFrame];
    self.photoController.delegate = self;
    
    self.decorateController = [[PEDecorateController alloc] init];
    self.decorateController.delegate = self;
}

- (void)setupDelegates {
    PEMessageReceiver *messageReceiver = [PESessionManager sharedInstance].messageReceiver;
    messageReceiver.stateChangeDelegate = self;
    
    //DisplayView's Datasource & Delegate
    self.photoDisplayCollectionView.dataSource = (id<UICollectionViewDataSource>)self.photoController;
    self.photoDisplayCollectionView.delegate = self;
    
    self.decorateDisplayView.dataSource = (id<DecorateDisplayViewDataSource>)self.decorateController;
    self.decorateDisplayView.delegate = self;
    
    //MenuView's Delegate
    self.penMenuView.delegate = self;
    self.textMenuView.delegate = self;
    self.stickerMenuView.delegate = self;
}

- (void)setupMainMenu {
    NSArray *menuItems = @[[UIImage imageNamed:@"MenuSticker"], [UIImage imageNamed:@"MenuText"], [UIImage imageNamed:@"MenuPen"]];
    
    [self.mainMenuButton loadButtonWithIcons:menuItems
                                 startDegree:-M_PI
                                layoutDegree:M_PI / 2];
    
    [self.mainMenuButton setMainColor:[ColorUtility colorWithName:ColorNameBlue]];
    
    [self.mainMenuButton setCenterIcon:[UIImage imageNamed:@"MenuMain"]];
    [self.mainMenuButton setCenterIconType:XXXIconTypeCustomImage];
    [self.mainMenuButton setDelegate:self];
}


#pragma mark - Start Synchronize Message Methods

- (void)startSynchronizeMessage {
    [[PESessionManager sharedInstance].messageReceiver startSynchronizeMessage];
}


#pragma mark - Present Other ViewController Methods

- (void)presentMainViewController {
    [[PESessionManager sharedInstance] disconnectSession];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)presentPhotoCropViewController {
    [self performSegueWithIdentifier:SegueMoveToCropper sender:self];
}

- (void)presentNotAuthorizedAlertController:(NSString *)titleKey content:(NSString *)contentKey {
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:titleKey
                                          messageKey:contentKey
                                              button:@"alert_button_text_no"
                                       buttonHandler:nil
                                         otherButton:@"alert_button_text_yes"
                                  otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                  }];
}


#pragma mark - EventHandling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.mainMenuButton.isOpened) {
        [self.mainMenuButton dismissMenuButton];
    }
}

- (IBAction)backButtonTapped:(id)sender {
    PESessionManager *sessionManager = [PESessionManager sharedInstance];
    NSString *alertTitleKey, *alertContentKey;
    
    if (sessionManager.session.sessionState == SessionStateDisconnected) {
        alertTitleKey = @"alert_title_edit_finish";
        alertContentKey = @"alert_content_edit_finish";
    } else if (sessionManager.session.sessionState == SessionStateConnected) {
        alertTitleKey = @"alert_title_session_disconnect_ask";
        alertContentKey = @"alert_content_data_not_save";
    }
    
    if (!alertTitleKey && !alertContentKey) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [AlertHelper showAlertControllerOnViewController:self
                                            titleKey:alertTitleKey
                                          messageKey:alertContentKey
                                              button:@"alert_button_text_no"
                                       buttonHandler:nil
                                         otherButton:@"alert_button_text_yes"
                                  otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                      __strong typeof(weakSelf) self = weakSelf;
                                      
                                      if (!self) {
                                          return;
                                      }
                                      
                                      [self presentMainViewController];
                                  }];
}

- (IBAction)saveButtonTapped:(id)sender {
    WMProgressHUD *progress = [ProgressHelper showProgressAddedTo:self.navigationController.view titleKey:@"progress_title_saving"];
    
    UIImage *mergedCaptureImage = [ImageUtility mergeImage:[self viewCapture]
                                                    imageB:[self.decorateDisplayView viewCapture]];
    
    [ImageUtility saveImageAtPhotoAlbum:mergedCaptureImage];
    [ProgressHelper dismissProgress:progress dismissTitleKey:@"progress_title_saved" dismissType:DismissWithDone];
}

- (IBAction)decoreateVisibleToggled:(id)sender {
    UIButton *view = sender;
    view.selected = !view.selected;
    
    [self setMenuVisiblity:MenuVisiblityDecorateDisplay visiblity:view.selected];
}


#pragma mark - View Capture Method

- (UIImage *)viewCapture {
    //메인메뉴가 열려있으면 닫는다.
    if (self.mainMenuButton.isOpened) {
        [self.mainMenuButton dismissMenuButton];
    }
    
    NSArray<PhotoCollectionViewCell *> *cells = self.photoDisplayCollectionView.visibleCells;
    
    //이미지 캡쳐 전에, 셀들의 경계선을 지운다.
    for (PhotoCollectionViewCell *cell in cells) {
        [cell removeStrokeBorder];
    }
    
    UIImage *capturedImage = [ImageUtility viewCaptureImage:self.photoDisplayCollectionView];
    
    //이미지 캡쳐 후에, 셀들의 경계선을 다시 그린다.
    for (PhotoCollectionViewCell *cell in cells) {
        [cell setStrokeBorder];
    }
    
    return capturedImage;
}


#pragma mark - penMenuView & DecorateDataDisplayView's Set Visibility Methods

NS_ENUM(NSInteger, MenuVisiblityType) {
    MenuVisblityPen = 0,
    MenuVisiblityText,
    MenuVisiblitySticker,
    MenuVisiblityDecorateDisplay
};

- (void)setMenuVisiblity:(NSInteger)menuType visiblity:(BOOL)visiblity {
    if (menuType == MenuVisiblityDecorateDisplay) {
        //togglebutton은 setSelected로 숨기거나, 표시한다.
        [self.decorateDisplayToggleButton setSelected:visiblity];
        [self.decorateDisplayView setHidden:!visiblity];
        return;
    }
    
    [self.decorateDisplayToggleButton setSelected:YES];
    [self.decorateDisplayView setHidden:NO];
    
    [self.decorateDisplayToggleButton setHidden:visiblity];
    [self.mainMenuButton setHidden:visiblity];
    
    switch (menuType) {
        case MenuVisblityPen:
            [self.penMenuView setHidden:!visiblity];
            break;
        case MenuVisiblityText:
            [self.textMenuView setHidden:!visiblity];
            break;
        case MenuVisiblitySticker:
            [self.stickerMenuView setHidden:!visiblity];
            break;
    }
}


#pragma mark - XXXRoundMenuButton Delegate Method

typedef NS_ENUM(NSInteger, MainMenu) {
    MainMenuSticker     = 0,
    MainMenuText        = 1,
    MainMenuPen         = 2
};

- (void)xxxRoundMenuButtonDidOpened {
    
}

float const WaitUntilMainMenuAnimationFinish  = 0.24 + 0.06;

- (void)xxxRoundMenuButtonDidSelected:(XXXRoundMenuButton *)menuButton WithSelectedIndex:(NSInteger)index {
    [NSTimer scheduledTimerWithTimeInterval:WaitUntilMainMenuAnimationFinish
                                     target:self
                                   selector:@selector(selectedDecorateMainMenu:)
                                   userInfo:@(index)
                                    repeats:NO];
}

- (void)selectedDecorateMainMenu:(NSTimer *)timer {
    NSNumber *selectedMainMenu = [timer userInfo];
    
    if (!selectedMainMenu) {
        return;
    }
    
    switch (selectedMainMenu.integerValue) {
        case MainMenuPen:
            [self setMenuVisiblity:MenuVisblityPen visiblity:YES];
            break;
        case MainMenuText:
            [self setMenuVisiblity:MenuVisiblityText visiblity:YES];
            break;
        case MainMenuSticker:
            [self setMenuVisiblity:MenuVisiblitySticker visiblity:YES];
            break;
    }
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
                isSendEditCancelMsg = [self photoMenuPhotoAlbum];
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
        if (![self.photoController.dataSender sendDeselectPhotoDataMessage:self.photoController.selectedIndexPath]) {
            return;
        }
        
        self.photoController.selectedIndexPath = nil;
    }
    
    [sphereMenu dismissMenu];
}

- (BOOL)photoMenuPhotoAlbum {
    if ([AuthorityCheckUtility checkPhotoAlbumAccessAuthority]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
        return NO;
    }
    
    [self presentNotAuthorizedAlertController:@"alert_title_album_not_authorized" content:@"alert_content_album_not_authorized"];
    
    return YES;
}

- (BOOL)photoMenuCamera {
    if ([AuthorityCheckUtility checkPhotoCameraAccessAuthority]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
        return NO;
    }
    
    [self presentNotAuthorizedAlertController:@"alert_title_camera_not_authorized" content:@"alert_content_camera_not_authorized"];
    
    return YES;
}

- (BOOL)photoMenuPhotoEdit {
    [self presentPhotoCropViewController];
    
    return NO;
}

- (BOOL)photoMenuPhotoDelete {
    if (![self.photoController.dataSender sendDeletePhotoDataMessage:self.photoController.selectedIndexPath]) {
        //삭제 실패 시, Alert를 띄우는 방식으로 처리하고 - 메뉴는 닫는다.
        return YES;
    }
    
    [self.photoController clearCellDataAtSelectedIndexPath];
    self.photoController.selectedIndexPath = nil;
    
    return YES;
}


#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *, id> *)info {
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        self.pickedImageURL = (NSURL *)info[UIImagePickerControllerReferenceURL];
    } else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.takePhotoImage = [ImageUtility resizeImage:(UIImage *)info[UIImagePickerControllerOriginalImage]];
    }
    
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        __strong typeof(weakSelf) self = weakSelf;
        
        if (!self) {
            return;
        }
        
        if (!self.pickedImageURL && !self.takePhotoImage) {
            //Error Alert.
            [self.photoController updateCellStateAtSelectedIndexPath:CellStateNone];
            self.photoController.selectedIndexPath = nil;
        } else {
            [self presentPhotoCropViewController];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.photoController updateCellStateAtSelectedIndexPath:CellStateNone];
    [self.photoController.dataSender sendDeselectPhotoDataMessage:self.photoController.selectedIndexPath];
    self.photoController.selectedIndexPath = nil;
}


#pragma mark - PhotoCropViewController Delegate Methods

- (void)cropViewControllerDidFinished:(UIImage *)fullscreenImage croppedImage:(UIImage *)croppedImage filterType:(NSInteger)filterType {
    if (!fullscreenImage || !croppedImage) {
        //Alert. 사진 가져오지 못함.
        [self.photoController updateCellStateAtSelectedIndexPath:CellStateNone];
        [self.photoController.dataSender sendDeselectPhotoDataMessage:self.photoController.selectedIndexPath];
        self.photoController.selectedIndexPath = nil;
        return;
    }
    
    //CropViewController에서 Fullscreen Img, Cropped Img를 받은 후 저장한다.
    PEPhoto *photoData = [[PEPhoto alloc] init];
    photoData.state = CellStateUploading;
    photoData.fullscreenImage = fullscreenImage;
    photoData.croppedImage = croppedImage;
    photoData.filterType = filterType;
    
    self.pickedImageURL = nil;
    self.takePhotoImage = nil;
    
    //임시로 전달받은 두개의 파일을 저장한다.
    NSString *filename = [ImageUtility saveImageAtTemporaryDirectoryWithFullscreenImage:fullscreenImage withCroppedImage:croppedImage];
    
    if (!filename) {
        //Alert. 사진 저장 실패.
        [self.photoController updateCellStateAtSelectedIndexPath:CellStateNone];
        [self.photoController.dataSender sendDeselectPhotoDataMessage:self.photoController.selectedIndexPath];
        self.photoController.selectedIndexPath = nil;
        return;
    }
    
    NSURL *fullscreenImageURL = [ImageUtility fullscreenImageURLWithFilename:filename];
    NSURL *croppedImageURL = [ImageUtility croppedImageURLWithFilename:filename];
    
    [self.photoController setCellDataAtSelectedIndexPath:photoData];
    [self.photoController.dataSender sendInsertPhotoDataMessage:self.photoController.selectedIndexPath
                                                   originalImageURL:fullscreenImageURL
                                                    croppedImageURL:croppedImageURL
                                                         filterType:filterType];
}

- (void)cropViewControllerDidCancelled {
    self.pickedImageURL = nil;
    self.takePhotoImage = nil;
    
    [self.photoController updateCellStateAtSelectedIndexPath:CellStateNone];
    [self.photoController.dataSender sendDeselectPhotoDataMessage:self.photoController.selectedIndexPath];
    self.photoController.selectedIndexPath = nil;
}


#pragma mark - CollectionViewController Delegate Flowlayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.photoController sizeOfCell:indexPath collectionViewSize:collectionView.bounds.size];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isEnteredOtherPeer) {
        //Alert 표시. 상대방이 들어오기 전까지는 사진 메뉴를 사용할 수 없다.
        [AlertHelper showAlertControllerOnViewController:self
                                                titleKey:@"alert_title_other_peer_not_entered"
                                              messageKey:@"alert_content_other_peer_not_entered"
                                                  button:@"alert_button_text_ok"
                                           buttonHandler:nil];
        return;
    }
    
    if (self.mainMenuButton.isOpened) {
        [self.mainMenuButton dismissMenuButton];
    }
    
    //사진 선택 메시지 송신에 실패하면 메뉴를 띄우지 않는다.
    if (![self.photoController.dataSender sendSelectPhotoDataMessage:indexPath]) {
        return;
    }
    
    self.photoController.selectedIndexPath = indexPath;
    
    NSArray *images;
    if ([self.photoController hasImageAtSelectedIndexPath]) {
        images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"], [UIImage imageNamed:@"CircleFilter"], [UIImage imageNamed:@"CircleDelete"]];
    } else {
        images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"]];
    }
    
    if (self.photoMenu)
        self.photoMenu = nil;
    
    CGRect cellFrame = [collectionView cellForItemAtIndexPath:indexPath].frame;
    CGPoint centerPoint = CGPointMake(collectionView.superview.frame.origin.x + collectionView.frame.origin.x + cellFrame.origin.x + cellFrame.size.width / 2.0f,
                                      collectionView.superview.frame.origin.y + collectionView.frame.origin.y + cellFrame.origin.y + cellFrame.size.height / 2.0f);
    
    self.photoMenu = [[SphereMenu alloc] initWithRootView:self.navigationController.view
                                                   Center:centerPoint
                                               CloseImage:[UIImage imageNamed:@"CircleClose"] MenuImages:images];
    self.photoMenu.delegate = self;
    [self.photoMenu presentMenu];
}

/**
 * @brief IndexPath에 해당하는 하나의 셀만을 reload한다. 기존에 제공되는 reloadItemsAtIndexPaths에 IndexPath가 하나만 담긴 배열을 전달한다.
 * @param indexPath : 갱신할 셀의 IndexPatah
 */
- (void)reloadDataAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        
        if (!self)
            return;
        
        [self.photoDisplayCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }];
}


#pragma mark - Photo Data Controller Delegate Methods

- (void)didUpdatePhotoData:(NSIndexPath *)indexPath {
    [self reloadDataAtIndexPath:indexPath];
}

- (void)didFinishReceivePhotoData:(NSIndexPath *)indexPath {
    //Ack 전송 실패시 어떻게 할 것인가...?
    [self.photoController.dataSender sendPhotoDataAckMessage:indexPath ack:YES];
}

- (void)didErrorReceivePhotoData:(NSIndexPath *)indexPath {
    //Ack 전송 실패시 어떻게 할 것인가...?
    [self.photoController.dataSender sendPhotoDataAckMessage:indexPath ack:NO];
}

- (void)didInterruptPhotoDataSelection:(NSIndexPath *)indexPath {
    [self.photoController updateCellStateAtSelectedIndexPath:CellStateNone];
    self.photoController.selectedIndexPath = nil;
    [self.photoMenu setHidden:YES];
    [self.photoMenu dismissMenu];
}


#pragma mark - Decorate Data Controller Delegate Methods

- (void)didReceiveScreenSize {
    self.isEnteredOtherPeer = YES;
}

- (void)didUpdateDecorateData:(NSUUID *)uuid {
    [self.decorateDisplayView updateDecorateViewOfUUID:uuid];
}

- (void)didInterruptDecorateDataSelection:(NSUUID *)uuid {
    [self.decorateController selectDecorateData:uuid selected:NO];
}


#pragma mark - PhotoDecorateDataDisplayView Delegate Methods

- (void)didSelectDecorateViewOfUUID:(NSUUID *)uuid selected:(BOOL)selected {
    if (selected) {
        if (![self.decorateController.dataSender sendSelectDecorateDataMessage:uuid]) {
            return;
        }
    } else {
        if (![self.decorateController.dataSender sendDeselectDecorateDataMessage:uuid]) {
            return;
        }
    }
    
    [self.decorateController selectDecorateData:uuid selected:selected];
}

- (void)didUpdateDecorateViewOfUUID:(NSUUID *)uuid frame:(CGRect)frame {
    if (![self.decorateController.dataSender sendUpdateDecorateDataMessage:uuid updateFrame:frame]) {
        return;
    }
    
    [self.decorateController updateDecorateData:uuid frame:frame];
    
}

- (void)didDeleteDecorateViewOfUUID:(NSUUID *)uuid {
    if (![self.decorateController.dataSender sendDeleteDecorateDataMessage:uuid]) {
        return;
    }
    
    [self.decorateController deleteDecorateData:uuid];
}


#pragma mark - PhotoPenMenuView Delegate Methods

- (void)decoratePenMenuViewDidFinished:(PEDecorate *)decorateData {
    [self setMenuVisiblity:MenuVisblityPen visiblity:NO];
    
    if (![self.decorateController.dataSender sendInsertDecorateDataMessage:decorateData]) {
        return;
    }
    
    [self.decorateController addDecorateData:decorateData];
}

- (void)decoratePenMenuViewDidCancelled {
    [self setMenuVisiblity:MenuVisblityPen visiblity:NO];
}


#pragma mark - PhotoTextMenuView Delegate Methods

- (void)decorateTextMenuViewDidFinished:(PEDecorate *)decorateData {
    [self setMenuVisiblity:MenuVisiblityText visiblity:NO];
    
    if (![self.decorateController.dataSender sendInsertDecorateDataMessage:decorateData]) {
        return;
    }
    
    [self.decorateController addDecorateData:decorateData];
}

- (void)decorateTextMenuViewDidCancelled {
    [self setMenuVisiblity:MenuVisiblityText visiblity:NO];
}


#pragma mark - PhotoStickerViewController Delegate Methods

- (void)decorateStickerMenuViewDidSelectItem:(PEDecorate *)decorateData {
    if (![self.decorateController.dataSender sendInsertDecorateDataMessage:decorateData]) {
        return;
    }
    
    [self.decorateController addDecorateData:decorateData];
}

- (void)decorateStickerMenuViewDidFinish {
    [self setMenuVisiblity:MenuVisiblitySticker visiblity:NO];
}


#pragma mark - MessageReceiverStateChangeDelegate Methods

- (void)didReceiveChangeSessionState:(NSInteger)state {
    __weak typeof(self) weakSelf = self;
    
    switch (state) {
        case SessionStateConnected:
            //여기선 세션 연결이 일어날 일이 없다.
            //추후에 세션 연결 끊겼다가 다시 복구되는 경우에나 사용할 것 같다.
            break;
        case SessionStateDisconnected:
            [AlertHelper showAlertControllerOnViewController:self
                                                    titleKey:@"alert_title_session_disconnected"
                                                  messageKey:@"alert_content_photo_edit_continue"
                                                      button:@"alert_button_text_no"
                                               buttonHandler:^(UIAlertAction * _Nonnull action) {
                                                   [[PESessionManager sharedInstance] disconnectSession];
                                               }
                                                 otherButton:@"alert_button_text_yes"
                                          otherButtonHandler:^(UIAlertAction * _Nonnull action) {
                                              __strong typeof(weakSelf) self = weakSelf;
                                              
                                              if (!self) {
                                                  return;
                                              }
                                              
                                              [self presentMainViewController];
                                          }];
            break;
    }
}

@end