//
//  SphereMenu.m
//  SphereMenu
//
//  Created by Tu You on 14-8-24.
//  Copyright (c) 2014年 TU YOU. All rights reserved.
//

#import "SphereMenu.h"

static const int kItemInitTag = 1001;
static const CGFloat kAngleOffset = M_PI_2 / 2;
static const CGFloat kSphereLength = 80;
static const float kSphereDamping = 0.3;

@interface SphereMenu () <UICollisionBehaviorDelegate>

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) UIButton *start;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *positions;

// animator and behaviors
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic, strong) NSMutableArray *snaps;

@property (nonatomic, strong) UITapGestureRecognizer *tapOnStart;

@property (nonatomic, strong) id<UIDynamicItem> bumper;
@property (nonatomic, assign) BOOL expanded;

@property (nonatomic, assign) BOOL isAnimated;

@end

@implementation SphereMenu

- (instancetype)initWithRootView:(UIView *)rootView Center:(CGPoint)center CloseImage:(UIImage *)image MenuImages:(NSArray *)images {
    if (self = [super init]) {
        _angle = kAngleOffset;
        _sphereLength = kSphereLength;
        _sphereDamping = kSphereDamping;
        
        //사진 액자가 화면의 중간 범위에 위치할 때,
        if (rootView.center.x - 10 <= center.x && center.x <= rootView.center.x + 10) {
            if (images.count == 2) {
                _startAngle = M_PI * 1.1f;
            } else {
                _startAngle = M_PI * -1.13f;
            }
        } else {
            //사진 액자가 화면의 왼쪽에 위치할 때,
            if (center.x < rootView.center.x) {
                if (images.count == 2) {
                    _startAngle = M_PI * 1.2f;
                } else {
                    _startAngle = M_PI * 1.15f;
                }
                //사진 액자가 화면의 오른쪽에 위치할 때,
            } else if (center.x > rootView.center.x) {
                if (images.count == 2) {
                    _startAngle = M_PI * 1.05f;
                } else {
                    _startAngle = M_PI * -1.4f;
                }
            }
        }
        
        _start = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_start setImage:image forState:UIControlStateNormal];
        _start.center = center;
        _images = images;
        _count = self.images.count;
        
        self.frame = rootView.bounds;
        [rootView addSubview:self];
    }
    
    return self;
}

- (void)presentMenu {
    [self addSubview:_start];
    [self expandSubmenu];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    _isAnimated = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isAnimated = NO;
    });
}

- (void)dismissMenu {
    _isAnimated = YES;
    [self shrinkSubmenu];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isAnimated = NO;
        
        [self removeFromSuperview];
        self.backgroundColor = [UIColor clearColor];
    });
}

- (void)commonSetup {
    self.items = [NSMutableArray array];
    self.positions = [NSMutableArray array];
    self.snaps = [NSMutableArray array];
    
    // setup the items
    for (int i = 0; i < self.count; i++) {
        CGPoint position = [self centerForSphereAtIndex:i];
        
        UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
        [item setImage:self.images[i] forState:UIControlStateNormal];
        
        item.tag = kItemInitTag + i;
        item.userInteractionEnabled = YES;
        [self addSubview:item];
        
        item.center = self.start.center;
        
        [self.positions addObject:[NSValue valueWithCGPoint:position]];
        
        [item addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)]];
        [item addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
        [self.items addObject:item];
    }
    
    _start.userInteractionEnabled = YES;
    _start.tag = kItemInitTag - 1;
    [_start addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    [self addSubview:_start];
    
    self.userInteractionEnabled = YES;
    self.tag = kItemInitTag - 2;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    
    [self.superview bringSubviewToFront:self];
    
    // setup animator and behavior
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    
    self.collision = [[UICollisionBehavior alloc] initWithItems:self.items];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    self.collision.collisionDelegate = self;
    
    for (int i = 0; i < self.count; i++) {
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[i] snapToPoint:self.center];
        snap.damping = self.sphereDamping;
        [self.snaps addObject:snap];
    }
    
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.items];
    self.itemBehavior.allowsRotation = NO;
    self.itemBehavior.elasticity = 1.2;
    self.itemBehavior.density = 0.5;
    self.itemBehavior.angularResistance = 5;
    self.itemBehavior.resistance = 10;
    self.itemBehavior.elasticity = 0.8;
    self.itemBehavior.friction = 0.5;
}

