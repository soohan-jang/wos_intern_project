//
//  PhotoEditorViewCell.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const NOTIFICATION_SELECTED_CELL;
extern NSString *const KEY_SELECTED_CELL_INDEXPATH;
extern NSString *const KEY_SELECTED_CELL_CENTER_X;
extern NSString *const KEY_SELECTED_CELL_CENTER_Y;

@interface PhotoEditorFrameViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *photoFrameView;
@property (weak, nonatomic) IBOutlet UIImageView *photoLoadingView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (strong, nonatomic) NSIndexPath *indexPath;

/**
 사진 액자에 스트로크 처리된 테두리를 표시한다.
 */
- (void)setStrokeBorder;

/**
 탭 이벤트를 인식하고, 처리할 이벤트핸들러를 설정한다.
 */
- (void)setTapGestureRecognizer;

/**
 사진 액자에 이미지를 설정한다.
 */
- (void)setImage:(UIImage *)image;

/**
 현재 셀의 상태를 표시하기 위한 UI이다. 상태는 NONE, UPLOADING, DOWNLOADING으로 구분된다.
 또한 UPLOADING/DOWNLOADING 시 해당 사진 액자에서 이벤트가 발생하는 것을 방지한다.
 */
- (void)setLoadingImage:(NSInteger)loadingState;

@end
