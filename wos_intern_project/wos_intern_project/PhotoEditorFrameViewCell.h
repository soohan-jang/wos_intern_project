//
//  PhotoEditorViewCell.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoEditorFrameViewCell: UICollectionViewCell

@property (nonatomic, strong) NSArray *imageViewArray;

- (void)setUI:(NSUInteger) frameIndex;

@end
