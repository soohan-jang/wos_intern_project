//
//  PhotoEditorViewCell.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorFrameViewCell.h"

@implementation PhotoEditorFrameViewCell

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
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:@[@10, @5]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:10.0];
    [shapeLayer setPath:path.CGPath];
    
    [self.layer addSublayer:shapeLayer];
}

- (void)removeStrokeBorder {
    self.layer.sublayers = nil;
}

@end
