//
//  PhotoFrameSelectCellData.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameSelectCellData.h"
#import "CommonConstants.h"
#import "ColorUtility.h"

@interface PhotoFrameSelectCellData ()

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL ownSelected;
@property (nonatomic, assign) BOOL otherSelected;

@end

@implementation PhotoFrameSelectCellData

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath {
    self = [super init];
    
    if (self) {
        _indexPath = indexPath;
        _ownSelected = NO;
        _otherSelected = NO;
        _stateColor = [ColorUtility colorWithName:White];
    }
    
    return self;
}

- (void)updateCellState:(BOOL)state isOwnSelection:(BOOL)isOwnSelection {
    if (isOwnSelection) {
        _ownSelected = state;
    } else {
        _otherSelected = state;
    }
    
    if (_ownSelected && _otherSelected) {
        _stateColor = [ColorUtility colorWithName:Green];
    } else if (_ownSelected && !_otherSelected) {
        _stateColor = [ColorUtility colorWithName:Blue];
    } else if (!_ownSelected && _otherSelected) {
        _stateColor = [ColorUtility colorWithName:Orange];
    } else {
        _stateColor = [ColorUtility colorWithName:White];
    }
}

- (BOOL)isBothSelected {
    if (_ownSelected && _otherSelected) {
        return YES;
    }
    
    return NO;
}

@end