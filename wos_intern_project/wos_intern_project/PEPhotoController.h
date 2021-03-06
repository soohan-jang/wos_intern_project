//
//  PhotoDataController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 28..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PEPhoto.h"

typedef NS_ENUM(NSInteger, CellState) {
    CellStateNone           = 0,
    CellStateUploading      = 1,
    CellStateDownloading    = 2,
    CellStateEditing        = 3
};

@protocol PEPhotoControllerDelegate;

@interface PEPhotoMessageSender : NSObject

- (BOOL)sendSelectPhotoDataMessage:(NSIndexPath *)indexPath;
- (BOOL)sendDeselectPhotoDataMessage:(NSIndexPath *)indexPath;

- (void)sendInsertPhotoDataMessage:(NSIndexPath *)indexPath originalImageURL:(NSURL *)originalImageURL croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType;
- (void)sendUpdatePhotoDataMessage:(NSIndexPath *)indexPath croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType;
- (BOOL)sendDeletePhotoDataMessage:(NSIndexPath *)indexPath;

- (BOOL)sendPhotoDataAckMessage:(NSIndexPath *)indexPath ack:(BOOL)ack;

@end

@interface PEPhotoController : NSObject

@property (weak, nonatomic) id<PEPhotoControllerDelegate> delegate;
@property (strong, nonatomic) PEPhotoMessageSender *dataSender;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

/**
 Framenumber를 토대로 CellManager를 초기화한 뒤 반환한다.
 */
- (instancetype)initWithPhotoFrameNumber:(NSInteger)photoframeNumber;

/**
 인덱스에 위치한 사진 액자의 크기를 반환한다.
 */
- (CGSize)cellSizeOfIndexPath:(NSIndexPath *)indexPath collectionViewSize:(CGSize)collectionViewSize;

/**
 인덱스에 위치한 사진 액자에 상태값, Fullscreen Image, Cropped Image 모두를 설정한다. 이 함수는 새로운 사진을 입력했을 때 호출한다.
 */
- (void)setCellDataAtIndexPath:(NSIndexPath *)indexPath photoData:(PEPhoto *)photoData;
- (void)setCellDataAtSelectedIndexPath:(PEPhoto *)photoData;

/**
 인덱스에 위치한 사진 액자의 상태를 변경한다. 상태값은 None, Uploading, Downloading, Editing이 있다.
 */
- (void)updateCellStateAtIndexPath:(NSIndexPath *)indexPath state:(NSInteger)state;
- (void)updateCellStateAtSelectedIndexPath:(NSInteger)state;

- (PEPhoto *)photoDataOfCellAtIndexPath:(NSIndexPath *)indexPath;
- (PEPhoto *)photoDataOfCellAtSelectedIndexPath;

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

- (void)setEnabledAllPhotoData;

@end

@protocol PEPhotoControllerDelegate <NSObject>
@required
- (void)didUpdatePhotoData:(NSIndexPath *)indexPath;
- (void)didFinishReceivePhotoData:(NSIndexPath *)indexPath;
- (void)didErrorReceivePhotoData:(NSIndexPath *)indexPath;
- (void)didInterruptPhotoDataSelection:(NSIndexPath *)indexPath;

@end
