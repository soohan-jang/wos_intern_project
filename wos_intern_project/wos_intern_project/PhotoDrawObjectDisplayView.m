//
//  PhotoDrawObjectDisplayView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawObjectDisplayView.h"

#import "UIView+StringTag.h"
#import "WMPhotoDecorateObject.h"

@interface PhotoDrawObjectDisplayView ()

@property (nonatomic, copy) NSString *selectedDrawingObjectId;

@property (nonatomic, strong) UIButton *resizeButton;
@property (nonatomic, strong) UIButton *rotateButton;
@property (nonatomic, strong) UIButton *zOrderButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation PhotoDrawObjectDisplayView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deselectDrawObject)]];
        [self setupSubMenuButtons];
    }
    
    return self;
}

NSInteger const SubMenuWidth           = 30;
NSInteger const SubMenuHeight          = 30;

- (void)setupSubMenuButtons {
    self.resizeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SubMenuWidth, SubMenuHeight)];
    [self.resizeButton setImage:[UIImage imageNamed:@"SubMenuResize"] forState:UIControlStateNormal];
    [self.resizeButton setUserInteractionEnabled:YES];
    [self.resizeButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedResizeButton:)]];
    [self.resizeButton setHidden:YES];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SubMenuWidth, SubMenuHeight)];
    [self.deleteButton setImage:[UIImage imageNamed:@"SubMenuDelete"] forState:UIControlStateNormal];
    [self.deleteButton setUserInteractionEnabled:YES];
    [self.deleteButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedDeleteButton:)]];
    [self.deleteButton setHidden:YES];
    
    [self addSubview:self.resizeButton];
    [self addSubview:self.deleteButton];
}

- (void)addDecoView:(UIView *)decoView {
    if (!decoView)
        return;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedDrawObjectView:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedDrawObjectView:)];
    [decoView setGestureRecognizers:@[tapGestureRecognizer, panGestureRecognizer]];
    
    [decoView setUserInteractionEnabled:YES];
    
    [self addSubview:decoView];
}

- (void)addDecoViews:(NSArray<UIView *> *)decoViews {
    if (decoViews == nil || decoViews.count == 0)
        return;
    
    [self deleteAllDecoViews];
    
    for (UIView *view in decoViews) {
        [self addDecoView:view];
    }
}

- (void)updateDecoViewWithId:(NSString *)identifier originX:(CGFloat)originX originY:(CGFloat)originY {
    if (![self hasSubViews])
        return;
    
    UIView *view = [self getViewWithId:identifier];
    
    if (!view)
        return;
    
    view.frame = CGRectMake(originX, originY, view.frame.size.width, view.frame.size.height);
}

- (void)updateDecoViewWithId:(NSString *)identifier originX:(CGFloat)originX originY:(CGFloat)originY width:(CGFloat)width height:(CGFloat)height {
    if (![self hasSubViews])
        return;
    
    UIView *view = [self getViewWithId:identifier];
    
    if (!view)
        return;
    
    view.frame = CGRectMake(originX, originY, width, height);
    [self drawDecoViewEditPreventImage:view];
}

- (void)updateDecoViewWithId:(NSString *)identifier angle:(CGFloat)angle {
    if (![self hasSubViews])
        return;
    
    UIView *view = [self getViewWithId:identifier];
    
    if (!view)
        return;
    
    //View에 대한 Angle 설정. Transform 먹여야 할 듯?
}

/**
 @berif
 파라메터로 받은 View를 최상위로 올린다. 이 메소드를 호출하기 전, 반드시 Controller에 저장된 View Model의 Z-order를 변경해주어야 한다.
 */
- (void)updateDecoViewZOrderWithId:(NSString *)identifier {
    if (![self hasSubViews])
        return;
    
    UIView *view = [self getViewWithId:identifier];
    
    if (!view)
        return;
    
    [self bringSubviewToFront:view];
}

- (void)deleteDecoViewWithId:(NSString *)identifier {
    if (![self hasSubViews])
        return;
    
    UIView *view = [self getViewWithId:identifier];
    
    if (!view)
        return;
    
    [self removeRecognizerOfView:view];
    [view removeFromSuperview];
}

