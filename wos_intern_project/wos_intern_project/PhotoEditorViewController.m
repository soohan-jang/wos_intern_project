//
//  PhotoEditorViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorViewController.h"

@interface PhotoEditorViewController ()

@property (strong, nonatomic) UIImage *image;

@end

@implementation PhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.photoFrameKind = self.photoFrameKind;
    
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

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPhotoInsert:) name:NOTIFICATION_RECV_EDITOR_PHOTO_INSERT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPhotoDelete:) name:NOTIFICATION_RECV_EDITOR_PHOTO_DELETE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSelectFrameChanged:) name:NOTIFICATION_RECV_EDITOR_DRAWING_INSERT object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSelectFrameChanged:) name:NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSelectFrameConfirm:) name:NOTIFICATION_RECV_EDITOR_DRAWING_DELETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSessionDisconnected:) name:NOTIFICATION_RECV_EDITOR_DISCONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCellAction:) name:@"tapped_cell" object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_PHOTO_INSERT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_PHOTO_DELETE object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_DRAWING_INSERT object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_DRAWING_UPDATE object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_DRAWING_DELETE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECV_EDITOR_DISCONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tapped_cell" object:nil];
}

- (void)selectedCellAction:(NSNotification *)notification {
    NSArray *images;
    
    self.selectedPhotoFrameIndex = (NSIndexPath *)[notification.userInfo objectForKey:@"index_path"];
    if ([self.collectionView hasImageWithItemIndex:self.selectedPhotoFrameIndex.item]) {
        images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"], [UIImage imageNamed:@"CircleFilter"], [UIImage imageNamed:@"CircleDelete"]];
    }
    else {
        images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"]];
    }
    
    SphereMenu *sphereMenu = [[SphereMenu alloc] initWithRootView:self.view Center:self.view.center CloseImage:[UIImage imageNamed:@"CircleClose"] MenuImages:images];
    sphereMenu.delegate = self;
    [sphereMenu presentMenu];
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
        }
    }
}

/**** CollectionViewController DataSource Methods ****/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionView numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoEditorFrameViewCell *cell = (PhotoEditorFrameViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell setIndexPath:indexPath];
    [cell setTapGestureRecognizer];
    [cell setStrokeBorder];
    [cell setImage:[self.collectionView getImageWithItemIndex:indexPath.item]];
    
    return cell;
}

/**** CollectionViewController Delegate Flowlayout Methods ****/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.collectionView insetForCollectionView];
}

- (void)sphereDidSelected:(SphereMenu *)sphereMenu Index:(int)index {
    if (index == 0) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        
        if (status == ALAuthorizationStatusNotDetermined) {
            //아직 권한 설정 안됨. 해당 Alert 표시.
        }
        else if (status == ALAuthorizationStatusAuthorized) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            //picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:picker animated:YES completion:nil];
            });
        }
        else {
            //권한 없음. 해당 Alert 표시.
        }
    }
    else if (index == 1) {
        
    }
    else if (index == 2) {
        
    }
    else if (index == 3) {
        [self.collectionView delImageWithItemIndex:self.selectedPhotoFrameIndex.item];
        [self.collectionView reloadData];
    
        NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE),
                                   KEY_EDITOR_PHOTO_DELETE_INDEX: @(self.selectedPhotoFrameIndex.item)};
        
        [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    }
    
    [sphereMenu dismissMenu];
}

/**** UIImagePickerController Delegate Methods ****/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        CGFloat scale;
        
        if (image.size.width > 4000) {
            scale = 4.0f;
        }
        else if (image.size.width > 3000) {
            scale = 3.0f;
        }
        else if (image.size.width > 2000) {
            scale = 2.0f;
        }
        else {
            scale = 1.0f;
        }
        
        CGSize targetSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
        
        UIGraphicsBeginImageContext(targetSize);
        [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        image = nil;
            
        [self.collectionView putImageWithItemIndex:self.selectedPhotoFrameIndex.item Image:resizedImage];
        [self.collectionView reloadData];
        
        NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT),
                                   KEY_EDITOR_PHOTO_INSERT_INDEX: @(self.selectedPhotoFrameIndex.item),
                                   KEY_EDITOR_PHOTO_INSERT_DATA: resizedImage};
        
        [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
//        [ConnectionManager sharedInstance].ownSession sendResourceAtURL:<#(nonnull NSURL *)#> withName:<#(nonnull NSString *)#> toPeer:<#(nonnull MCPeerID *)#> withCompletionHandler:<#^(NSError * _Nullable error)completionHandler#>
    });
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/**** Perform Selector Methods ****/


/**** Session Communication Methods ****/
- (void)receivedPhotoInsert:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger item = [(NSNumber *)[notification.userInfo objectForKey:KEY_EDITOR_PHOTO_INSERT_INDEX] integerValue];
        UIImage *image = (UIImage *)[notification.userInfo objectForKey:KEY_EDITOR_PHOTO_INSERT_DATA];
        
        [self.collectionView putImageWithItemIndex:item Image:image];
        [self.collectionView reloadData];
    });
}

- (void)receivedPhotoDelete:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger item = [(NSNumber *)[notification.userInfo objectForKey:KEY_EDITOR_PHOTO_DELETE_INDEX] integerValue];
        
        [self.collectionView delImageWithItemIndex:item];
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
