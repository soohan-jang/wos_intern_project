//
//  PhotoEditorCollectionView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 18..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#import "ConnectionManager.h"

#import "SphereMenu.h"
#import "PhotoEditorFrameViewCell.h"

extern const NSInteger CELL_STATE_NONE;
extern const NSInteger CELL_STATE_UPLOADING;
extern const NSInteger CELL_STATE_DOWNLOADING;
extern const NSInteger CELL_STATE_EDITING;

@interface PhotoEditorCollectionView : UICollectionView <SphereMenuDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UIViewController *parentViewController;

/**
 몇 번째 사진 액자를 골랐는지에 대한 프로퍼티이다. 사진 액자는 1번부터 12번까지 있다.
 */
@property (nonatomic, assign) NSInteger photoFrameNumber;
//@property (nonatomic, strong) UITapGestureRecognizer *scrollTapGestureRecognizer;
@property (nonatomic, assign) NSIndexPath *selectedPhotoFrameIndex;
@property (nonatomic, strong) NSURL *selectedImageURL;

@property (nonatomic, assign) BOOL isMenuAppear;

//@property (atomic, strong) NSMutableDictionary *cellDataDictionary;
@property (atomic, strong) NSMutableDictionary *cellFullscreenImages;
@property (atomic, strong) NSMutableDictionary *cellCroppedImages;
@property (atomic, strong) NSMutableDictionary *cellStates;

/**
 액자종류에 따라 표시될 각각의 사진 액자 크기를 설정한다.
 */
- (CGSize)buildEachPhotoFrameSize:(NSInteger)itemIndex;

/**
 섹션의 수를 반환한다. 섹션의 수는 1이다.
 */
- (NSInteger)numberOfSections;

/**
 액자종류에 따라 표시될 사진 액자의 수를 반환한다.
 */
- (NSInteger)numberOfItems;

/**
 인덱스에 위치한 사진 액자를 반환한다.
 */
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 인덱스에 위치한 사진 액자의 크기를 반환한다. 사진 액자 크기는 bulidEachPhotoFrameSize에 의해 설정된다.
 */
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)itemIndexPath;

/**
 CollectionView를 수직 가운데 졍렬하기 위한 UIEdgeInsets를 반환한다.
 */
- (UIEdgeInsets)insetForCollectionView;

- (CGSize)getSizeOfSelectedCell;

/**
 각 셀들이 클릭되었음을 알리는 Notification을 수신하는 함수이다.
 */
- (void)selectedCellAction:(NSNotification *)notification;

- (void)loadPhotoCropViewController;

- (void)setCellStateOfSelectedIndex:(NSInteger)state;
- (void)setCellFullscreenImageOfSelectedIndex:(UIImage *)fullscreenImage;
- (void)setCellCroppedImageOfSelectedIndex:(UIImage *)croppedImage;

- (void)setCellStateAtIndex:(NSInteger)index state:(NSInteger)state;
- (void)setCellFullscreenImageAtIndex:(NSInteger)index fullscreenImage:(UIImage *)fullscreenImage;
- (void)setCellCroppedImageAtIndex:(NSInteger)index croppedImage:(UIImage *)croppedImage;

- (NSInteger)getCellStateOfSelectedIndex;
- (UIImage *)getCellFullscreenImageOfSelectedIndex;
- (UIImage *)getCellCroppedImageOfSelectedIndex;

- (NSInteger)getCellStateAtIndex:(NSInteger)index;
- (UIImage *)getCellFullscreenImageAtIndex:(NSInteger)index;
- (UIImage *)getCellCroppedImageAtIndex:(NSInteger)index;

- (void)clearCellDataOfSelectedIndex;
- (void)clearCellDataAtIndex:(NSInteger)index;

@end