- (void)deleteAllDecoViews {
    if (![self hasSubViews])
        return;
    
    for (UIView *view in self.subviews) {
        [self removeRecognizerOfView:view];
        [view removeFromSuperview];
    }
}

- (void)setEnableWithId:(NSString *)identifier enable:(BOOL)enable {
    if (![self hasSubViews])
        return;
    
    UIView *view = [self getViewWithId:identifier];
    
    if (!view)
        return;
    
    if (enable) {
        [self removeDecoViewEditPreventImage:view];
    } else {
        [self drawDecoViewEditPreventImage:view];
    }
}

- (void)deselectDrawObject {
    if (![self hasSubViews])
        return;
    
    if (!self.selectedDrawingObjectId)
        return;
    
    [self.delegate decoViewDidDeselected:self.selectedDrawingObjectId];
    [self changeSelectedDrawObjectView:nil];
}

/**
 @berif
 selectedDrawObjectView를 변경한다. changedView는 현재 선택된 객체로 설정될 뷰를 의미한다.
 이전에 선택되었던 뷰의 바운더리와 서브메뉴를 제거하고, 현재 선택된 객체에 바운더리와 서브메뉴를 그린다.
 changedView가 nil이면 선택해제만 된 것으로 간주한다.
 */
- (void)changeSelectedDrawObjectView:(UIView *)changedView {
    //만약 이전에 선택된 뷰와 현재 선택된 뷰가 같다면, 종료한다.
    if ([self.selectedDrawingObjectId isEqual:changedView.stringTag])
        return;
    
    //이전에 선택된 뷰가 있었다면,
    if (self.selectedDrawingObjectId) {
        [self removeDecoViewBoundary];
        [self removeSubMenu];
        [self.delegate decoViewDidDeselected:self.selectedDrawingObjectId];
    }
    
    //현재 선택된 뷰가 있다면,
    if (changedView) {
        self.selectedDrawingObjectId = changedView.stringTag;
        
        [self drawDecoViewBoundary];
        [self drawSubMenus];
        [self.delegate decoViewDidSelected:changedView.stringTag];
    } else {
        self.selectedDrawingObjectId = nil;
    }
}

- (UIView *)getViewWithId:(NSString *)identifier {
    if (![self hasSubViews])
        return nil;
    
    for (UIView *view in self.subviews) {
        if ([view.stringTag isEqualToString:identifier]) {
            return view;
        }
    }
    
    return nil;
}
         
- (void)removeRecognizerOfView:(UIView *)view {
    NSArray<UIGestureRecognizer *> *recognizers = view.gestureRecognizers;
    
    if (recognizers == nil || recognizers.count == 0)
        return;
    
    for (UIGestureRecognizer *recognizer in recognizers) {
        [view removeGestureRecognizer:recognizer];
    }
}

/**
 @berif
 self.view가 subView를 가지고 있는지를 확인한 후, 여부를 반환한다.
 */
- (BOOL)hasSubViews {
    if (self.subviews.count == 0)
        return NO;
    
    return YES;
}


#pragma mark - EventHandler Methods

/**
 그려진 객체에 Tap 이벤트가 발생했을 때 수행되는 메소드이다. 경계를 그리고, 수정에 필요한 버튼(크기조절, 회전, 삭제, Z-order 변경)을 표시한다.
 */
- (void)tappedDrawObjectView:(UITapGestureRecognizer *)recognizer {
    [self changeSelectedDrawObjectView:recognizer.view];
}

/**
 그려진 객체에 Pan 이벤트가 발생했을 때 수행되는 메소드이다. 이벤트의 좌표값에 따라 객체의 위치를 변경한다.
 객체의 이동은 객체의 Center 값을 이벤트의 좌표로 할당함으로 수행한다.
 */
- (void)pannedDrawObjectView:(UIPanGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    
    [self changeSelectedDrawObjectView:view];
    
    //이동거리 제한을 둬야함.
    CGFloat x1 = self.bounds.origin.x;
    CGFloat y1 = self.bounds.origin.y;
    CGFloat x2 = self.bounds.size.width + x1;
    CGFloat y2 = self.bounds.size.height + y1;
    
    CGPoint point = [recognizer locationInView:self];
    
    if (!(x1 < point.x && point.x < x2 && y1 < point.y && point.y < y2))
        return;
        
    view.center = point;
    [self drawSubMenus];
    
    [self.delegate decoViewDidMovedWithId:view.stringTag originX:view.frame.origin.x originY:view.frame.origin.y];
}

