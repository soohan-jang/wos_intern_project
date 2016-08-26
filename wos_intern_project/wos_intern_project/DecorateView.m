//
//  DecorateView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 19..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateView.h"

#import "ColorUtility.h"

@interface DecorateView ()

@property (nonatomic, strong) UIImageView *eventPreventView;

@end

@implementation DecorateView

- (instancetype)initWithUUID:(NSUUID *)uuid timestamp:(NSNumber *)timestamp {
    self = [super init];
    
    if (self) {
        _uuid = uuid;
        _timestamp = timestamp;
        
        _eventPreventView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Editing"]];
        _eventPreventView.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent2f];
        _eventPreventView.contentMode = UIViewContentModeCenter;
        _eventPreventView.hidden = YES;
        
        [self addSubview:_eventPreventView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self visibleBorderLine:selected];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self visibleEventPreventView:!enabled];
}


#pragma mark - Visible & Hidden Border Line Methods

NSString *const BoundaryLayerName = @"boundaryLayer";
CGFloat const DefaultMargin       = 2.0f;
CGFloat const StrokeLineWitdth    = 1.0f;

- (void)visibleBorderLine:(BOOL)visible {
    for (CALayer *layer in [self.layer.sublayers copy]) {
        if (layer.name != nil && [layer.name isEqualToString:BoundaryLayerName]) {
            [layer removeFromSuperlayer];
        }
    }
    
    if (!visible) {
        return;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGRect shapeRect = CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width - (DefaultMargin + StrokeLineWitdth),
                                  self.frame.size.height - (DefaultMargin + StrokeLineWitdth));
    
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake(self.frame.size.width / 2.0f,
                                        self.frame.size.height / 2.0f)];
    
    [shapeLayer setStrokeColor:[[ColorUtility colorWithName:ColorNameOrange] CGColor]];
    [shapeLayer setFillColor:[[ColorUtility colorWithName:ColorNameTransparent] CGColor]];
    [shapeLayer setLineWidth:StrokeLineWitdth];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:@[@10, @5]];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shapeRect];
    [shapeLayer setPath:path.CGPath];
    
    shapeLayer.name = BoundaryLayerName;
    [self.layer addSublayer:shapeLayer];
}


#pragma mark - Visible & Hidden Prevent Event View Methods

- (void)visibleEventPreventView:(BOOL)visible {
    if (visible) {
        _eventPreventView.frame = self.bounds;
    }
    
    _eventPreventView.hidden = !visible;
    self.userInteractionEnabled = !visible;
}

@end
