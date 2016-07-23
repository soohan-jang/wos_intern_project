//
//  PhotoEditorViewCell.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorFrameViewCell.h"

NSString *const NOTIFICATION_SELECTED_CELL  = @"notification_selected_cell";
NSString *const KEY_SELECTED_CELL_INDEXPATH = @"selected_cell_indexpath";

@interface PhotoEditorFrameViewCell () <UIScrollViewDelegate>

@end

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

- (void)setLoadingImage:(NSInteger)loadingState {
    //STATE_NONE
    if (loadingState == 0) {
        self.photoLoadingView.hidden = YES;
    }
    else {
        self.photoLoadingView.hidden = NO;
        
        //STATE_UPLOADING
        if (loadingState == 1) {
            [self.photoLoadingView setImage:[UIImage imageNamed:@"Uploading"]];

        }
        //STATE DONWLOADING
        else if (loadingState == 2) {
            [self.photoLoadingView setImage:[UIImage imageNamed:@"Downloading"]];
        }
    }
}

- (void)tapAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SELECTED_CELL object:nil userInfo:@{KEY_SELECTED_CELL_INDEXPATH:self.indexPath}];
}

@end
