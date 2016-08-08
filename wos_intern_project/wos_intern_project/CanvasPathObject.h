//
//  CanvasPathObject.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 8..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanvasPathObject : NSObject

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) NSInteger width;

- (instancetype)initWithPath:(UIBezierPath *)path color:(UIColor *)color width:(NSInteger)width;

@end
