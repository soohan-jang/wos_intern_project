//
//  ColorUtility.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ColorUtility.h"

@implementation ColorUtility

+ (UIColor *)colorWithName:(NSInteger)colorName {
    CGFloat red = 0.f, green = 0.f, blue = 0.f, alpha = 1.f;
    
    switch (colorName) {
        case ColorNameTransparent:
            alpha = 0.f;
            break;
        case ColorNameTransparent2f:
            alpha = 0.2f;
            break;
        case ColorNameTransparent4f:
            alpha = 0.4f;
            break;
        case ColorNameBlack:
            red = green = blue = 0.f;
            break;
        case ColorNameWhite:
            red = green = blue = 255.f;
            break;
        case ColorNameDarkGray:
            red = green = blue = 51.f;
            break;
        case ColorNameRed:
            red = 231.f;
            green = 76.f;
            blue = 60.f;
            break;
        case ColorNameGreen:
            red = 39.f;
            green = 174.f;
            blue = 96.f;
            break;
        case ColorNameBlue:
            red = 52.f;
            green = 152.f;
            blue = 219.f;
            break;
        case ColorNameYellow:
            red = 241.f;
            green = 196.f;
            blue = 15.f;
            break;
        case ColorNameOrange:
            red = 243.f;
            green = 156.f;
            blue = 18.f;
            alpha = 1.f;
            break;
    }
    
    return [UIColor colorWithRed:red / 255.f
                           green:green / 255.f
                            blue:blue / 255.f
                           alpha:alpha];
}

@end