//
//  PhotoDataController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 28..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PEPhotoController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#import "PESessionManager.h"
#import "PEMessageSender.h"
#import "PEMessageReceiver.h"

#import "PhotoCollectionViewCell.h"

#import "ImageUtility.h"

NSInteger const DefaultMargin   = 5;

@interface PEPhotoMessageSender ()

@property (strong, nonatomic) PEMessageSender *messageSender;

@end

@implementation PEPhotoMessageSender

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.messageSender = [PESessionManager sharedInstance].messageSender;
    }
    
    return self;
}

- (BOOL)sendSelectPhotoDataMessage:(NSIndexPath *)indexPath {
    return [self.messageSender sendSelectPhotoDataMessage:indexPath];
}

- (BOOL)sendDeselectPhotoDataMessage:(NSIndexPath *)indexPath {
    return [self.messageSender sendDeselectPhotoDataMessage:indexPath];
}

- (void)sendInsertPhotoDataMessage:(NSIndexPath *)indexPath originalImageURL:(NSURL *)originalImageURL croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType {
    [self.messageSender sendInsertPhotoDataMessage:indexPath
                                  originalImageURL:originalImageURL
                                   croppedImageURL:croppedImageURL
                                        filterType:filterType];
}

- (void)sendUpdatePhotoDataMessage:(NSIndexPath *)indexPath croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType {
    [self.messageSender sendUpdatePhotoDataMessage:indexPath
                                   croppedImageURL:croppedImageURL
                                        filterType:filterType];
}

- (BOOL)sendDeletePhotoDataMessage:(NSIndexPath *)indexPath {
    return [self.messageSender sendDeletePhotoDataMessage:indexPath];
}

- (BOOL)sendPhotoDataAckMessage:(NSIndexPath *)indexPath ack:(BOOL)ack {
    return [self.messageSender sendPhotoDataAckMessage:indexPath ack:ack];
}

@end

@interface PEPhotoController () <UICollectionViewDataSource, PEMessageReceiverPhotoDataDelegate>

/**
 몇 번째 사진 액자를 골랐는지에 대한 프로퍼티이다. 사진 액자는 1번부터 12번까지 있다.
 */
@property (nonatomic, assign) NSInteger photoFrameNumber;
@property (atomic, strong) NSArray<PEPhoto *> *cellDatas;

@end

@implementation PEPhotoController


#pragma mark - Initialize Method

- (instancetype)initWithFrameNumber:(NSInteger)frameNumber {
    self = [super init];
    
    if (self) {
        self.photoFrameNumber = frameNumber;
        
        NSMutableArray<PEPhoto *> *cellInitArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [self numberOfCells]; i++) {
            [cellInitArray addObject:[[PEPhoto alloc] init]];
        }
        
        if (cellInitArray != nil || cellInitArray.count > 0) {
            self.cellDatas = [NSArray arrayWithArray:cellInitArray];
        }
        
        [cellInitArray removeAllObjects];
        cellInitArray = nil;
        
        self.dataSender = [[PEPhotoMessageSender alloc] init];
        [PESessionManager sharedInstance].messageReceiver.photoDataDelegate = self;
    }
    
    return self;
}


#pragma mark - Get Cell's number and size Methods

- (NSInteger)numberOfCells {
    switch (self.photoFrameNumber) {
        case 0:
            return 1;
        case 1:
        case 2:
            return 2;
        case 3:
        case 4:
        case 8:
        case 9:
            return 3;
        case 5:
        case 6:
        case 7:
        case 10:
        case 11:
            return 4;
        default:
            return 1;
    }
}

