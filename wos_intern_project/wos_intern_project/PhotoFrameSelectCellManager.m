//
//  PhotoFrameSelectCellManager.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameSelectCellManager.h"
#import "ConnectionManager.h"

NSInteger const PhotoFrameCellCount = 12;

@interface PhotoFrameSelectCellManager () <ConnectionManagerPhotoFrameDataDelegate>

@property (strong, nonatomic) NSMutableArray<PhotoFrameSelectCellData *> *cellDatas;

@end

@implementation PhotoFrameSelectCellManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [ConnectionManager sharedInstance].photoFrameDataDelegate = self;
        self.cellDatas = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < PhotoFrameCellCount; i++) {
            [self.cellDatas addObject:[[PhotoFrameSelectCellData alloc] initWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
    }
    
    return self;
}

- (NSInteger)getItemNumber {
    return PhotoFrameCellCount;
}

- (CGSize)getCellSize:(CGSize)collectionViewSize {
    //한 라인에 셀 3개를 배치한다. 따라서 셀 간의 간격은 2곳이 생긴다.
    CGFloat cellBetweenSpace = 20.0f * 2.0f;
    CGFloat cellWidth = (collectionViewSize.width - cellBetweenSpace) / 3.0f;
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)getEdgeInsetsOfSection:(CGSize)collectionViewSize {
    //셀의 높이는 너비와 같다. 셀은 가로로 4개가 배치되므로, 셀 너비값의 4배가 각 셀의 높이를 합한 값이 된다.
    CGFloat cellBetweenSpace = 20.0f * 2.0f;
    CGFloat cellsHeight = ((collectionViewSize.width - cellBetweenSpace) / 3.0f) * 4.0f;
    //셀 간의 간격은 3곳이 생기며, 라인 간 간격은 20으로 정의되어 있다.
    CGFloat cellsBetweenSpace = 20.0f * 3.0f;
    //남은 공간의 절반을 상단의 inset으로 지정하면, 수직으로 중간에 정렬시킬 수 있다.
    CGFloat topInset = (collectionViewSize.height - cellsHeight - cellsBetweenSpace) / 2.0f;
    
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}

//isOwnSelection으로 내가 발생시킨 이벤트인지, 상대방에 발생시킨 이벤트인지 파악한다.
- (void)setSelectedCellAtIndexPath:(NSIndexPath *)indexPath isOwnSelection:(BOOL)isOwnSelection {
    if (!indexPath)
        return;
    
    PhotoFrameSelectCellData *cellData;
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
    
    [self.delegate didUpdateCellStateWithDoneActivate:(cellData.ownSelected && cellData.otherSelected)];
}

- (UIImage *)getCellImageAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellDatas[indexPath.item].image;
}

- (BOOL)isEqualBothSelectedIndexPath {
    if (self.ownSelectedIndexPath.item == self.otherSelectedIndexPath.item)
        return YES;
    
    return NO;
}


#pragma mark - ConnectionManager Delegate Methods.

- (void)receivedPhotoFrameSelected:(NSIndexPath *)indexPath {
    if (!indexPath)
        return;
    
    [self setSelectedCellAtIndexPath:indexPath isOwnSelection:NO];
    
    PhotoFrameSelectCellData *cellData = self.cellDatas[indexPath.item];
    [self.delegate didUpdateCellStateWithDoneActivate:(cellData.ownSelected && cellData.otherSelected)];
}

- (void)receivedPhotoFrameRequestConfirm:(NSIndexPath *)confirmIndexPath {
    if (!confirmIndexPath)
        return;
    
    //승인 Alert 띄우는 부분은 ViewController가 담당하게 넘기고,
    [self.delegate didRequestConfirmCellWithIndexPath:confirmIndexPath];
    
    //승인 요청받은 IndexPath와 내가 선택한 IndexPath가 일치하는지 확인하고,
    if (self.ownSelectedIndexPath.item != confirmIndexPath.item) {
        //일치하지 않으면 승인 요청받은 IndexPath를 내가 선택한 IndexPath에 할당한다.
        [self setSelectedCellAtIndexPath:confirmIndexPath isOwnSelection:YES];
        //현재 승인 요청 중이므로, Done 버튼은 비활성화시킨다.
        [self.delegate didUpdateCellStateWithDoneActivate:NO];
    }
}

@end
