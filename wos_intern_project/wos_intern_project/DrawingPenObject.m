//
//  DrawingPenObject.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DrawingPenObject.h"

@interface DrawingPenObject ()

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGColorRef color;

@end

@implementation DrawingPenObject

- (instancetype)initWithPath:(UIBezierPath *)path withWidth:(CGFloat)width withColor:(CGColorRef)color {
    self = [super init];
    
    if (self) {
        self.path = path.copy;
        self.width = width;
        self.color = color;
    }
    
    return self;
}

- (void)drawInCanvasView:(UIView *)canvasView {
    if (canvasView == nil) {
        return;
    }
    
    
}

- (void)containsPoint:(CGPoint)point {
    
}

- (void)moveObject:(CGPoint)movePoint {
    
}

- (void)resizeObject:(CGRect)resizeRect {
    
}

- (void)rotateObject:(CGFloat)rotateAngle {

}

@end
