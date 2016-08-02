//
//  PhotoFrameSelectViewCell.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 15..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameSelectViewCell.h"

@implementation PhotoFrameSelectViewCell

- (void)changeFrameImage {
    if (self.isOwnSelected) {
        //본인이 선택한 상태에서 상대방도 선택했다면, Green Color로 변경
        if (self.isConnectedPeerSelected) {
            [self.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PhotoFrame%d_green", (int)self.cellIndex]]];
        //본인이 선택한 상태에서 상대방은 선택하지 않았다면, Blue Color로 변경
        } else {
            [self.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PhotoFrame%d_blue", (int)self.cellIndex]]];
        }
    } else {
        //본인이 선택하지 않은 상태에서 상대방이 선택했다면, Orange Color로 변경
        if (self.isConnectedPeerSelected) {
            [self.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PhotoFrame%d_orange", (int)self.cellIndex]]];
        //본인이 선택하지 않은 상태에서 상대방도 선택하지 않았다면, White Color로 변경
        } else {
            [self.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PhotoFrame%d", (int)self.cellIndex]]];
        }
    }
}

@end
