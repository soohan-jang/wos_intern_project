//
//  PhotoDrawCanvasView.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 6..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawCanvasView.h"

int const DefaultLineWidth = 4;

@interface PhotoDrawCanvasView ()

//이건 따로 뷰 모델로 만들어서 관리하고, PhotoDrawCanvasView도 Controller화 시켜도 될 것 같은데?
@property (nonatomic, strong) NSMutableArray<UIBezierPath *> *pathArray;
@property (nonatomic, strong) NSMutableArray<UIColor *> *pathColorArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *pathWidthArray;

@end

@implementation PhotoDrawCanvasView {
    UIBezierPath *path;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        self.pathArray = [[NSMutableArray alloc] init];
        self.pathColorArray = [[NSMutableArray alloc] init];
        self.pathWidthArray = [[NSMutableArray alloc] init];
        
        self.lineColor = [UIColor blackColor];
        self.lineWidth = DefaultLineWidth;
        
        path = [UIBezierPath bezierPath];
        path.lineWidth = self.lineWidth;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        self.pathArray = [[NSMutableArray alloc] init];
        self.pathColorArray = [[NSMutableArray alloc] init];
        self.pathWidthArray = [[NSMutableArray alloc] init];
        
        path = [UIBezierPath bezierPath];
        path.lineWidth = DefaultLineWidth;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    for (int i = 0; i < self.pathArray.count; i++) {
        UIBezierPath *drawPath = self.pathArray[i];
        
        [self.pathColorArray[i] setStroke];
        [drawPath setLineWidth:self.pathWidthArray[i].floatValue];
        [drawPath stroke];
    }
    
    if (path == nil || path.isEmpty)
        return;
    
    [self.lineColor setStroke];
    [path setLineWidth:self.lineWidth];
    [path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (self.drawMode == ModeDraw) {
        ctr = 0;
        pts[0] = point;
    } else if (self.drawMode == ModeErase) {
        [self removePathLocatedAtPoint:point];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (self.drawMode == ModeErase) {
        [self removePathLocatedAtPoint:point];
    } else if (self.drawMode == ModeDraw) {
        ctr++;
        pts[ctr] = point;
        if (ctr == 4) {
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            
            [path moveToPoint:pts[0]];
            [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            
            [self setNeedsDisplay];
            // replace points and get ready to handle the next segment
            pts[0] = pts[3];
            pts[1] = pts[4];
            ctr = 1;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.drawMode == ModeErase) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self removePathLocatedAtPoint:point];
    } else if (self.drawMode == ModeDraw) {
        if (path == nil || path.isEmpty)
            return;
        
        [self addPath];
        ctr = 0;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


#pragma mark - Add Path in Array

- (void)addPath {
    [self.pathArray addObject:[path copy]];
    [self.pathColorArray addObject:[self.lineColor copy]];
    [self.pathWidthArray addObject:@(self.lineWidth)];
    [path removeAllPoints];
    [self setNeedsDisplay];
}

//지우개 기능 초기버전. 개선의 여지가 많다.
- (void)removePathLocatedAtPoint:(CGPoint)point {
    if (self.pathArray == nil || self.pathArray.count == 0)
        return;
    
    for (int i = (int)self.pathArray.count - 1; i >= 0; i--) {
        CGPathRef pathRef = [self.pathArray[i] CGPath];
        if (!CGPathContainsPoint(pathRef, NULL, point, true))
            continue;
        
        [self.pathArray removeObjectAtIndex:i];
        [self.pathColorArray removeObjectAtIndex:i];
        [self.pathWidthArray removeObjectAtIndex:i];
        [self setNeedsDisplay];
        break;
    }
}


#pragma mark - Calculate Bounds & Get Path Image

- (CGRect)calculatePathBounds {
    if (self.pathArray == nil || self.pathArray.count == 0)
        return CGRectNull;
    
    CGMutablePathRef mutalblePathRef = CGPathCreateMutable();
    for (UIBezierPath *subPath in self.pathArray)
        CGPathAddPath(mutalblePathRef, NULL, [subPath CGPath]);
    
    CGRect bounds = CGPathGetBoundingBox(mutalblePathRef);
    bounds = CGRectMake(bounds.origin.x - 10,
                        bounds.origin.y - 10,
                        bounds.size.width + 20,
                        bounds.size.height + 20);
    
    //각 Path의 Bounds 계산해서, 최소값 최대값 x, y 도출.
    //이후 x - 20, y - 20, w + 40, h + 40으로 bounds capture하여 UIImage Create, return.
    
    CGPathRelease(mutalblePathRef);
    
    return bounds;
}

- (UIImage *)getPathImage {
    CGRect bounds = [self calculatePathBounds];
    
    //Bounds가 null이면 nil을 반환한다.
    if (CGRectIsNull(bounds))
        return nil;
    
    //이미지 캡쳐 전에, 배경을 투명하게 만든다.
    self.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *canvasViewCaptureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef pathImageRef = CGImageCreateWithImageInRect([canvasViewCaptureImage CGImage], bounds);
    UIImage *pathImage = [UIImage imageWithCGImage:pathImageRef];
    
    //이미지 캡쳐가 종료되었으므로, 배경색을 다시 원상 복구한다.
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    return pathImage;
}


#pragma mark - Clear Canvas View

- (void)clear {
    [self.pathArray removeAllObjects];
    [self.pathColorArray removeAllObjects];
    [self.pathWidthArray removeAllObjects];
    [path removeAllPoints];
    [self setNeedsDisplay];
}

@end