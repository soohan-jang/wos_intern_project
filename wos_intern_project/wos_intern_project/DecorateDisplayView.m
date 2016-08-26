//
//  DecorateDataDisplayView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateDisplayView.h"

#import "PEDecorate.h"
#import "DecorateView.h"

#import "ColorUtility.h"
#import "DispatchAsyncHelper.h"
#import "ImageUtility.h"

@interface DecorateDisplayView ()

@property (nonatomic, strong) UIButton *resizeButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation DecorateDisplayView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackground:)]];
        [self setupSubMenuButtons];
    }
    
    return self;
}

NSInteger const SubMenuWidth           = 30;
NSInteger const SubMenuHeight          = 30;

- (void)setupSubMenuButtons {
    self.resizeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SubMenuWidth, SubMenuHeight)];
    [self.resizeButton setHidden:YES];
    [self.resizeButton setImage:[UIImage imageNamed:@"SubMenuResize"] forState:UIControlStateNormal];
    [self.resizeButton setUserInteractionEnabled:YES];
    [self.resizeButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(pannedResizeButton:)]];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SubMenuWidth, SubMenuHeight)];
    [self.deleteButton setHidden:YES];
    [self.deleteButton setImage:[UIImage imageNamed:@"SubMenuDelete"] forState:UIControlStateNormal];
    [self.deleteButton setUserInteractionEnabled:YES];
    [self.deleteButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tappedDeleteButton:)]];
}


#pragma mark - EventHandling

- (void)tappedBackground:(UITapGestureRecognizer *)recognizer {
    DecorateView *selectedView = [self getSelectedDecorateView];
    
    if (selectedView && self.delegate) {
        [self.delegate didSelectDecorateViewOfUUID:selectedView.uuid selected:NO];
    }
}

- (void)tappedDecorateView:(UITapGestureRecognizer *)recognizer {
    DecorateView *view = (DecorateView *)recognizer.view;
    [self setSelectedDecorateView:view];
}

- (void)pannedDecorateView:(UIPanGestureRecognizer *)recognizer {
    DecorateView *view = [self getSelectedDecorateView];
    
    CGPoint point = [recognizer locationInView:self];
    //발생한 이벤트 좌표값이 DisplayView 내부에 존재할 때만 이벤트를 전파한다.
    if (!CGRectContainsPoint(self.bounds, point)) {
        return;
    }
    
    //또한 발생한 이벤트 좌표값이 현재 선택된 View 내부에 존재할 때만 이벤트를 전파한다.
    if (!CGRectContainsPoint(view.frame, point)) {
        return;
    }
    
    CGRect movedFrame = CGRectMake(point.x - view.frame.size.width / 2,
                                   point.y - view.frame.size.height / 2,
                                   view.frame.size.width,
                                   view.frame.size.height);
    
    if (self.delegate) {
        [self.delegate didUpdateDecorateViewOfUUID:view.uuid frame:movedFrame];
    }
}

- (void)pannedResizeButton:(UIPanGestureRecognizer *)recognizer {
    DecorateView *view = [self getSelectedDecorateView];
    
    CGPoint point = [recognizer locationInView:self];
    
    CGFloat dx, dy, width, height;
    
    dx = point.x - (view.frame.origin.x + view.frame.size.width);
    dy = view.frame.origin.y - point.y;
    
    width = view.frame.size.width + dx;
    height = view.frame.size.height + dy;
    
    if (point.x < view.frame.origin.x + 20) {
        return;
    }
    
    if (point.y > view.frame.origin.y + view.frame.size.height - 20) {
        return;
    }
    
    CGRect resizedFrame = CGRectMake(view.frame.origin.x, point.y, width, height);
    
    if (self.delegate) {
        [self.delegate didUpdateDecorateViewOfUUID:view.uuid frame:resizedFrame];
    }
}

- (void)tappedDeleteButton:(UITapGestureRecognizer *)recognizer {
    DecorateView *view = [self getSelectedDecorateView];
    
    if (self.delegate) {
        [self.delegate didDeleteDecorateViewOfUUID:view.uuid];
    }
}


