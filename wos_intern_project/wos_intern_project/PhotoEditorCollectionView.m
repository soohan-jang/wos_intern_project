//
//  PhotoEditorCollectionView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 18..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorCollectionView.h"

#define DEFAULT_MARGIN  5

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
    if (self.frameIndex == 0) {
        return CGSizeMake(containerWidth - DEFAULT_MARGIN, containerHeight - DEFAULT_MARGIN);
    }
    else if (self.frameIndex == 1) {
        return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
    }
    else if (self.frameIndex == 2) {
        return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, containerHeight - DEFAULT_MARGIN);
    }
    else if (self.frameIndex == 3) {
        return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
    }
    else if (self.frameIndex == 4) {
        if (itemIndex == 0) {
            return CGSizeMake(containerWidth - DEFAULT_MARGIN, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
        else {
            return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
    }
    else if (self.frameIndex == 5) {
        if (itemIndex == 1) {
            return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, containerHeight - DEFAULT_MARGIN);
        }
        else {
            return CGSizeMake((containerWidth - DEFAULT_MARGIN) / 2.0f, (containerHeight - (DEFAULT_MARGIN / 2.0f * 3.0f)) / 2.0f);
        }
    }
    else if (self.frameIndex == 6) {
        
    }
    else if (self.frameIndex == 7) {
        
    }
    else if (self.frameIndex == 8) {
        
    }
    else if (self.frameIndex == 9) {
        
    }
    else if (self.frameIndex == 10) {
        
    }
    else if (self.frameIndex == 11) {
        
    }
    else {
        cellWidth = cellHeight = 0;
    }
    
    return CGSizeMake(cellWidth, cellHeight);
}

- (NSInteger)numberOfItems {
    switch (self.frameIndex) {
        case 0:
            return 1;
        case 1:
        case 2:
            return 2;
        case 4:
        case 5:
        case 6:
        case 7:
            return 3;
        case 3:
        case 8:
        case 9:
        case 10:
        case 11:
            return 4;
        default:
            return 1;
    }
}

- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    PhotoEditorFrameViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"photoFrameCell" forIndexPath:itemIndexPath];
    [cell setStrokeBorder];
    return cell;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self buildEachPhotoFrameSize:itemIndexPath.item];
}

- (UIEdgeInsets)insetForCollectionView {
    return UIEdgeInsetsMake(DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f, DEFAULT_MARGIN / 2.0f);
}

@end
