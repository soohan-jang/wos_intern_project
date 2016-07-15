//
//  PhotoFrameViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 14..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFrameViewController : UIViewController

@property (nonatomic, strong) NSArray *imageViewArray;

- (void)setupUI:(NSUInteger)frameNumber;

@end
