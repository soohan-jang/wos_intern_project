//
//  ColorUtility.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIColor.h>

NS_ENUM(NSInteger, ColorName) {
    ColorNameTransparent     = 0,
    ColorNameTransparent2f,
    ColorNameTransparent4f,
    ColorNameBlack,
    ColorNameWhite,
    ColorNameDarkGray,
    ColorNameRed,
    ColorNameGreen,
    ColorNameBlue,
    ColorNameYellow,
    ColorNameOrange,
    ColorNameDeepOrange
};

@interface ColorUtility : NSObject

+ (UIColor *)colorWithName:(NSInteger)colorName;

@end
