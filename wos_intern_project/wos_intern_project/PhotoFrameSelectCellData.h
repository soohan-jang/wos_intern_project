//
//  PhotoFrameSelectCellData.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIImage.h>

@interface PhotoFrameSelectCellData : NSObject

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL ownSelected;
@property (nonatomic, assign) BOOL otherSelected;

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath;
- (void)updateCellState:(BOOL)state isOwnSelection:(BOOL)isOwnSelection;

@end