//
//  CanvasPathObject.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 8..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "CanvasPathObject.h"

@implementation CanvasPathObject

- (instancetype)initWithPath:(UIBezierPath *)path color:(UIColor *)color width:(NSInteger)width {
    self = [super init];
    
    if (self) {
        self.path = [path copy];
        self.color = [color copy];
        self.width = width;
    }
    
    return self;
}

@end
