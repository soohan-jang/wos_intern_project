//
//  PhotoEditorDrawViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawView.h"

@interface PhotoDrawView ()

@end

@implementation PhotoDrawView

//- (void)setHidden:(BOOL)hidden {
//    [super setHidden:hidden];
//    
//    if (hidden) {
//        [self.canvasView clear];
//    } else {
//        [self.canvasView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
//    }
//}

- (IBAction)doneAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(drawViewDidFinished:WithImage:)]) {
        [self.delegate drawViewDidFinished:self WithImage:[self.canvasView getPathImage]];
    }
}

- (IBAction)backAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(drawViewDidCancelled:)]) {
        [self.delegate drawViewDidCancelled:self];
    }
}

@end
