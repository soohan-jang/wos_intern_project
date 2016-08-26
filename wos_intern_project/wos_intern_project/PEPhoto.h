//
//  PhotoData.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PEPhoto : NSObject

@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *croppedImage;
@property (nonatomic, assign) NSInteger filterType;

@end
