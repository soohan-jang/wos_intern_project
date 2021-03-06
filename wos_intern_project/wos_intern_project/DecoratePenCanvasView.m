//
//  PhotoDrawCanvasView.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 6..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecoratePenCanvasView.h"

#import "PECanvasPath.h"

#import "ColorUtility.h"

CGFloat const DefaultLineWidth = 4;

@interface DecoratePenCanvasView ()

@property (nonatomic, strong) NSMutableArray<PECanvasPath *> *pathDatas;

@end

@implementation DecoratePenCanvasView {
    UIBezierPath *path;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent4f];
        self.pathDatas = [[NSMutableArray alloc] init];
        
        self.lineColor = [ColorUtility colorWithName:ColorNameBlack];
        self.lineWidth = DefaultLineWidth;
        
        path = [UIBezierPath bezierPath];
        path.lineWidth = self.lineWidth;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    for (PECanvasPath *pathData in self.pathDatas) {
        [pathData.color setStroke];
        [pathData.path setLineWidth:pathData.width];
        [pathData.path stroke];
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
            pts[3] = CGPointMake((pts[2].x + pts[4].x) / 2.0, (pts[2].y + pts[4].y) / 2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            
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
    [self.pathDatas addObject:[[PECanvasPath alloc] initWithPath:path color:self.lineColor width:self.lineWidth]];
    [path removeAllPoints];
    [self setNeedsDisplay];
}

//지우개 1차 개선버전 - 오버헤드가 심할 것 같은데? 성능적으로 너무 저하되면 사용할 수 없다.
//성능에 대해서 파악한 이후에 기존에 논의하였던 Undo/Redo 방식의 적용을 검토해볼 필요성이 있다.
CGFloat const EraserRecognizeDistance = 1.0f;
CGFloat const EraserDistanceIncrement = 0.1f;

- (void)removePathLocatedAtPoint:(CGPoint)point {
    if (self.pathDatas == nil || self.pathDatas.count == 0)
        return;
    
    @autoreleasepool {
        NSArray *reversedArray = [[self.pathDatas reverseObjectEnumerator] allObjects];
        
        for (PECanvasPath *pathData in reversedArray) {
            CGPathRef pathRef = [pathData.path CGPath];
            BOOL isContained = NO;
            for (CGFloat x = point.x - EraserRecognizeDistance; x <= point.x + EraserRecognizeDistance; x = x + EraserDistanceIncrement) {
                for (CGFloat y = point.y - EraserRecognizeDistance; y <= point.y + EraserRecognizeDistance; y = y + EraserDistanceIncrement) {
                    if (!CGPathContainsPoint(pathRef, NULL, CGPointMake(x, y), true))
                        continue;
                    
                    isContained = YES;
                    break;
                }
                if (isContained)
                    break;
            }
            
            if (!isContained)
                continue;
            
            [self.pathDatas removeObject:pathData];
            [self setNeedsDisplay];
            break;
        }
        
        reversedArray = nil;
    }
}


#pragma mark - Calculate Bounds & Get Path Image

- (CGRect)calculatePathBounds {
    if (self.pathDatas == nil || self.pathDatas.count == 0)
        return CGRectNull;
    
    CGMutablePathRef mutalblePathRef = CGPathCreateMutable();
    
    for (PECanvasPath *pathData in self.pathDatas)
        CGPathAddPath(mutalblePathRef, NULL, [pathData.path CGPath]);
    
    CGRect captureBounds = CGPathGetBoundingBox(mutalblePathRef);
    captureBounds = CGRectMake(captureBounds.origin.x - 10,
                               captureBounds.origin.y - 10,
                               captureBounds.size.width + 20,
                               captureBounds.size.height + 20);
    
    //각 Path의 Bounds 계산해서, 최소값 최대값 x, y 도출.
    //이후 x - 20, y - 20, w + 40, h + 40으로 bounds capture하여 UIImage Create, return.
    
    CGPathRelease(mutalblePathRef);
    
    return captureBounds;
}

- (UIImage *)viewCapture {
    CGRect captureBounds = [self calculatePathBounds];
    
    //Bounds가 null이면 nil을 반환한다.
    if (CGRectIsNull(captureBounds))
        return nil;
    
    //이미지 캡쳐 전에, 배경을 투명하게 만든다.
    self.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent];
    
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *canvasViewCaptureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef pathImageRef = CGImageCreateWithImageInRect([canvasViewCaptureImage CGImage], captureBounds);
    UIImage *pathImage = [UIImage imageWithCGImage:pathImageRef];
    
    //이미지 캡쳐가 종료되었으므로, 배경색을 다시 원상 복구한다.
    self.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent2f];
    //또한 사용하였던 CGImageRef를 해제한다.
    CGImageRelease(pathImageRef);
    
    return pathImage;
}


#pragma mark - Clear Canvas View

- (void)clear {
    [self.pathDatas removeAllObjects];
    [path removeAllPoints];
    [self setNeedsDisplay];
}

@end