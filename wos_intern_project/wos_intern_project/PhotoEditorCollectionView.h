//
//  PhotoEditorCollectionView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 18..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RFQuiltLayout.h"

#import "PhotoEditorFrameViewCell.h"

extern NSInteger const STATE_NONE;
extern NSInteger const STATE_UPLOADING;
extern NSInteger const STATE_DOWNLOADING;

@interface PhotoEditorCollectionView : UICollectionView

@property (nonatomic) NSInteger photoFrameNumber;

@property (atomic, strong) NSMutableDictionary *loadingStateDictionary;
@property (atomic, strong) NSMutableDictionary *imageDictionary;

/**
 액자종류에 따라 표시될 각각의 사진 액자 크기를 설정한다.
 */
- (CGSize)buildEachPhotoFrameSize:(NSInteger)itemIndex;

/**
 액자종류에 따라 표시될 사진 액자의 수를 반환한다.
 */
- (NSInteger)numberOfItems;

/**
 인덱스에 위치한 사진 액자를 반환한다.
 */
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)itemIndexPath;

/**
 인덱스에 위치한 사진 액자의 크기를 반환한다. 사진 액자 크기는 bulidEachPhotoFrameSize에 의해 설정된다.
 */
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)itemIndexPath;

/**
 CollectionView를 수직 가운데 졍렬하기 위한 UIEdgeInsets를 반환한다.
 */
- (UIEdgeInsets)insetForCollectionView;

/**
 각 Cell들의 상태를 저장 및 관리하기 위한 함수이다.
 */
- (void)setLoadingStateWithItemIndex:(NSInteger)item State:(NSInteger)state;
- (NSInteger)getLoadingStateWithItemIndex:(NSInteger)item;

/**
 각 Cell들의 이미지를 저장 및 관리하기 위한 함수이다.
 */
- (void)putImageWithItemIndex:(NSInteger)item Image:(UIImage *)image;
- (UIImage *)getImageWithItemIndex:(NSInteger)item;
- (void)delImageWithItemIndex:(NSInteger)item;
- (BOOL)hasImageWithItemIndex:(NSInteger)item;

@end