- (void)didMoveToSuperview {
    [self commonSetup];
}

- (void)removeFromSuperview {
    for (int i = 0; i < self.count; i++) {
        [self.items[i] removeFromSuperview];
        for (UIGestureRecognizer *recongnizer in ((UIButton *)self.items[i]).gestureRecognizers) {
            [self.items[i] removeGestureRecognizer:recongnizer];
        }
    }
    [self.items removeAllObjects];
    [self.positions removeAllObjects];
    self.images = nil;
    
    [_start removeFromSuperview];
    for (UIGestureRecognizer *recongnizer in _start.gestureRecognizers) {
        [_start removeGestureRecognizer:recongnizer];
    }
    
    [super removeFromSuperview];
    for (UIGestureRecognizer *recongnizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recongnizer];
    }
}

- (CGPoint)centerForSphereAtIndex:(int)index {
    //self.angle이 offset이다. (M_PI_2 - self.angle)는 offset을 의미하고, index * self.angle로 각 인덱스별로 offset를 늘려 설정한다.
    //따라서 서브메뉴의 시작각도를 변경하려면 수식 맨 앞에 있는 PI값을 건드리면 된다.
    CGFloat firstAngle = _startAngle + (M_PI_2 - self.angle) + index * self.angle;
    CGPoint startPoint = self.start.center;
    CGFloat x = startPoint.x + cos(firstAngle) * self.sphereLength;
    CGFloat y = startPoint.y + sin(firstAngle) * self.sphereLength;
    CGPoint position = CGPointMake(x, y);
    return position;
}

- (void)tapped:(UITapGestureRecognizer *)gesture {
    int tag = (int)gesture.view.tag - kItemInitTag;
    
    if (tag < 0) {
        [self.animator removeBehavior:self.collision];
        [self.animator removeBehavior:self.itemBehavior];
        [self removeSnapBehaviors];
    }
    
    if ([self.delegate respondsToSelector:@selector(sphereDidSelected:index:)]) {
        [self.delegate sphereDidSelected:self index:tag];
    }
}

- (void)expandSubmenu {
    for (int i = 0; i < self.count; i++) {
        [self snapToPostionsWithIndex:i];
    }
    
    self.expanded = YES;
}

- (void)shrinkSubmenu {
    [self.animator removeBehavior:self.collision];
    
    for (int i = 0; i < self.count; i++) {
        [self snapToStartWithIndex:i];
    }
    
    self.expanded = NO;
}

- (void)panned:(UIPanGestureRecognizer *)gesture {
    UIView *touchedView = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.itemBehavior];
        [self.animator removeBehavior:self.collision];
        [self removeSnapBehaviors];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        touchedView.center = [gesture locationInView:self.superview];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.bumper = touchedView;
        [self.animator addBehavior:self.collision];
        NSUInteger index = [self.items indexOfObject:touchedView];
        
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    [self.animator addBehavior:self.itemBehavior];
    
    if (item1 != self.bumper) {
        NSUInteger index = (int)[self.items indexOfObject:item1];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
    
    if (item2 != self.bumper) {
        NSUInteger index = (int)[self.items indexOfObject:item2];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
}

- (void)snapToStartWithIndex:(NSUInteger)index {
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[index] snapToPoint:self.start.center];
    snap.damping = self.sphereDamping;
    UISnapBehavior *snapToRemove = self.snaps[index];
    self.snaps[index] = snap;
    [self.animator removeBehavior:snapToRemove];
    [self.animator addBehavior:snap];
}

- (void)snapToPostionsWithIndex:(NSUInteger)index {
    id positionValue = self.positions[index];
    CGPoint position = [positionValue CGPointValue];
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[index] snapToPoint:position];
    snap.damping = self.sphereDamping;
    UISnapBehavior *snapToRemove = self.snaps[index];
    self.snaps[index] = snap;
    [self.animator removeBehavior:snapToRemove];
    [self.animator addBehavior:snap];
}

- (void)removeSnapBehaviors {
    [self.snaps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.animator removeBehavior:obj];
    }];
}

@end
