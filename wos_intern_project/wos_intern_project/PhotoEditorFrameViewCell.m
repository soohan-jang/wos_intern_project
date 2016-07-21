//
//  PhotoEditorViewCell.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorFrameViewCell.h"

@interface PhotoEditorFrameViewCell () <UIScrollViewDelegate>

@end

@implementation PhotoEditorFrameViewCell

//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedCellAction:)];
//        recognizer.numberOfTapsRequired = 1;
//        [self.photoScrollView setUserInteractionEnabled:YES];
//        [self.photoScrollView addGestureRecognizer:recognizer];
//    }
//    return self;
//}

- (void)setStrokeBorder {
    CGFloat defaultMargin = 5.0f;
    CGFloat strokeLineWitdth = 3.0f;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGSize frameSize = self.frame.size;
    
    CGRect shapeRect = CGRectMake(0.0f, 0.0f, frameSize.width - (defaultMargin + strokeLineWitdth), frameSize.height - (defaultMargin + strokeLineWitdth));
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake(frameSize.width/2.0f,frameSize.height/2.0f)];
    
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor colorWithRed:243/255.0f green:156/255.0f blue:18/255.0f alpha:1] CGColor]];
    [shapeLayer setLineWidth:strokeLineWitdth];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:@[@10, @5]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shapeRect];
    [shapeLayer setPath:path.CGPath];
    
    [self.photoFrameView.layer addSublayer:shapeLayer];
}

- (void)setTapGestureRecognizer {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.photoScrollView setUserInteractionEnabled:YES];
    [self.photoScrollView addGestureRecognizer:recognizer];
}

- (void)setImage:(UIImage *)image {
    [self.photoImageView setImage:image];
}

- (void)tapAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tapped_cell" object:nil userInfo:@{@"index_path":self.indexPath}];
}

@end