- (CGSize)cellSizeOfIndexPath:(NSIndexPath *)indexPath collectionViewSize:(CGSize)collectionViewSize {
    CGFloat containerWidth = collectionViewSize.width;
    CGFloat containerHeight = collectionViewSize.height;
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
    switch (self.photoFrameNumber) {
        case 0:
            return CGSizeMake(containerWidth - DefaultMargin, containerHeight - DefaultMargin);
            break;
        case 1:
            return CGSizeMake((containerWidth - DefaultMargin) / 2.0f, containerHeight - DefaultMargin);
            break;
        case 2:
            return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            break;
        case 3:
            return CGSizeMake((containerWidth - DefaultMargin) / 3.0f, containerHeight - DefaultMargin);
            break;
        case 4:
            return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 3.0f);
            break;
        case 5:
            return CGSizeMake((containerWidth - DefaultMargin) / 4.0f, containerHeight - DefaultMargin);
            break;
        case 6:
            return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 4.0f);
            break;
        case 7:
            return CGSizeMake((containerWidth - DefaultMargin) / 2.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            break;
        case 8:
            if (indexPath.item == 0) {
                return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            } else {
                return CGSizeMake((containerWidth - DefaultMargin) / 2.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            }
            break;
        case 9:
            if (indexPath.item == 2) {
                return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            } else {
                return CGSizeMake((containerWidth - DefaultMargin) / 2.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            }
            break;
        case 10:
            if (indexPath.item == 0) {
                return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            } else {
                return CGSizeMake((containerWidth - DefaultMargin * 1.01f) / 3.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            }
            break;
        case 11:
            if (indexPath.item == 3) {
                return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            } else {
                return CGSizeMake((containerWidth - DefaultMargin * 1.01f) / 3.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
            }
            break;
        default:
            cellWidth = cellHeight = 0;
            break;
    }
    
    return CGSizeMake(cellWidth, cellHeight);
}


#pragma mark - Set & Get Cell's Data Methods

- (void)setCellDataAtSelectedIndexPath:(PEPhoto *)photoData {
    [self setCellDataAtIndexPath:self.selectedIndexPath photoData:photoData];
}

- (void)setCellDataAtIndexPath:(NSIndexPath *)indexPath photoData:(PEPhoto *)photoData {
    if ([self isOutBoundIndex:indexPath]) {
        return;
    }
    
    [self updateCellStateAtIndexPath:indexPath state:photoData.state];
    self.cellDatas[indexPath.item].originalImage = photoData.originalImage;
    self.cellDatas[indexPath.item].croppedImage = photoData.croppedImage;
    self.cellDatas[indexPath.item].filterType = photoData.filterType;
    
    if (self.delegate) {
        [self.delegate didUpdatePhotoData:indexPath];
    }
}

- (void)updateCellStateAtSelectedIndexPath:(NSInteger)state {
    [self updateCellStateAtIndexPath:self.selectedIndexPath state:state];
}

- (void)updateCellStateAtIndexPath:(NSIndexPath *)indexPath state:(NSInteger)state {
    if ([self isOutBoundIndex:indexPath]) {
        return;
    }
    
    self.cellDatas[indexPath.item].state = state;
    
    if (self.delegate) {
        [self.delegate didUpdatePhotoData:indexPath];
    }
}

- (PEPhoto *)photoDataOfCellAtSelectedIndexPath {
    return [self photoDataOfCellAtIndexPath:self.selectedIndexPath];
}

- (PEPhoto *)photoDataOfCellAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isOutBoundIndex:indexPath]) {
        return nil;
    }
    
    return self.cellDatas[indexPath.item];
}

- (BOOL)hasImageAtSelectedIndexPath {
    return [self hasImageAtIndexPath:self.selectedIndexPath];
}

- (BOOL)hasImageAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isOutBoundIndex:indexPath]) {
        return NO;
    }
    
    if (self.cellDatas[indexPath.item].croppedImage) {
        return YES;
    }
    
    return NO;
}


#pragma mark - clear method

- (void)clearCellDataAtSelectedIndexPath {
    [self clearCellDataAtIndexPath:self.selectedIndexPath];
}

- (void)clearCellDataAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isOutBoundIndex:indexPath]) {
        return;
    }
    
    self.cellDatas[indexPath.item].state = CellStateNone;
    self.cellDatas[indexPath.item].originalImage = nil;
    self.cellDatas[indexPath.item].croppedImage = nil;
    
    if (self.delegate) {
        [self.delegate didUpdatePhotoData:indexPath];
    }
}