#pragma mark - Draw & Remove Resize, Delete Button

- (void)drawControlButtonsOnSelectedDecorateView {
    CGRect frame = [self getSelectedDecorateView].frame;
    
    [self.resizeButton setCenter:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y)];
    [self.deleteButton setCenter:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height)];
    
    if (self.resizeButton.hidden) {
        [self addSubview:self.resizeButton];
        self.resizeButton.hidden = NO;
    }
    
    if (self.deleteButton.hidden) {
        [self addSubview:self.deleteButton];
        self.deleteButton.hidden = NO;
    }
}

- (void)removeControlButtonsFromSelectedDecorateView {
    [self.resizeButton removeFromSuperview];
    [self.deleteButton removeFromSuperview];
    
    self.resizeButton.hidden = YES;
    self.deleteButton.hidden = YES;
}


#pragma mark - Utility Methods

- (BOOL)hasSubView {
    if (self.subviews.count == 0) {
        return NO;
    }
    
    return YES;
}

- (void)setSelectedDecorateView:(DecorateView *)view {
    //선택되지 않은 상태의 뷰에서 이벤트가 발생했다면, 선택된 뷰를 변경한다.
    if (!view.selected && self.delegate) {
        DecorateView *selectedView = [self getSelectedDecorateView];
        
        //기존에 선택된 뷰가 있다면, 선택 해제한다.
        if (selectedView) {
            [self.delegate didSelectDecorateViewOfUUID:selectedView.uuid selected:NO];
        }
        
        [self.delegate didSelectDecorateViewOfUUID:view.uuid selected:YES];
    }
}

- (DecorateView *)getSelectedDecorateView {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DecorateView class]] && ((DecorateView *)view).selected) {
            return (DecorateView *)view;
        }
    }
    
    return nil;
}

- (DecorateView *)decorateViewOfUUID:(NSUUID *)uuid {
    if (![self hasSubView]) {
        return nil;
    }
    
    NSString *uuidString = uuid.UUIDString;
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DecorateView class]] && [((DecorateView *)view).uuid.UUIDString isEqualToString:uuidString]) {
            return (DecorateView *)view;
        }
    }
    
    return nil;
}

- (void)addGestureRecognizerOnDecorateView:(DecorateView *)view {
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedDecorateView:)]];
    [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedDecorateView:)]];
}

- (BOOL)compareDecorateView:(DecorateView *)decorateView isSmallerThan:(DecorateView *)compareView {
    if ([decorateView.timestamp compare:compareView.timestamp] == NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)numberOfDecorateView {
    NSUInteger count = self.subviews.count;
    
    if (count == 0) {
        return count;
    }
    
    if (!self.resizeButton.hidden) {
        count--;
    }
    
    if (!self.deleteButton.hidden) {
        count--;
    }
    
    return count;
}
            

#pragma mark - Capture View

- (UIImage *)viewCapture {
    UIImage *captureImage = [ImageUtility viewCaptureImage:self];
    
    return captureImage;
}


#pragma mark - Call DataSource Methods

- (void)updateDecorateViewOfUUID:(NSUUID *)uuid {
    __weak typeof(self) weakSelf = self;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakSelf) self = weakSelf;
        
        if (!self) {
            return;
        }
        
        if (self.dataSource) {
            DecorateView *newDecorateView = [self.dataSource decorateDisplayView:self decorateViewOfUUID:uuid];
            
            //update or delete view
            if (!newDecorateView) {
                return;
            }
            
            //insert view
            for (UIView *view in self.subviews) {
                if ([view isKindOfClass:[DecorateView class]] && [self compareDecorateView:newDecorateView isSmallerThan:(DecorateView *)view]) {
                    [self addGestureRecognizerOnDecorateView:newDecorateView];
                    [self insertSubview:newDecorateView belowSubview:view];
                    return;
                }
            }
            
            [self addGestureRecognizerOnDecorateView:newDecorateView];
            [self addSubview:newDecorateView];
        }
    }];
}

@end