/**
 그려진 객체에 표시된 크기변경 버튼에 Pan 이벤트가 발생했을 때 수행되는 메소드이다. 이벤트의 좌표값에 따라 객체의 크기를 변경한다.
 객체의 크기는 높이와 너비의 비율을 유지하며 조절된다.
 */
- (void)pannedResizeButton:(UIPanGestureRecognizer *)recognizer {
    UIView *view = [self getViewWithId:self.selectedDrawingObjectId];
    CGPoint point = [recognizer locationInView:self];
    
    CGRect frame = view.frame;
    CGFloat dx, dy, width, height;

    dx = point.x - (frame.origin.x + frame.size.width);
    dy = frame.origin.y - point.y;
    
    width = frame.size.width + dx;
    height = frame.size.height + dy;
    
    if (point.x < frame.origin.x + 20)
        return;
    
    if (point.y > frame.origin.y + frame.size.height - 20)
        return;
    
    //그림 객체의 크기를 새롭게 잡고, 바운더리 새로 그리고, 서브 버튼들 위치도 변경해야 됨.
    view.frame = CGRectMake(frame.origin.x, point.y, width, height);
    [self removeDecoViewBoundary];
    [self drawDecoViewBoundary];
    [self drawSubMenus];
    
    [self.delegate decoViewDidResizedWithId:self.selectedDrawingObjectId originX:frame.origin.x originY:frame.origin.y resizedWidth:width resizedHeight:height];
}

/**
 그려진 객체에 표시된 회전 버튼에 Pan 이벤트가 발생했을 때 수행되는 메소드이다. 이벤                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          트의 좌표값에 따라 객체의 회전각도가 결정된다.
 */
- (void)pannedRotateButton:(id)sender forEvent:(UIEvent *)event {
    
}

/**
 그려진 객체에 표시된 Z-order 변경 버튼에 Tap 이벤트가 발생했을 때 수행되는 메소드이다. 해당되는 객체를 bringToFront하여 최상위로 올린다.
 */
- (void)tappedChangeZOrderButton:(id)sender forEvent:(UIEvent *)event {
    
}

/**
 그려진 객체에 표시된 삭제 버튼에 Tap 이벤트가 발생했을 때 수행되는 메소드이다. 해당되는 객체의 GestrueRecognizer를 제거하고, DisplayView에서 제거한다.
 */
- (void)tappedDeleteButton:(UITapGestureRecognizer *)recognizer {
    [self deleteDecoViewWithId:self.selectedDrawingObjectId];
    [self.delegate decoViewDidDeletedWithId:self.selectedDrawingObjectId];
    [self changeSelectedDrawObjectView:nil];
}


#pragma mark - Draw & Remove Boundary Line Methods

NSString *const BoundaryLayerName = @"boundaryLayer";

/**
 View의 경계에 점선을 그려 경계를 표시한다.
 */
- (void)drawDecoViewBoundary {
    if (!self.selectedDrawingObjectId)
        return;
    
    CGFloat defaultMargin = 2.0f;
    CGFloat strokeLineWitdth = 1.0f;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    UIView *view = [self getViewWithId:self.selectedDrawingObjectId];
    CGRect frame = view.frame;
    CGRect shapeRect = CGRectMake(frame.origin.x,
                                  frame.origin.y,
                                  frame.size.width - (defaultMargin + strokeLineWitdth),
                                  frame.size.height - (defaultMargin + strokeLineWitdth));
    
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake(frame.size.width / 2.0f,
                                        frame.size.height / 2.0f)];
    
    [shapeLayer setStrokeColor:[[UIColor colorWithRed:243 / 255.0f
                                                green:156 / 255.0f
                                                 blue:18 / 255.0f
                                                alpha:1] CGColor]];
    
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setLineWidth:strokeLineWitdth];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:@[@10, @5]];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shapeRect];
    [shapeLayer setPath:path.CGPath];
    
    shapeLayer.name = BoundaryLayerName;
    [view.layer addSublayer:shapeLayer];
}

