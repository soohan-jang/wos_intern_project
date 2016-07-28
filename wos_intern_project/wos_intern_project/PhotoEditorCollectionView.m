//
//  PhotoEditorCollectionView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 18..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorCollectionView.h"

#define SECTION_NUMBER  1
#define DEFAULT_MARGIN  5

const NSInteger CELL_STATE_NONE         = 0;
const NSInteger CELL_STATE_UPLOADING    = 1;
const NSInteger CELL_STATE_DOWNLOADING  = 2;
const NSInteger CELL_STATE_EDITING      = 3;


@implementation PhotoEditorCollectionView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCellAction:) name:NOTIFICATION_SELECTED_CELL object:nil];
        
        //Init properties.
        self.isMenuAppear = NO;
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SELECTED_CELL object:nil];
}

- (CGSize)buildEachPhotoFrameSize:(NSInteger)itemIndex {
    CGFloat containerWidth = self.frame.size.width;
    CGFloat containerHeight = self.frame.size.height;
    CGFloat cellWidth;
    CGFloat cellHeight;
    
    /** Template **/
    /** 너비 1, 높이 0.5
     return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
    **/
    /** 너비 0.5, 높이 1
     return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, containerHeight - DEFAULT_MARGIN);
    **/
    /** 너비 0.5. 높이 0.5
     return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
    **/
    if (self.photoFrameNumber == 0) {
        return CGSizeMake(containerWidth - DEFAULT_MARGIN, containerHeight - DEFAULT_MARGIN);
    }
    else if (self.photoFrameNumber == 1) {
        return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, containerHeight - DEFAULT_MARGIN);
    }
    else if (self.photoFrameNumber == 2) {
        return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
    }
    else if (self.photoFrameNumber == 3) {
        return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 3.0f, containerHeight - DEFAULT_MARGIN);
    }
    else if (self.photoFrameNumber == 4) {
        return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 3.0f);
    }
    else if (self.photoFrameNumber == 5) {
        return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 4.0f, containerHeight - DEFAULT_MARGIN);
    }
    else if (self.photoFrameNumber == 6) {
        return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 4.0f);
    }
    else if (self.photoFrameNumber == 7) {
        return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
    }
    else if (self.photoFrameNumber == 8) {
        if (itemIndex == 0) {
            return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
        else {
            return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
    }
    else if (self.photoFrameNumber == 9) {
        if (itemIndex == 2) {
            return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
        else {
            return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
    }
    else if (self.photoFrameNumber == 10) {
        if (itemIndex == 0) {
            return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
        else {
            return CGSizeMake((containerWidth - DEFAULT_MARGIN * 1.01f) / 3.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
    }
    else if (self.photoFrameNumber == 11) {
        if (itemIndex == 3) {
            return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
        else {
            return CGSizeMake((containerWidth - DEFAULT_MARGIN * 1.01f) / 3.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
    }
    else {
        cellWidth = cellHeight = 0;
    }
    
    return CGSizeMake(cellWidth, cellHeight);
}

- (NSInteger)numberOfSections {
    return SECTION_NUMBER;
}

- (NSInteger)numberOfItems {
    NSInteger itemNumber = 0;
    
    switch (self.photoFrameNumber) {
        case 0:
            itemNumber = 1;
            break;
        case 1:
        case 2:
            itemNumber = 2;
            break;
        case 3:
        case 4:
        case 8:
        case 9:
            itemNumber = 3;
            break;
        case 5:
        case 6:
        case 7:
        case 10:
        case 11:
            itemNumber = 4;
            break;
        default:
            itemNumber = 1;
            break;
    }
    
    return itemNumber;
}

- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoEditorFrameViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"photoFrameCell" forIndexPath:indexPath];
    [cell setIndexPath:indexPath];
    [cell setTapGestureRecognizer];
    [cell setStrokeBorder];
    [cell setImage:[self getCellCroppedImageAtIndex:indexPath.item]];
    [cell setLoadingImage:[self getCellStateAtIndex:indexPath.item]];
    
    return cell;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self buildEachPhotoFrameSize:itemIndexPath.item];
}

- (UIEdgeInsets)insetForCollectionView {
    return UIEdgeInsetsMake(DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f);
}

- (CGSize)getSizeOfSelectedCell {
    return [self cellForItemAtIndexPath:self.selectedPhotoFrameIndex].frame.size;
}

- (void)selectedCellAction:(NSNotification *)notification {
    if (!self.isMenuAppear) {
        self.isMenuAppear = YES;
        
        NSArray *images;
        
        self.selectedPhotoFrameIndex = (NSIndexPath *)notification.userInfo[KEY_SELECTED_CELL_INDEXPATH];
        if ([self getCellCroppedImageAtIndex:self.selectedPhotoFrameIndex.item] == nil) {
            images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"]];
        }
        else {
            images = @[[UIImage imageNamed:@"CircleAlbum"], [UIImage imageNamed:@"CircleCamera"], [UIImage imageNamed:@"CircleFilter"], [UIImage imageNamed:@"CircleDelete"]];
        }
        
        CGPoint sphereMenuCenter = CGPointMake([notification.userInfo[KEY_SELECTED_CELL_CENTER_X] floatValue], [notification.userInfo[KEY_SELECTED_CELL_CENTER_Y] floatValue]);
        CGFloat angleOffset;
        
        //사진 액자가 화면의 왼쪽에 위치할 때,
        if (sphereMenuCenter.x < self.center.x) {
            angleOffset = M_PI * 1.1f;
        }
        //사진 액자가 화면의 오른쪽에 위치할 때,
        else if (sphereMenuCenter.x > self.center.x) {
            if (images.count == 2) {
                angleOffset = M_PI;
            }
            else {
                angleOffset = M_PI * -1.3f;
            }
        }
        //사진 액자가 화면의 중간에 위치할 때,
        else {
            angleOffset = M_PI;
        }
        
        SphereMenu *sphereMenu = [[SphereMenu alloc] initWithRootView:self.superview Center:sphereMenuCenter CloseImage:[UIImage imageNamed:@"CircleClose"] MenuImages:images StartAngle:angleOffset];
        sphereMenu.delegate = self;
        [sphereMenu presentMenu];
    }
}

- (void)loadPhotoCropViewController {
    [self.parentViewController performSegueWithIdentifier:@"moveToPhotoCrop" sender:self.parentViewController];
}

/**** SphereMenu Delegate Method ****/
- (void)sphereDidSelected:(SphereMenu *)sphereMenu Index:(int)index {
    if (index == 0) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        
        if (status == ALAuthorizationStatusNotDetermined || status == ALAuthorizationStatusAuthorized) {
            //아직 권한이 설정되지 않은 경우엔, System에서 Alert 띄워준다.
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self.parentViewController presentViewController:picker animated:YES completion:nil];
            
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT),
                                       KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedPhotoFrameIndex.item)};
            
            [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
        }
        else {
            //권한 없음. 해당 Alert 표시.
        }
    }
    else if (index == 1) {
        //camera
        
        /*
        NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT),
        KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedPhotoFrameIndex.item)};
         
        [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
         */
    }
    else if (index == 2) {
        //edit
        self.selectedImageURL = nil;
        [self loadPhotoCropViewController];
        
        NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT),
                                   KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedPhotoFrameIndex.item)};
        
        [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    }
    else if (index == 3) {
        [self clearCellDataOfSelectedIndex];
        [self reloadData];
        
        NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE),
                                   KEY_EDITOR_PHOTO_DELETE_INDEX: @(self.selectedPhotoFrameIndex.item)};
        
        [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
    }
    
    [sphereMenu dismissMenu];
    self.isMenuAppear = NO;
}

