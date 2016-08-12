//
//  PhotoFrameSelectCellManager.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoFrameSelectCellData.h"

@protocol PhotoFrameSelectCellManagerDelegate;

@interface PhotoFrameSelectCellManager : NSObject

@property (weak, nonatomic) id<PhotoFrameSelectCellManagerDelegate> delegate;

@property (nonatomic, strong, readonly) NSIndexPath *ownSelectedIndexPath;
@property (nonatomic, strong, readonly) NSIndexPath *otherSelectedIndexPath;

/**
 액자종류에 따라 표시될 사진 액자의 수를 반환한다.
 */
- (NSInteger)getItemNumber;

/**
 인덱스에 위치한 사진 액자의 크기를 반환한다.
 */
- (CGSize)getCellSize:(CGSize)collectionViewSize;

- (UIEdgeInsets)getEdgeInsetsOfSection:(CGSize)collectionViewSize;

- (void)setSelectedCellAtIndexPath:(NSIndexPath *)indexPath isOwnSelection:(BOOL)isOwnSelection;

/**
 인덱스에 위치한 사진 액자의 이미지를 가져온다.
 */
- (UIImage *)getCellImageAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isEqualBothSelectedIndexPath;

@end

@protocol PhotoFrameSelectCellManagerDelegate <NSObject>
@required
- (void)didUpdateCellStateWithDoneActivate:(BOOL)activate;
- (void)didRequestConfirmCellWithIndexPath:(NSIndexPath *)indexPath;

@end