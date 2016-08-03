//
//  PhotoFrameSelectViewCell.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 15..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFrameSelectViewCell : UICollectionViewCell

@property (assign, nonatomic) NSUInteger cellIndex;
@property (assign, nonatomic) BOOL isOwnSelected;
@property (assign, nonatomic) BOOL isConnectedPeerSelected;
@property (weak, nonatomic) IBOutlet UIImageView *frameImageView;

/**
 상태값에 따라 액자 이미지를 변경한다. 
 */
- (void)changeFrameImage;

@end
