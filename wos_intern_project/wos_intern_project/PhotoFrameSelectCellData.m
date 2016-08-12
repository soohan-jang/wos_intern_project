//
//  PhotoFrameSelectCellData.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameSelectCellData.h"
#import "CommonConstants.h"
#import "ImageUtility.h"

@implementation PhotoFrameSelectCellData

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath {
    self = [super init];
    
    if (self) {
        self.indexPath = indexPath;
        self.ownSelected = NO;
        self.otherSelected = NO;
        [self updateCellState];
    }
    
    return self;
}

- (void)updateCellState:(BOOL)state isOwnSelection:(BOOL)isOwnSelection {
    if (isOwnSelection) {
        self.ownSelected = state;
    } else {
        self.otherSelected = state;
    }
    
    [self updateCellState];
}

- (void)updateCellState {
    if (self.ownSelected && self.otherSelected) {
        self.image = [UIImage imageNamed:[ImageUtility generatePhotoFrameImageWithIndex:self.indexPath.item
                                                                                postfix:PostFixImagePhotoFrameGreen]];
        return;
    }
    
    if (self.ownSelected && !self.otherSelected) {
        self.image = [UIImage imageNamed:[ImageUtility generatePhotoFrameImageWithIndex:self.indexPath.item
                                                                                postfix:PostFixImagePhotoFrameBlue]];
        return;
    }
    
    if (!self.ownSelected && self.otherSelected) {
        self.image = [UIImage imageNamed:[ImageUtility generatePhotoFrameImageWithIndex:self.indexPath.item
                                                                                postfix:PostFixImagePhotoFrameOrange]];
        return;
    }
    
    if (!self.ownSelected && !self.otherSelected) {
        self.image = [UIImage imageNamed:[ImageUtility generatePhotoFrameImageWithIndex:self.indexPath.item]];
        return;
    }
}

@end