//
//  PhotoFrameSelectViewCell.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 15..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameSelectViewCell.h"

@implementation PhotoFrameSelectViewCell

- (void)setImageWithIndex:(NSUInteger) index State:(NSUInteger) state {
    NSString *imageName;
    
    switch (state) {
        case FRAME_STATE_NONE:
            imageName = [NSString stringWithFormat:@"PhotoFrame%ld", index];
            break;
        case FRAME_STATE_BLUE:
            imageName = [NSString stringWithFormat:@"PhotoFrame%ld_blue", index];
            break;
        case FRAME_STATE_ORANGE:
            imageName = [NSString stringWithFormat:@"PhotoFrame%ld_orange", index];
            break;
        case FRAME_STATE_GREEN:
            imageName = [NSString stringWithFormat:@"PhotoFrame%ld_green", index];
            break;
        default:
            imageName = [NSString stringWithFormat:@"PhotoFrame%ld", index];
            break;
    }
    
    [self.frameImageView setImage:[UIImage imageNamed:imageName]];
}

@end
