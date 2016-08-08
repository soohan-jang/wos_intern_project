//
//  PhotoFrameCellManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 28..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameCellManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

NSInteger const SectionNumber = 1;
NSInteger const DefaultMargin = 5;

@interface PhotoFrameCellManager ()

/**
 몇 번째 사진 액자를 골랐는지에 대한 프로퍼티이다. 사진 액자는 1번부터 12번까지 있다.
 */
@property (nonatomic, assign) NSInteger photoFrameNumber;
@property (atomic, strong) NSMutableDictionary *cellFullscreenImages;
@property (atomic, strong) NSMutableDictionary *cellCroppedImages;
@property (atomic, strong) NSMutableDictionary *cellStates;

@end

@implementation PhotoFrameCellManager

- (instancetype)initWithFrameNumber:(NSInteger)frameNumber {
    self = [super init];
    
    if (self) {
        self.photoFrameNumber = frameNumber;
    }
    
    return self;
}

- (CGSize)getCellSizeWithIndex:(NSInteger)cellIndex withCollectionViewSize:(CGSize)collectionViewSize {
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
    if (self.photoFrameNumber == 0) {
        return CGSizeMake(containerWidth - DefaultMargin, containerHeight - DefaultMargin);
    } else if (self.photoFrameNumber == 1) {
        return CGSizeMake((containerWidth - DefaultMargin) / 2.0f, containerHeight - DefaultMargin);
    } else if (self.photoFrameNumber == 2) {
        return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
    } else if (self.photoFrameNumber == 3) {
        return CGSizeMake((containerWidth - DefaultMargin) / 3.0f, containerHeight - DefaultMargin);
    } else if (self.photoFrameNumber == 4) {
        return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 3.0f);
    } else if (self.photoFrameNumber == 5) {
        return CGSizeMake((containerWidth - DefaultMargin) / 4.0f, containerHeight - DefaultMargin);
    } else if (self.photoFrameNumber == 6) {
        return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 4.0f);
    } else if (self.photoFrameNumber == 7) {
        return CGSizeMake((containerWidth - DefaultMargin) / 2.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
    } else if (self.photoFrameNumber == 8) {
        if (cellIndex == 0) {
            return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
        } else {
            return CGSizeMake((containerWidth - DefaultMargin) / 2.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
        }
    } else if (self.photoFrameNumber == 9) {
        if (cellIndex == 2) {
            return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
        } else {
            return CGSizeMake((containerWidth - DefaultMargin) / 2.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
        }
    } else if (self.photoFrameNumber == 10) {
        if (cellIndex == 0) {
            return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
        } else {
            return CGSizeMake((containerWidth - DefaultMargin * 1.01f) / 3.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
        }
    } else if (self.photoFrameNumber == 11) {
        if (cellIndex == 3) {
            return CGSizeMake(containerWidth - DefaultMargin, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
        } else {
            return CGSizeMake((containerWidth - DefaultMargin * 1.01f) / 3.0f, (containerHeight - (DefaultMargin / 2.0f * 3.0f)) / 2.0f);
        }
    } else {
        cellWidth = cellHeight = 0;
    }
    
    return CGSizeMake(cellWidth, cellHeight);
}

- (NSInteger)getSectionNumber {
    return SectionNumber;
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

- (void)setCellStateAtIndex:(NSInteger)index withState:(NSInteger)state {
    if (self.cellStates == nil) {
        self.cellStates = [@{@(index): @(state)} mutableCopy];
    } else {
        self.cellStates[@(index)] = @(state);
    }
}

- (void)setCellFullscreenImageAtIndex:(NSInteger)index withFullscreenImage:(UIImage *)fullscreenImage {
    if (self.cellFullscreenImages == nil) {
        self.cellFullscreenImages = [@{@(index): fullscreenImage} mutableCopy];
    } else {
        self.cellFullscreenImages[@(index)] = fullscreenImage;
    }
}

- (void)setCellCroppedImageAtIndex:(NSInteger)index withCroppedImage:(UIImage *)croppedImage {
    if (self.cellCroppedImages == nil) {
        self.cellCroppedImages = [@{@(index): croppedImage} mutableCopy];
    } else {
        self.cellCroppedImages[@(index)] = croppedImage;
    }
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

- (void)clearCellDataAtIndex:(NSInteger)index {
    self.cellStates[@(index)] = nil;
    self.cellFullscreenImages[@(index)] = nil;
    self.cellCroppedImages[@(index)] = nil;
}

@end
