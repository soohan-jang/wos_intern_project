//
//  PhotoDrawObjectDisplayView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawObjectDisplayView.h"

@interface PhotoDrawObjectDisplayView ()

@property (nonatomic, strong) DecorateObjectManager *decorateObjectManager;
@property (nonatomic, strong) NSMutableArray *drawObjectViews;
@property (nonatomic, assign) CGPoint previousPoint;

- (void)backgroundTapAction:(UITapGestureRecognizer *)recognizer;
- (void)drawObjectTapAction:(UITapGestureRecognizer *)recognizer;
- (void)drawObjectPanAction:(UIPanGestureRecognizer *)recognizer;
- (void)resizeButtonPanAction;
- (void)rotateButtonPanAction;
- (void)deleteButtonTapAction;

- (void)drawViewBoundary:(UIView *)view;
- (void)removeViewBoundary:(UIView *)view;

@end

@implementation PhotoDrawObjectDisplayView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapAction:)]];
        
        self.decorateObjectManager = [[DecorateObjectManager alloc] init];
    }
    
    return self;
}

- (void)addDrawObject:(WMPhotoDecorateObject *)drawObject {
    UIView *view = [drawObject getView];
    NSLog(@"view frame x : %f, y : %f, w : %f, h : %f", view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(drawObjectTapAction:)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawObjectPanAction:)];
    [view setGestureRecognizers:@[tapGestureRecognizer, panGestureRecognizer]];
    [view setUserInteractionEnabled:YES];
    
    if (self.drawObjectViews == nil) {
        self.drawObjectViews = [@[view] mutableCopy];
    } else {
        [self.drawObjectViews addObject:view];
    }
    
    [self.decorateObjectManager addDecorateObject:drawObject];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:view];;
    });
}

//이 부분은 딕셔너리를 넘겨서, 해당 값으로 셋팅하는 것으로 변경하자.
- (void)updateDrawObject:(WMPhotoDecorateObject *)drawObject {
    if (self.drawObjectViews != nil && self.drawObjectViews.count > 0) {
        for (UIView *view in self.drawObjectViews) {
            [view removeFromSuperview];
        }
        
        NSInteger index;
        for (index = 0; index < [self.decorateObjectManager getCount]; index++) {
            if ([[((WMPhotoDecorateObject *)[self.decorateObjectManager getDecorateObjectAtIndex:index]) getID] isEqualToString:[drawObject getID]]) {
                break;
            }
        }
        
        for (UIGestureRecognizer *recognizer in ((UIView *)self.drawObjectViews[index]).gestureRecognizers) {
            [self.drawObjectViews[index] removeGestureRecognizer:recognizer];
        }
        
        if ([[drawObject getData] isKindOfClass:[UIImage class]]) {
            WMPhotoDecorateImageObject *decoObject = (WMPhotoDecorateImageObject *)[self.decorateObjectManager getDecorateObjectAtIndex:index];
            decoObject.image = (UIImage *)[decoObject getData];
            decoObject.frame = drawObject.frame;
        } else if ([[drawObject getData] isKindOfClass:[NSString class]]) {
            WMPhotoDecorateTextObject *decoObject = (WMPhotoDecorateTextObject *)[self.decorateObjectManager getDecorateObjectAtIndex:index];
            decoObject.text = (NSString *)[drawObject getData];
            decoObject.frame = drawObject.frame;
        }
        
        [self sortDrawObject];
        
        [self.drawObjectViews removeAllObjects];
        
        for (int i = 0; i < [self.decorateObjectManager getCount]; i++) {
            UIView *view = [((WMPhotoDecorateObject *)[self.decorateObjectManager getDecorateObjectAtIndex:i]) getView];
            [self.drawObjectViews addObject:view];
            [self addSubview:view];
        }
    }
}

- (void)removeDrawObjectWithID:(NSString *)identifier {
    if (self.drawObjectViews != nil && self.drawObjectViews.count > 0) {
        NSInteger index;
        for (index = 0; index < [self.decorateObjectManager getCount]; index++) {
            if ([[((WMPhotoDecorateObject *)[self.decorateObjectManager getDecorateObjectAtIndex:index]) getID] isEqualToString:identifier]) {
                break;
            }
        }
        
        [self.drawObjectViews[index] removeFromSuperview];
        [self.drawObjectViews removeObjectAtIndex:index];
    }
}

- (void)sortDrawObject {
    
}

- (void)backgroundTapAction:(UITapGestureRecognizer *)recognizer {
    [self removeViewBoundary];
    self.previousPoint = CGPointMake(-9999, -9999);
}

- (void)drawObjectTapAction:(UITapGestureRecognizer *)recognizer {
    [self removeViewBoundary:recognizer.view];
    [self drawViewBoundary:recognizer.view];
}

- (void)drawObjectPanAction:(UIPanGestureRecognizer *)recognizer {
    [self removeViewBoundary:recognizer.view];
    [self drawViewBoundary:recognizer.view];
    
    //이동거리 제한을 둬야함.
    CGFloat x1 = self.bounds.origin.x;
    CGFloat y1 = self.bounds.origin.y;
    CGFloat x2 = self.bounds.size.width - x1;
    CGFloat y2 = self.bounds.size.height - y1;
    
    CGFloat centerX = recognizer.view.center.x;
    CGFloat centerY = recognizer.view.center.y;
    
//    NSLog(@"x1 : %f / y1 : %f", x1, y1);
//    NSLog(@"x2 : %f / y2 : %f", x2, y2);
//    NSLog(@"centerX : %f / centerY : %f", centerX, centerY);
    
    //이렇게하면 경계에서 이동 제한이 걸려야되는데, 실제로는 마이너스값이 찍힌다. 이게 무슨????
    if ((x1 <= centerX && centerX <= x2) && (y1 <= centerY && centerY <= y2)) {
        recognizer.view.center = [recognizer locationInView:self];
        
        //이동이 종료된 이후에, 변경된 사항을 DrawingManager에게 전달하고, 상대방에게도 전달해야한다.
    }
    
    if ([self.delegate respondsToSelector:@selector(drawObjectDidMoved:)]) {
        NSInteger index = [self.drawObjectViews indexOfObject:recognizer.view];
        [self.delegate drawObjectDidMoved:(WMPhotoDecorateObject *)[self.decorateObjectManager getDecorateObjectAtIndex:index]];
    }
}

- (void)resizeButtonPanAction {
    
}

- (void)rotateButtonPanAction {
    
}

- (void)deleteButtonTapAction {
    
}

- (void)drawViewBoundary:(UIView *)view {
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
    [shapeLayer setStrokeColor:[[UIColor colorWithRed:243 / 255.0f green:156 / 255.0f blue:18 / 255.0f alpha:1] CGColor]];
    [shapeLayer setLineWidth:strokeLineWitdth];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:@[@10, @5]];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shapeRect];
    [shapeLayer setPath:path.CGPath];
    
    [view.layer addSublayer:shapeLayer];
}

- (void)removeViewBoundary {
    for (UIView *view in self.drawObjectViews) {
        [self removeViewBoundary:view];
    }
}

- (void)removeViewBoundary:(UIView *)view {
    if (view != nil) {
        for (CALayer *layer in view.layer.sublayers) {
            [layer removeFromSuperlayer];
        }
    }
}

@end
