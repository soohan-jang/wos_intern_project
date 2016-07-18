//
//  PhotoEditorCollectionView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 18..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoEditorFrameViewCell.h"

@interface PhotoEditorCollectionView : UICollectionView

@property (nonatomic) NSUInteger frameIndex;

- (NSInteger)numberOfItems;
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)insetForCollectionView;

@end
