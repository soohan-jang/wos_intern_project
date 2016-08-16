//
//  PhotoEditorFrameCellManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 28..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorFrameCellManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#import "PhotoEditorFrameCellData.h"

NSInteger const DefaultMargin = 5;

@interface PhotoEditorFrameCellManager ()

/**
 몇 번째 사진 액자를 골랐는지에 대한 프로퍼티이다. 사진 액자는 1번부터 12번까지 있다.
 */
@property (nonatomic, assign) NSInteger photoFrameNumber;
@property (atomic, strong) NSArray<PhotoEditorFrameCellData *> *cellDatas;

@end

@implementation PhotoEditorFrameCellManager

- (instancetype)initWithFrameNumber:(NSInteger)frameNumber {
    self = [super init];
    
    if (self) {
        self.photoFrameNumber = frameNumber;
        
        NSMutableArray<PhotoEditorFrameCellData *> *cellInitArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [self getItemNumber]; i++) {
            [cellInitArray addObject:[[PhotoEditorFrameCellData alloc] init]];
        }
        
        if (cellInitArray != nil || cellInitArray.count > 0) {
            self.cellDatas = [NSArray arrayWithArray:cellInitArray];
        }
        
        [cellInitArray removeAllObjects];
        cellInitArray = nil;
    }
    
    return self;
}

- (CGSize)getCellSizeAtIndexPath:(NSIndexPath *)indexPath collectionViewSize:(CGSize)collectionViewSize {
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

- (NSInteger)getItemNumber {
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

- (void)setCellStateAtIndexPath:(NSIndexPath *)indexPath state:(NSInteger)state {
    if ([self isNilOrEmpty] || [self isOutBoundIndex:indexPath.item]) {
        return;
    }
    
    self.cellDatas[indexPath.item].state = state;
}

- (void)setCellFullscreenImageAtIndexPath:(NSIndexPath *)indexPath fullscreenImage:(UIImage *)fullscreenImage {
    if ([self isNilOrEmpty] || [self isOutBoundIndex:indexPath.item]) {
        return;
    }
    
    self.cellDatas[indexPath.item].fullscreenImage = fullscreenImage;
}

- (void)setCellCroppedImageAtIndexPath:(NSIndexPath *)indexPath croppedImage:(UIImage *)croppedImage {
    if ([self isNilOrEmpty] || [self isOutBoundIndex:indexPath.item]) {
        return;
    }
    
    self.cellDatas[indexPath.item].croppedImage = croppedImage;
}

- (NSInteger)getCellStateAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNilOrEmpty] || [self isOutBoundIndex:indexPath.item]) {
        return NSNotFound;
    }
    
    return self.cellDatas[indexPath.item].state;
}

- (UIImage *)getCellFullscreenImageAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNilOrEmpty] || [self isOutBoundIndex:indexPath.item]) {
        return nil;
    }
    
    return self.cellDatas[indexPath.item].fullscreenImage;
}

- (UIImage *)getCellCroppedImageAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNilOrEmpty] || [self isOutBoundIndex:indexPath.item]) {
        return nil;
    }
    
    return self.cellDatas[indexPath.item].croppedImage;
}

- (void)clearCellDataAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNilOrEmpty] || [self isOutBoundIndex:indexPath.item]) {
        return;
    }
    
    PhotoEditorFrameCellData *data = self.cellDatas[indexPath.item];
    data.state = CellStateNone;
    data.fullscreenImage = nil;
    data.croppedImage = nil;
}

- (BOOL)isNilOrEmpty {
    if (self.cellDatas == nil || self.cellDatas.count == 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isOutBoundIndex:(NSInteger)index {
    if ([self isNilOrEmpty]) {
        return YES;
    }
    
    if (self.cellDatas.count <= index) {
        return YES;
    }
    
    return NO;
}

@end
