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
        case Transparent:
            alpha = 0.f;
            break;
        case Transparent2f:
            alpha = 0.2f;
            break;
        case Black:
            red = green = blue = 0.f;
            break;
        case White:
            red = green = blue = 255.f;
            break;
        case DarkGray:
            red = green = blue = 51.f;
            break;
        case Red:
            red = 231.f;
            green = 76.f;
            blue = 60.f;
            break;
        case Green:
            red = 39.f;
            green = 174.f;
            blue = 96.f;
            break;
        case Blue:
            red = 52.f;
            green = 152.f;
            blue = 219.f;
            break;
        case Yellow:
            red = 241.f;
            green = 196.f;
            blue = 15.f;
            break;
        case Orange:
            red = 45.f;
            green = 140.f;
            blue = 213.f;
            alpha = 1.f;
            break;
    }
    
    return [UIColor colorWithRed:red / 255.f
                           green:green / 255.f
                            blue:blue / 255.f
                           alpha:alpha];
}

@end