//
//  PhotoEditorViewCell.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorFrameViewCell.h"

#define BOUNDARY_STROKE_COLOR               [[UIColor colorWithRed:243 / 255.0f green:156 / 255.0f blue:18 / 255.0f alpha:1] CGColor]

NSString *const NOTIFICATION_SELECTED_CELL  = @"notification_selected_cell";
NSString *const KEY_SELECTED_CELL_INDEXPATH = @"selected_cell_indexpath";
NSString *const KEY_SELECTED_CELL_CENTER  = @"selected_cell_center";

@interface PhotoEditorFrameViewCell ()

@property (weak, nonatomic) IBOutlet UIView *photoFrameView;
@property (weak, nonatomic) IBOutlet UIImageView *photoLoadingView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

/**
 셀에서 탭 이벤트가 발생했을 때, 이를 처리하기 위한 함수이다.
 */
- (void)tapAction;

@end

@implementation PhotoEditorFrameViewCell

- (void)initializeCell {
    self.indexPath = 0;
    self.photoLoadingView.image = nil;
    self.photoImageView.image = nil;
    
    [self removeStrokeBorder];
    [self removeTapGestureRecognizer];
}

- (void)setStrokeBorder {
    CGFloat defaultMargin = 5.0f;
    CGFloat strokeLineWitdth = 3.0f;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGRect shapeRect = CGRectMake(self.bounds.origin.x,
                                  self.bounds.origin.y,
                                  self.bounds.size.width - (defaultMargin + strokeLineWitdth),
                                  self.bounds.size.height - (defaultMargin + strokeLineWitdth));
    
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f)];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:BOUNDARY_STROKE_COLOR];
    [shapeLayer setLineWidth:strokeLineWitdth];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:@[@10, @5]];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shapeRect];
    [shapeLayer setPath:path.CGPath];
    
    [self.photoFrameView.layer addSublayer:shapeLayer];
}

- (void)removeStrokeBorder {
    if (self.photoFrameView == nil || self.photoFrameView.layer.sublayers.count == 0)
        return;
    
    for (CALayer *layer in self.photoFrameView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
}

- (void)setTapGestureRecognizer {
    if (self.gestureRecognizers == nil || self.gestureRecognizers.count == 0) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self.photoImageView addGestureRecognizer:recognizer];
        [self.photoImageView setUserInteractionEnabled:YES];
    }
}

- (void)removeTapGestureRecognizer {
    if (self.photoImageView == nil || self.photoImageView.gestureRecognizers.count == 0)
        return;
    
    for (UIGestureRecognizer *recognizer in self.photoImageView.gestureRecognizers) {
        [self.photoImageView removeGestureRecognizer:recognizer];
    }
}

- (void)setImage:(UIImage *)image {
    [self.photoImageView setImage:image];
}

- (void)setLoadingImage:(NSInteger)loadingState {
    //STATE_NONE
    if (loadingState == 0) {
        self.photoLoadingView.hidden = YES;
    } else {
        self.photoLoadingView.hidden = NO;
        
        //STATE_UPLOADING
        if (loadingState == 1) {
            [self.photoLoadingView setImage:[UIImage imageNamed:@"Uploading"]];
        //STATE_DONWLOADING
        } else if (loadingState == 2) {
            [self.photoLoadingView setImage:[UIImage imageNamed:@"Downloading"]];
        //STATE_EDITING
        } else if (loadingState == 3) {
            [self.photoLoadingView setImage:[UIImage imageNamed:@"Editing"]];
        }
    }
}

- (void)tapAction {
    CGPoint centerPoint = CGPointMake(self.superview.frame.origin.x + self.frame.origin.x + self.frame.size.width / 2.0f,
                                self.superview.frame.origin.y + self.frame.origin.y + self.frame.size.height / 2.0f);
    
    NSDictionary *sendData = @{KEY_SELECTED_CELL_INDEXPATH:self.indexPath,
                               KEY_SELECTED_CELL_CENTER:[NSValue valueWithCGPoint:centerPoint]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SELECTED_CELL object:nil userInfo:sendData];
}

@end
