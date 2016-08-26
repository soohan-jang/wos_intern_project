//
//  PhotoCollectionViewCell.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell

/**
 * @brief 샐을 초기화한다.
 */
- (void)initializeCell;

/**
 * @brief 사진 액자에 스트로크 처리된 테두리를 표시한다.
 */
- (void)setStrokeBorder;

/**
 * @brief 사진 액자에 그려진 테두리를 제거한다.
 */
- (void)removeStrokeBorder;

/**
 * @brief 사진 액자에 이미지를 설정한다.
 */
- (void)setImage:(UIImage *)image;

/**
 @brief 현재 셀의 상태를 표시하기 위한 UI이다. 상태는 None, Editing, Uploading, Downloading으로 구분된다. 
 */
- (void)setLoadingImage:(NSInteger)loadingState;

@end
