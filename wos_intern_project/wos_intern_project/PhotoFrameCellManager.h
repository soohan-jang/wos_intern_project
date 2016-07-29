//
//  PhotoFrameCellManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 28..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#define SECTION_NUMBER  1

extern const NSInteger CELL_STATE_NONE;
extern const NSInteger CELL_STATE_UPLOADING;
extern const NSInteger CELL_STATE_DOWNLOADING;
extern const NSInteger CELL_STATE_EDITING;

@interface PhotoFrameCellManager : NSObject

/**
 Framenumber를 토대로 CellManager를 초기화한 뒤 반환한다.
 */
- (instancetype)initWithFrameNumber:(NSInteger)frameNumber;

/**
 섹션의 수를 반환한다. 섹션의 수는 1이다.
 */
- (NSInteger)getSectionNumber;

/**
 액자종류에 따라 표시될 사진 액자의 수를 반환한다.
 */
- (NSInteger)getItemNumber;

/**
 인덱스에 위치한 사진 액자의 크기를 반환한다.
 */
- (CGSize)getCellSizeWithIndex:(NSInteger)cellIndex withCollectionViewSize:(CGSize)collectionViewSize;

- (void)setCellStateAtIndex:(NSInteger)index withState:(NSInteger)state;
- (void)setCellFullscreenImageAtIndex:(NSInteger)index withFullscreenImage:(UIImage *)fullscreenImage;
- (void)setCellCroppedImageAtIndex:(NSInteger)index withCroppedImage:(UIImage *)croppedImage;

- (NSInteger)getCellStateAtIndex:(NSInteger)index;
- (UIImage *)getCellFullscreenImageAtIndex:(NSInteger)index;
- (UIImage *)getCellCroppedImageAtIndex:(NSInteger)index;

- (void)clearCellDataAtIndex:(NSInteger)index;

@end
