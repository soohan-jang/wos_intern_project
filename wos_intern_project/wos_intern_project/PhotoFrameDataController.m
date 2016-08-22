//
//  PhotoFrameDataController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameDataController.h"
#import "SelectPhotoFrameViewCell.h"
#import "ConnectionManager.h"
#import "ImageUtility.h"

NSInteger const NumberOfPhotoFrameCells = 12;

@interface PhotoFrameDataController () <UICollectionViewDataSource, ConnectionManagerPhotoFrameDataDelegate>

@property (strong, atomic) NSMutableArray<PhotoFrameData *> *cellDatas;

@end

@implementation PhotoFrameDataController

- (instancetype)initWithCollectionViewSize:(CGSize)size {
    self = [super init];
    
    if (self) {
        [ConnectionManager sharedInstance].photoFrameDataDelegate = self;
        self.cellDatas = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < NumberOfPhotoFrameCells; i++) {
            [self.cellDatas addObject:[[PhotoFrameData alloc] initWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
    }
    
    return self;
}

- (void)clearController {
    [self.cellDatas removeAllObjects];
    self.cellDatas = nil;
    
    _ownSelectedIndexPath = nil;
    _otherSelectedIndexPath = nil;
    self.delegate = nil;
}

//isOwnSelection으로 내가 발생시킨 이벤트인지, 상대방에 발생시킨 이벤트인지 파악한다.
- (void)setSelectedCellAtIndexPath:(NSIndexPath *)indexPath isOwnSelection:(BOOL)isOwnSelection {
    if (!indexPath)
        return;
    
    PhotoFrameData *cellData;
    NSIndexPath *prevIndexPath;
    
    if (isOwnSelection) {
        prevIndexPath = self.ownSelectedIndexPath;
    } else {
        prevIndexPath = self.otherSelectedIndexPath;
    }
    
    if (prevIndexPath) {
        if (prevIndexPath.item == indexPath.item) {
            //기존에 선택된 것과 같으면, 선택 취소로 간주한다.
            cellData = self.cellDatas[indexPath.item];
            [cellData updateCellState:NO isOwnSelection:isOwnSelection];
            
            prevIndexPath = nil;
        } else {
            //다르면, 기존의 것을 선택해제하고 현재의 것을 선택한다.
            cellData = self.cellDatas[prevIndexPath.item];
            [cellData updateCellState:NO isOwnSelection:isOwnSelection];
            
            cellData = self.cellDatas[indexPath.item];
            [cellData updateCellState:YES isOwnSelection:isOwnSelection];
            
            prevIndexPath = indexPath;
        }
    } else {
        //기존에 선택된 것이 없으므로, 현재 인덱스패스에 대해서만 선택처리한다.
        cellData = self.cellDatas[indexPath.item];
        [cellData updateCellState:YES isOwnSelection:isOwnSelection];
        
        prevIndexPath = indexPath;
    }
    
    if (isOwnSelection) {
        _ownSelectedIndexPath = prevIndexPath;
    } else {
        _otherSelectedIndexPath = prevIndexPath;
    }
    
    [self.delegate didUpdateCellStateWithDoneActivate:[cellData isBothSelected]];
}

- (CGSize)sizeOfCell:(CGSize)size {
    CGFloat cellBetweenSpace = 20.0f * 2.0f;
    CGFloat cellWidth = (size.width - cellBetweenSpace) / 3.0f;
    
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)edgeInsets:(CGSize)size {
    CGFloat cellBetweenSpace = 20.0f * 2.0f;
    //셀의 높이는 너비와 같다. 셀은 가로로 4개가 배치되므로, 셀 너비값의 4배가 각 셀의 높이를 합한 값이 된다.
    CGFloat cellsHeight = ((size.width - cellBetweenSpace) / 3.0f) * 4.0f;
    //셀 간의 간격은 3곳이 생기며, 라인 간 간격은 20으로 정의되어 있다.
    CGFloat cellsBetweenSpace = 20.0f * 3.0f;
    //남은 공간의 절반을 상단의 inset으로 지정하면, 수직으로 중간에 정렬시킬 수 있다.
    CGFloat topInset = (size.height - cellsHeight - cellsBetweenSpace) / 2.0f;
    
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}

- (UIImage *)cellImageAtIndexPath:(NSIndexPath *)indexPath {
    return [ImageUtility coloredImageNamed:[ImageUtility photoFrameImageWithIndex:indexPath.item]
                                     color:_cellDatas[indexPath.item].stateColor];
}

- (BOOL)isEqualBothSelectedIndexPath {
    if (!_ownSelectedIndexPath || !_otherSelectedIndexPath) {
        return NO;
    }
    
    if (_ownSelectedIndexPath.item == _otherSelectedIndexPath.item) {
        return YES;
    }
    
    return NO;
}


#pragma mark - CollectionViewController DataDelegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NumberOfPhotoFrameCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectPhotoFrameViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SelectPhotoFrameViewCell class]) forIndexPath:indexPath];
    cell.frameImageView.image = [self cellImageAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - ConnectionManager Delegate Methods.

- (void)receivedPhotoFrameSelected:(NSIndexPath *)indexPath {
    if (!indexPath)
        return;
    
    [self setSelectedCellAtIndexPath:indexPath isOwnSelection:NO];
    
    PhotoFrameData *cellData = self.cellDatas[indexPath.item];
    [self.delegate didUpdateCellStateWithDoneActivate:[cellData isBothSelected]];
}

@end