#pragma mark - check method

- (BOOL)isNilOrEmpty {
    if (self.cellDatas == nil || self.cellDatas.count == 0) {
        return YES;
    }
    
    return NO;
}

/**
 * @brief 이 함수는 내부적으로 isNilOrEmpty를 호출한다. 함께 호출하지 말 것.
 */
- (BOOL)isOutBoundIndex:(NSIndexPath *)indexPath {
    if ([self isNilOrEmpty]) {
        return YES;
    }
    
    if (!indexPath) {
        return YES;
    }
    
    if (self.cellDatas.count <= indexPath.item) {
        return YES;
    }
    
    return NO;
}


#pragma mark - CollectionViewController DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfCells];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCollectionViewCell class]) forIndexPath:indexPath];
    
    //Cell Initialize
    [cell initializeCell];
    
    [cell setStrokeBorder];
    [cell setImage:self.cellDatas[indexPath.item].croppedImage];
    [cell setLoadingImage:self.cellDatas[indexPath.item].state];
    
    return cell;
}


#pragma mark - MessageReceiverPhotoDataDelegate Methods

- (void)didReceiveSelectPhotoData:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath.item == indexPath.item && self.delegate) {
        [self.delegate didInterruptPhotoDataSelection:indexPath];
    }
    
    [self updateCellStateAtIndexPath:indexPath state:CellStateEditing];
}

- (void)didReceiveDeselectPhotoData:(NSIndexPath *)indexPath {
    [self updateCellStateAtIndexPath:indexPath state:CellStateNone];
}

- (void)didReceiveStartReceivePhotoData:(NSIndexPath *)indexPath {
    [self updateCellStateAtIndexPath:indexPath state:CellStateDownloading];
}

- (void)didReceiveFinishReceivePhotoData:(NSIndexPath *)indexPath {
    [self updateCellStateAtIndexPath:indexPath state:CellStateNone];
    
    if (self.delegate) {
        [self.delegate didFinishReceivePhotoData:indexPath];
    }
}

- (void)didReceiveErrorReceivePhotoData:(NSIndexPath *)indexPath dataType:(NSString *)dataType {
    //Do Something, about error fixing.
    
    if (self.delegate) {
        [self.delegate didErrorReceivePhotoData:indexPath];
    }
}

- (void)didReceiveInsertPhotoData:(NSIndexPath *)indexPath dataType:(NSString *)dataType insertDataURL:(NSURL *)insertDataURL filterType:(NSInteger)filterType {
    if ([dataType isEqualToString:PhotoTypeCropped]) {
        self.cellDatas[indexPath.item].croppedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:insertDataURL]];
    } else if ([dataType isEqualToString:PhotoTypeOriginal]) {
        self.cellDatas[indexPath.item].originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:insertDataURL]];
    }
    
    self.cellDatas[indexPath.item].filterType = filterType;
    
    if (self.delegate) {
        [self.delegate didUpdatePhotoData:indexPath];
    }
}

- (void)didReceiveUpdatePhotoData:(NSIndexPath *)indexPath updateDataURL:(NSURL *)updateDataURL filterType:(NSInteger)filterType {
    self.cellDatas[indexPath.item].croppedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:updateDataURL]];
    self.cellDatas[indexPath.item].filterType = filterType;
    
    if (self.delegate) {
        [self.delegate didUpdatePhotoData:indexPath];
    }
}

- (void)didReceiveDeletePhotoData:(NSIndexPath *)indexPath {
    [self clearCellDataAtIndexPath:indexPath];
}

- (void)didReceivePhotoDataAck:(NSIndexPath *)indexPath ack:(BOOL)ack {
    [self updateCellStateAtIndexPath:indexPath state:CellStateNone];
    
    if (!ack) {
        //Do Something, about error fixing.
    }
}

@end
