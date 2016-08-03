//
//  PhotoDrawObjectDisplayView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawObjectDisplayView.h"

#define INITIAL_VALUE_OF_POINT          -9999
#define BOUNDARY_STROKE_COLOR           [[UIColor colorWithRed:243 / 255.0f green:156 / 255.0f blue:18 / 255.0f alpha:1] CGColor]

NSInteger const DECO_VIEW_Z_ORDER_UP    = 0;
NSInteger const DECO_VIEW_Z_ORDER_DOWN  = 1;

@interface PhotoDrawObjectDisplayView ()

@property (nonatomic, assign) CGPoint previousPoint;

/**
 배경에 Tap 이벤트가 발생했을 때 수행되는 메소드이다. 그려진 객체들에 경계가 표시되어 있다면, 이를 해제하는 작업을 수행한다.
 */
- (void)backgroundTapAction:(UITapGestureRecognizer *)recognizer;
/**
 그려진 객체에 Tap 이벤트가 발생했을 때 수행되는 메소드이다. 경계를 그리고, 수정에 필요한 버튼(크기조절, 회전, 삭제, Z-order 변경)을 표시한다.
 */
- (void)decoViewTapAction:(UITapGestureRecognizer *)recognizer;
/**
 그려진 객체에 Pan 이벤트가 발생했을 때 수행되는 메소드이다. 이벤트의 좌표값에 따라 객체의 위치를 변경한다.
 객체의 이동은 객체의 Center 값을 이벤트의 좌표로 할당함으로 수행한다.
 */
- (void)decoViewPanAction:(UIPanGestureRecognizer *)recognizer;
/**
 그려진 객체에 표시된 크기변경 버튼에 Pan 이벤트가 발생했을 때 수행되는 메소드이다. 이벤트의 좌표값에 따라 객체의 크기를 변경한다.
 객체의 크기는 높이와 너비의 비율을 유지하며 조절된다.
 */
- (void)resizeButtonPanAction;
/**
 그려진 객체에 표시된 회전 버튼에 Pan 이벤트가 발생했을 때 수행되는 메소드이다. 이벤트의 좌표값에 따라 객체의 회전각도가 결정된다.
 */
- (void)rotateButtonPanAction;
/**
 그려진 객체에 표시된 Z-order 변경 버튼에 Tap 이벤트가 발생했을 때 수행되는 메소드이다. 해당되는 객체를 bringToFront하여 최상위로 올린다.
 */
- (void)zOrderUpButtonAction;
/**
 그려진 객체에 표시된 삭제 버튼에 Tap 이벤트가 발생했을 때 수행되는 메소드이다. 해당되는 객체의 GestrueRecognizer를 제거하고, DisplayView에서 제거한다.
 */
- (void)deleteButtonTapAction;
/**
 View의 경계에 점선을 그려 경계를 표시한다.
 */
- (void)drawDecoViewBoundary:(UIView *)view;
/**
 모든 View의 경계에 그려진 점선을 제거한다.
 */
- (void)deleteAllDecoViewBoundary;
/**
 View의 경계에 그려진 점선을 제거한다.
 */
- (void)deleteDecoViewBoundary:(UIView *)view;

@end

@implementation PhotoDrawObjectDisplayView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapAction:)]];
    }
    
    return self;
}

- (void)addDecoView:(UIView *)decoView {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(decoViewTapAction:)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(decoViewPanAction:)];
    [decoView setGestureRecognizers:@[tapGestureRecognizer, panGestureRecognizer]];
    [decoView setUserInteractionEnabled:YES];
    
    [self addSubview:decoView];
}

- (void)updateDecoViewWithId:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY {
    if (self.subviews.count > 0) {
        for (UIView *view in self.subviews) {
            if ([view.stringTag isEqualToString:identifier]) {
                view.frame = CGRectMake(originX, originY, view.frame.size.width, view.frame.size.height);
                break;
            }
        }
    }
}

- (void)updateDecoViewWithId:(NSString *)identifier WithWidth:(CGFloat)width WithHeight:(CGFloat)height {
    if (self.subviews.count > 0) {
        for (UIView *view in self.subviews) {
            if ([view.stringTag isEqualToString:identifier]) {
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, height);
                break;
            }
        }
    }
}

- (void)updateDecoViewWithId:(NSString *)identifier WithAngle:(CGFloat)angle {
    if (self.subviews.count > 0) {
        for (UIView *view in self.subviews) {
            if ([view.stringTag isEqualToString:identifier]) {
                //Angle 설정. Transform 먹여야 할 듯?
                break;
            }
        }
    }
}

