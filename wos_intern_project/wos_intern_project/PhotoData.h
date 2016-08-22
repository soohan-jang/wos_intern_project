//
//  PhotoData.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoData : NSObject

@property (atomic, assign) NSInteger state;
@property (atomic, strong) UIImage *fullscreenImage;
@property (atomic, strong) UIImage *croppedImage;

@end
