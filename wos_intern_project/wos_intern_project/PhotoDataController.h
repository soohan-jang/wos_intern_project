//
//  PhotoDataController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 28..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoData.h"

typedef NS_ENUM(NSInteger, CellState) {
    CellStateNone           = 0,
    CellStateUploading      = 1,
    CellStateDownloading    = 2,
    CellStateEditing        = 3
};

@protocol PhotoDataControllerDelegate;

@interface PhotoDataController : NSObject

@property (weak, nonatomic) id<PhotoDataControllerDelegate> delegate;
@property (assign, nonatomic) NSIndexPath *selectedIndexPath;

/**
 Framenumber를 토대로 CellManager를 초기화한 뒤 반환한다.
 */
- (instancetype)initWithFrameNumber:(NSInteger)frameNumber;

/**
 인덱스에 위치한 사진 액자의 크기를 반환한다.
 */
- (CGSize)sizeOfCell:(NSIndexPath *)indexPath collectionViewSize:(CGSize)collectionViewSize;

/**
 인덱스에 위치한 사진 액자에 상태값, Fullscreen Image, Cropped Image 모두를 설정한다. 이 함수는 새로운 사진을 입력했을 때 호출한다.
 */
- (void)setCellDataAtIndexPath:(NSIndexPath *)indexPath photoData:(PhotoData *)photoData;
- (void)setCellDataAtSelectedIndexPath:(PhotoData *)photoData;

/**
 인덱스에 위치한 사진 액자의 상태를 변경한다. 상태값은 None, Uploading, Downloading, Editing이 있다.
 */
- (void)updateCellStateAtIndexPath:(NSIndexPath *)indexPath state:(NSInteger)state;
- (void)updateCellStateAtSelectedIndexPath:(NSInteger)state;

///**
// 인덱스에 위치한 사진 액자의 상태 정보를 가져온다. 상태값은 None, Uploading, Downloading, Editing이 있다.
// */
//- (NSInteger)getCellStateAtIndexPath:(NSIndexPath *)indexPath;
//
/**
 인덱스에 해당하는 사진 액자와 연결된 Fullscreen Image를 가져온다.
 */
- (UIImage *)fullscreenImageOfCellAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)fullscreenImageOfCellAtSelectedIndexPath;

/**
 인덱스에 해당하는 사진 액자에 사진 정보가 있는지 확인한다.
 */
- (BOOL)hasImageAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)hasImageAtSelectedIndexPath;

/**
 해당 인덱스의 사진 액자 정보를 삭제한다.
 */
- (void)clearCellDataAtIndexPath:(NSIndexPath *)indexPath;
- (void)clearCellDataAtSelectedIndexPath;

@end

@protocol PhotoDataControllerDelegate <NSObject>
@required
- (void)didPhotoDataSourceUpdate:(NSIndexPath *)indexPath;
- (void)didPhotoEditInterrupt;

@end
