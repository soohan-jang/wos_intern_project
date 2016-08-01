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

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self.canvasView clear];
}

- (IBAction)doneAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(drawViewDidTouchedDone:WithImage:)]) {
        [self.delegate drawViewDidTouchedDone:self WithImage:[self.canvasView getPathImage]];
    }
}

- (IBAction)backAction:(id)sender {
    [self setHidden:YES];
}

@end
