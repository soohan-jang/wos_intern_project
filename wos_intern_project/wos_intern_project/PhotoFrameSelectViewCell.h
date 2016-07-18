//
//  PhotoFrameSelectViewCell.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 15..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFrameSelectViewCell : UICollectionViewCell

@property (nonatomic) NSUInteger cellIndex;
@property (nonatomic) BOOL isOwnSelected;
@property (nonatomic) BOOL isConnectedPeerSelected;
@property (nonatomic, strong) IBOutlet UIImageView *frameImageView;

/**
 상태값에 따라 액자 이미지를 변경한다. 
 */
- (void)changeFrameImage;

@end
