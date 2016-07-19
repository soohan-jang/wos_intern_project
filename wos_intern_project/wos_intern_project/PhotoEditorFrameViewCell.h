//
//  PhotoEditorViewCell.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoEditorFrameViewCell: UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;

/**
 사진 액자에 스트로크 처리된 테두리를 표시한다.
 */
- (void)setStrokeBorder;

/**
 사진 액자에 스트로크 처리된 테두리를 제거한다.
 */
- (void)removeStrokeBorder;
@end
