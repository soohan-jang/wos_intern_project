//
//  PhotoFrameCellManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 28..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CellState) {
    CellStateNone           = 0,
    CellStateUploading      = 1,
    CellStateDownloading    = 2,
    CellStateEditing        = 3
};

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
- (CGSize)getCellSizeAtIndexPath:(NSIndexPath *)indexPath collectionViewSize:(CGSize)collectionViewSize;

/**
 인덱스에 위치한 사진 액자의 상태를 변경한다. 상태값은 None, Uploading, Downloading, Editing이 있다.
 */
- (void)setCellStateAtIndexPath:(NSIndexPath *)indexPath state:(NSInteger)state;

/**
 인덱스에 위치한 사진 액자와 Fullscreen Image를 연결한다. 실제로 View에 표시하지는 않고, 연결만 지어놓는다.
 연결된 Fullscreen Image는 사진 편집 메뉴를 탭하여 진입했을 때 표시된다.
 */
- (void)setCellFullscreenImageAtIndexPath:(NSIndexPath *)indexPath fullscreenImage:(UIImage *)fullscreenImage;

/**
 인덱스에 위치한 사진 액자와 Cropped Image를 연결한다. 실제로 View에 표시된다.
 */
- (void)setCellCroppedImageAtIndexPath:(NSIndexPath *)indexPath croppedImage:(UIImage *)croppedImage;

/**
 인덱스에 위치한 사진 액자의 상태 정보를 가져온다. 상태값은 None, Uploading, Downloading, Editing이 있다.
 */
- (NSInteger)getCellStateAtIndexPath:(NSIndexPath *)indexPath;

/**
 인덱스에 해당하는 사진 액자와 연결된 Fullscreen Image를 가져온다.
 */
- (UIImage *)getCellFullscreenImageAtIndexPath:(NSIndexPath *)indexPath;

/**
 인덱스에 해당하는 사진 액자와 연결된 Cropped Image를 가져온다.
 */
- (UIImage *)getCellCroppedImageAtIndexPath:(NSIndexPath *)indexPath;

/**
 해당 인덱스의 사진 액자 정보를 삭제한다.
 */
- (void)clearCellDataAtIndexPath:(NSIndexPath *)indexPath;

@end