- (void)updateDecoViewZOrderWithId:(NSString *)identifier {
//    if (self.subviews.count > 0) {
//        NSMutableArray *subViews = [self.subviews mutableCopy];
//        
//        for (int index = 0; index < subViews.count; index++) {
//            if ([((UIView *)subViews[index]).stringTag isEqualToString:identifier]) {
//                if (changeZOrder == DECO_VIEW_Z_ORDER_UP) {
//                    //가장 상단에 위치한 뷰가 아닐 때만 Z Order를 변경한다.
//                    if (index < subViews.count) {
//                        UIView *tempView = subViews[index];
//                        subViews[index] = subViews[index + 1];
//                        subViews[index + 1] = tempView;
//                    }
//                } else if (changeZOrder == DECO_VIEW_Z_ORDER_DOWN) {
//                    //가장 하단에 위치한 뷰가 아닐 때만 Z Order를 변경한다.
//                    if (index > 0) {
//                        UIView *tempView = subViews[index];
//                        subViews[index] = subViews[index - 1];
//                        subViews[index - 1] = tempView;
//                    }
//                }
//                
//                //모든 뷰를 내리고,
//                for (UIView *view in self.subviews) {
//                    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
//                        [view removeGestureRecognizer:recognizer];
//                    }
//                    
//                    [view removeFromSuperview];
//                }
//                
//                //다시 등록한다.
//                for (UIView *view in subViews) {
//                    [self addDecoView:view WithId:nil];
//                }
//                
//                break;
//            }
//        }
//
//    }
}

- (void)deleteDecoViewWithId:(NSString *)identifier {
    if (self.subviews.count > 0) {
        for (UIView *view in self.subviews) {
            if ([view.stringTag isEqualToString:identifier]) {
                for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
                    [view removeGestureRecognizer:recognizer];
                }
                
                [view removeFromSuperview];
                [self setNeedsDisplay];
                break;
            }
        }
    }
}

- (void)drawDecoViews:(NSArray *)decoViews {
    if (self.subviews.count > 0) {
        for (UIView *view in self.subviews) {
            for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
                [view removeGestureRecognizer:recognizer];
            }
            [view removeFromSuperview];
        }
    }
    
    if (decoViews != nil && decoViews.count > 0) {
        for (UIView *view in decoViews) {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(decoViewTapAction:)];
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(decoViewPanAction:)];
            [view setGestureRecognizers:@[tapGestureRecognizer, panGestureRecognizer]];
            [view setUserInteractionEnabled:YES];
            [self addSubview:view];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)setEnableWithId:(NSString *)indentifier WithEnable:(BOOL)enable {
//    for (UIView *view in self.subviews) {
//        
//    }
}

- (void)backgroundTapAction:(UITapGestureRecognizer *)recognizer {
    if (self.subviews.count > 0) {
        [self deleteAllDecoViewBoundary];
        self.previousPoint = CGPointMake(INITIAL_VALUE_OF_POINT, INITIAL_VALUE_OF_POINT);
    }
}

- (void)decoViewTapAction:(UITapGestureRecognizer *)recognizer {
    [self deleteAllDecoViewBoundary];
    [self drawDecoViewBoundary:recognizer.view];
}

- (void)decoViewPanAction:(UIPanGestureRecognizer *)recognizer {
    [self deleteAllDecoViewBoundary];
    [self drawDecoViewBoundary:recognizer.view];
    
    //이동거리 제한을 둬야함.
    CGFloat x1 = self.bounds.origin.x;
    CGFloat y1 = self.bounds.origin.y;
    CGFloat x2 = self.bounds.size.width + x1;
    CGFloat y2 = self.bounds.size.height + y1;
    
    CGFloat centerX = recognizer.view.center.x;
    CGFloat centerY = recognizer.view.center.y;
    
//    NSLog(@"x1 : %f / y1 : %f", x1, y1);
//    NSLog(@"x2 : %f / y2 : %f", x2, y2);
//    NSLog(@"centerX : %f / centerY : %f", centerX, centerY);
    
    //이렇게하면 경계에서 이동 제한이 걸려야되는데, 실제로는 마이너스값이 찍힌다. 이게 무슨????
    if ((x1 <= centerX && centerX <= x2) && (y1 <= centerY && centerY <= y2)) {
        recognizer.view.center = [recognizer locationInView:self];
        
        if ([self.delegate respondsToSelector:@selector(decoViewDidMovedWithId:WithOriginX:WithOriginY:)]) {
            [self.delegate decoViewDidMovedWithId:recognizer.view.stringTag WithOriginX:recognizer.view.frame.origin.x WithOriginY:recognizer.view.frame.origin.y];
        }
    }
}

- (void)resizeButtonPanAction {
    
}

- (void)rotateButtonPanAction {
    
}

- (void)zOrderUpButtonAction {
    
}

- (void)deleteButtonTapAction {
    
}

- (void)drawDecoViewBoundary:(UIView *)view {
    CGFloat defaultMargin = 2.0f;
    CGFloat strokeLineWitdth = 1.0f;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGRect shapeRect = CGRectMake(view.frame.origin.x,
                                  view.frame.origin.y,
                                  view.frame.size.width - (defaultMargin + strokeLineWitdth),
                                  view.frame.size.height - (defaultMargin + strokeLineWitdth));
    
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake(view.frame.size.width / 2.0f, view.frame.size.height / 2.0f)];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:BOUNDARY_STROKE_COLOR];
    [shapeLayer setLineWidth:strokeLineWitdth];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:@[@10, @5]];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shapeRect];
    [shapeLayer setPath:path.CGPath];
    
    [view.layer addSublayer:shapeLayer];
}

- (void)deleteAllDecoViewBoundary {
    for (UIView *view in self.subviews) {
        [self deleteDecoViewBoundary:view];
    }
}

- (void)deleteDecoViewBoundary:(UIView *)view {
    if (view != nil) {
        for (CALayer *layer in view.layer.sublayers) {
            [layer removeFromSuperlayer];
        }
    }
}

@end
