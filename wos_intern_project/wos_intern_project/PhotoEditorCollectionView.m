//
//  PhotoEditorCollectionView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 18..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorCollectionView.h"

@implementation PhotoEditorCollectionView

- (CGSize)buildEachPhotoFrameSize {
    CGFloat containerWidth = self.bounds.size.width;
    CGFloat containerHeight = self.bounds.size.height;
    CGFloat cellWidth;
    CGFloat cellHeight;
    
    if (self.frameIndex == 0) {
        
    }
    else if (self.frameIndex == 1) {
        
    }
    else if (self.frameIndex == 2) {
        
    }
    else if (self.frameIndex == 3) {
        
    }
    else if (self.frameIndex == 4) {
        
    }
    else if (self.frameIndex == 5) {
        
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

- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoEditorFrameViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"photoFrameCell" forIndexPath:indexPath];
    return cell;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self buildEachPhotoFrameSize:indexPath.item];
}

- (UIEdgeInsets)insetForCollectionView {
    //액자는 정사각형 형태이므로, 액자의 너비와 높이는 같다.
    //즉, 액자의 높이에서 너비를 뺀 후에 이를 2로 나누어 상단에 Inset으로 지정하면 가운데 정렬을 할 수 있다.
    CGFloat topInset = (self.bounds.size.height - self.bounds.size.width) / 2;
    
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}

@end