/**
 View의 경계에 그려진 점선을 제거하고, 선택해제된 View의 identifier를 반환한다.
 */
- (void)removeDecoViewBoundary {
    if (!self.selectedDrawingObjectId)
        return;
    
    UIView *view = [self getViewWithId:self.selectedDrawingObjectId];
    
    for (CALayer *layer in [view.layer.sublayers copy]) {
        if (layer.name != nil && [layer.name isEqualToString:BoundaryLayerName]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
}


#pragma mark - Draw & Remove SubMenu Buttons

- (void)drawSubMenus {
    if (!self.selectedDrawingObjectId)
        return;
    
    CGRect frame = [self getViewWithId:self.selectedDrawingObjectId].frame;
    
    [self.resizeButton setCenter:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y)];
    [self.deleteButton setCenter:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height)];
    
    [self.resizeButton setHidden:NO];
    [self.deleteButton setHidden:NO];
    
    [self bringSubviewToFront:self.resizeButton];
    [self bringSubviewToFront:self.deleteButton];
}

/**
 @berif
 현재 선택된 DrawObjectView 위에 그려진 크기변경, 회전, Z-order 변경, 삭제 버튼을 제거하고 EventHandle Methods를 제거한다.
 */
- (void)removeSubMenu {
    if (!self.selectedDrawingObjectId)
        return;
    
    [self.resizeButton setHidden:YES];
    [self.deleteButton setHidden:YES];
}


#pragma mark - Draw & Remove Edit Prevent Image

NSInteger const PreventViewTag      = 1000;
NSInteger const PreventImageViewTag = 1001;
NSInteger const PreventImageWidth   = 40;
NSInteger const PreventImageHeight  = 40;

//이것도 SubMenu Button들과 같이 재사용할 것인지 고려할 필요가 있음. 지금 생각으론 재사용하는 게 좋을 것 같긴한데... 1:1이면 모를까 1:n 통신으로 가면 이렇게 해야됨.
//1:n 통신으로 가더라도, PreventView는 각 DrawObject의 자식뷰이므로 Tag로 인해 가져오는 것에 혼선을 빚는 일은 없음.
- (UIView *)generateEditPreventImageView:(CGRect)frame {
    UIView *preventView = [[UIView alloc] initWithFrame:frame];
    [preventView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    [preventView setUserInteractionEnabled:YES];
    [preventView setTag:PreventViewTag];
    
    UIImageView *preventImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Editing"]];
    [preventImageView setContentMode:UIViewContentModeScaleAspectFit];
    [preventImageView setUserInteractionEnabled:YES];
    
    preventImageView.frame = CGRectMake(0, 0, PreventImageWidth, PreventImageHeight);
    preventImageView.center = preventView.center;
    //이 부분은 차후 AutoLayout으로 변경하여 항상 부모의 중간에 위치하도록 설정한다.
    preventImageView.tag = PreventImageViewTag;
    
    [preventView addSubview:preventImageView];
    
    return preventView;
}

/**
 @berif
 파라메터로 받은 View의 위에 편집을 막는 UIImageView를 배치한다.
 */
- (void)drawDecoViewEditPreventImage:(UIView *)view {
    if (!view)
        return;
    
    UIView *preventView = [view viewWithTag:PreventViewTag];
    
    if (!preventView) {
        [view addSubview:[self generateEditPreventImageView:view.bounds]];
    } else {
        preventView.frame = view.bounds;
        //이 부분은 차후 AutoLayout으로 변경되면 삭제될 부분이다.
        UIView *preventImageView = [preventView viewWithTag:PreventImageViewTag];
        preventImageView.center = preventView.center;
    }
}

- (void)removeDecoViewEditPreventImage:(UIView *)view {
    if (!view)
        return;
    
    UIImageView *preventImageView = [view viewWithTag:PreventViewTag];
    
    if (preventImageView) {
        [preventImageView removeFromSuperview];
        preventImageView = nil;
    }
}

@end
