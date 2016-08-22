//
//  PhotoCollectionViewCell.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

#import "ColorUtility.h"

@interface PhotoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *photoFrameView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoLoadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *photoLoadingIndicator;

@end

@implementation PhotoCollectionViewCell

- (void)initializeCell {
    self.indexPath = 0;
    self.photoLoadingView.image = nil;
    self.photoImageView.image = nil;
    
    [self removeStrokeBorder];
    [self removeTapGestureRecognizer];
}

- (void)removeTapGestureRecognizer {
    if (self.photoImageView == nil || self.photoImageView.gestureRecognizers.count == 0)
        return;
    
    for (UIGestureRecognizer *recognizer in self.photoImageView.gestureRecognizers) {
        [self.photoImageView removeGestureRecognizer:recognizer];
    }
}


#pragma mark - Draw Border Methods

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
    [shapeLayer setFillColor:[[ColorUtility colorWithName:ColorNameTransparent] CGColor]];
    [shapeLayer setStrokeColor:[[ColorUtility colorWithName:ColorNameOrange] CGColor]];
    [shapeLayer setLineWidth:strokeLineWitdth];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:@[@10, @5]];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shapeRect];
    [shapeLayer setPath:path.CGPath];
    
    [self.photoFrameView.layer addSublayer:shapeLayer];
}

- (void)removeStrokeBorder {
    if (self.photoFrameView == nil || self.photoFrameView.layer.sublayers.count == 0) {
        return;
    }
    
    for (CALayer *layer in self.photoFrameView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
}


#pragma mark - Set Image Methods

- (void)setImage:(UIImage *)image {
    [self.photoImageView setImage:image];
}

- (void)setLoadingImage:(NSInteger)loadingState {
    //STATE_NONE
    if (loadingState == 0) {
        self.userInteractionEnabled = YES;
        self.photoLoadingView.hidden = YES;
        [self.photoLoadingIndicator stopAnimating];
    } else {
        self.userInteractionEnabled = NO;
        self.photoLoadingView.hidden = NO;
        //STATE_UPLOADING
        if (loadingState == 1) {
            [self.photoLoadingView setImage:[UIImage imageNamed:@"Uploading"]];
            [self.photoLoadingIndicator startAnimating];
        //STATE_DONWLOADING
        } else if (loadingState == 2) {
            [self.photoLoadingView setImage:[UIImage imageNamed:@"Downloading"]];
            [self.photoLoadingIndicator startAnimating];
        //STATE_EDITING
        } else if (loadingState == 3) {
            [self.photoLoadingView setImage:[UIImage imageNamed:@"Editing"]];
            [self.photoLoadingIndicator stopAnimating];
        }
    }
}

@end
