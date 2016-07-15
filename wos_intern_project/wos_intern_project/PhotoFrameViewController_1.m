//
//  PhotoFrameViewController_1.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 15..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameViewController_1.h"

@implementation PhotoFrameViewController_1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageViewArray = [NSArray arrayWithArray:[[self.view subviews][0] subviews]];
    
    NSLog(@"image view count : %d", self.imageViewArray.count);
}

@end