/**** UIImagePickerController Delegate Methods ****/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.selectedImageURL = (NSURL *)info[UIImagePickerControllerReferenceURL];
        
        if (self.selectedImageURL == nil) {
            //Error Alert.
            NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                                       KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedPhotoFrameIndex.item)};
            
            [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
        }
        else {
            [self loadPhotoCropViewController];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *sendData = @{KEY_DATA_TYPE: @(VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED),
                               KEY_EDITOR_PHOTO_EDIT_INDEX: @(self.selectedPhotoFrameIndex.item)};
    
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

- (void)setCellStateOfSelectedIndex:(NSInteger)state {
    [self setCellStateAtIndex:self.selectedPhotoFrameIndex.item state:state];
}

- (void)setCellFullscreenImageOfSelectedIndex:(UIImage *)fullscreenImage {
    [self setCellFullscreenImageAtIndex:self.selectedPhotoFrameIndex.item fullscreenImage:fullscreenImage];
}

- (void)setCellCroppedImageOfSelectedIndex:(UIImage *)croppedImage {
    [self setCellCroppedImageAtIndex:self.selectedPhotoFrameIndex.item croppedImage:croppedImage];
}

- (void)setCellStateAtIndex:(NSInteger)index state:(NSInteger)state {
    if (self.cellStates == nil) {
        self.cellStates = [@{@(index): @(state)} mutableCopy];
    }
    else {
        [self.cellStates setObject:@(state) forKey:@(index)];
    }
}

- (void)setCellFullscreenImageAtIndex:(NSInteger)index fullscreenImage:(UIImage *)fullscreenImage {
    if (self.cellFullscreenImages == nil) {
        self.cellFullscreenImages = [@{@(index): fullscreenImage} mutableCopy];
    }
    else {
        [self.cellFullscreenImages setObject:fullscreenImage forKey:@(index)];
    }
}

- (void)setCellCroppedImageAtIndex:(NSInteger)index croppedImage:(UIImage *)croppedImage {
    if (self.cellCroppedImages == nil) {
        self.cellCroppedImages = [@{@(index): croppedImage} mutableCopy];
    }
    else {
        [self.cellCroppedImages setObject:croppedImage forKey:@(index)];
    }
}

- (NSInteger)getCellStateOfSelectedIndex {
    return [self.cellStates[@(self.selectedPhotoFrameIndex.item)] integerValue];
}

- (UIImage *)getCellFullscreenImageOfSelectedIndex {
    return self.cellFullscreenImages[@(self.selectedPhotoFrameIndex.item)];
}

- (UIImage *)getCellCroppedImageOfSelectedIndex {
    return self.cellCroppedImages[@(self.selectedPhotoFrameIndex.item)];
}

- (NSInteger)getCellStateAtIndex:(NSInteger)index {
    return [self.cellStates[@(index)] integerValue];
}

- (UIImage *)getCellFullscreenImageAtIndex:(NSInteger)index {
    return self.cellFullscreenImages[@(index)];
}

- (UIImage *)getCellCroppedImageAtIndex:(NSInteger)index {
    return self.cellCroppedImages[@(index)];
}

- (void)clearCellDataOfSelectedIndex {
    self.cellStates[@(self.selectedPhotoFrameIndex.item)] = nil;
    self.cellFullscreenImages[@(self.selectedPhotoFrameIndex.item)] = nil;
    self.cellCroppedImages[@(self.selectedPhotoFrameIndex.item)] = nil;
}

- (void)clearCellDataAtIndex:(NSInteger)index {
    self.cellStates[@(index)] = nil;
    self.cellFullscreenImages[@(index)] = nil;
    self.cellCroppedImages[@(index)] = nil;
}

@end
