//
//  PhotoFrameSelectViewCell.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 15..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FRAME_STATE_NONE    0
#define FRAME_STATE_BLUE    1
#define FRAME_STATE_ORANGE  2
#define FRAME_STATE_GREEN   3

@interface PhotoFrameSelectViewCell : UICollectionViewCell

@property (nonatomic) NSUInteger *state;
@property (nonatomic, strong) IBOutlet UIImageView *frameImageView;

- (void)setImageWithIndex:(NSUInteger) index State:(NSUInteger) state;

@end
