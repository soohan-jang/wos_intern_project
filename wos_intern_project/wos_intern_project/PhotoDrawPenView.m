//
//  PhotoEditorDrawViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawPenView.h"

@interface PhotoDrawPenView ()

@end

@implementation PhotoDrawPenView

- (IBAction)doneAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(drawPenViewDidFinished:WithImage:)]) {
        [self.delegate drawPenViewDidFinished:self WithImage:[self.canvasView getPathImage]];
    }
}

- (IBAction)backAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(drawPenViewDidCancelled:)]) {
        [self.delegate drawPenViewDidCancelled:self];
    }
}

@end
