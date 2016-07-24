//
//  PhotoEditorCollectionView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 18..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorCollectionView.h"

#define DEFAULT_MARGIN  5

NSInteger const STATE_NONE          = 0;
NSInteger const STATE_UPLOADING     = 1;
NSInteger const STATE_DOWNLOADING   = 2;


@implementation PhotoEditorCollectionView

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

- (NSInteger)numberOfItems {
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

- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    PhotoEditorFrameViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"photoFrameCell" forIndexPath:itemIndexPath];
    return cell;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self buildEachPhotoFrameSize:itemIndexPath.item];
}

- (UIEdgeInsets)insetForCollectionView {
    return UIEdgeInsetsMake(DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f);
}

- (void)setLoadingStateWithItemIndex:(NSInteger)item State:(NSInteger)state {
    if (self.loadingStateDictionary == nil) {
        self.loadingStateDictionary = [@{@(item): @(state)} mutableCopy];
    }
    else {
        [self.loadingStateDictionary setObject:@(state) forKey:@(item)];
    }
}

- (NSInteger)getLoadingStateWithItemIndex:(NSInteger)item {
    if (self.loadingStateDictionary[@(item)] == nil) {
        return STATE_NONE;
    }
    else {
        return [self.loadingStateDictionary[@(item)] integerValue];
    }
}

- (void)putImageWithItemIndex:(NSInteger)item Image:(UIImage *)image {
    if (self.imageDictionary == nil) {
        self.imageDictionary = [@{@(item): image} mutableCopy];
    }
    else {
        [self.imageDictionary setObject:image forKey:@(item)];
    }
}

- (UIImage *)getImageWithItemIndex:(NSInteger)item {
    return (UIImage *)self.imageDictionary[@(item)];
}

- (void)delImageWithItemIndex:(NSInteger)item {
    [self.imageDictionary removeObjectForKey:@(item)];
}

- (BOOL)hasImageWithItemIndex:(NSInteger)item {
    if (self.imageDictionary[@(item)] == nil) {
        return NO;
    }
    else {
        return YES;
    }
}

@end
