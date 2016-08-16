//
//  ColorUtility.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIColor.h>

NS_ENUM(NSInteger, ColorName) {
    Transparent     = 0,
    Transparent2f   = 1,
    Black           = 2,
    White           = 3,
    DarkGray        = 4,
    Red             = 5,
    Green           = 6,
    Blue            = 7,
    Yellow          = 8,
    Orange          = 9,
    DeepOrange      = 10
};

@interface ColorUtility : NSObject

+ (UIColor *)colorWithName:(NSInteger)colorName;

@end
