//
//  PhotoEditorDrawViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawPenView.h"
#import "SmoothLineView.h"

@interface PhotoDrawPenView ()

@property (weak, nonatomic) IBOutlet SmoothLineView *canvasView;

@end

@implementation PhotoDrawPenView


#pragma mark - EventHandle Methods

- (IBAction)tappedDoneButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(drawPenViewDidFinished:WithImage:)]) {
        [self.delegate drawPenViewDidFinished:self WithImage:[self.canvasView getPathImage]];
    }
}

- (IBAction)tappedCancelButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(drawPenViewDidCancelled:)]) {
        [self.delegate drawPenViewDidCancelled:self];
    }
    
    [self.canvasView clear];
}

- (IBAction)tappedPaletteButton:(id)sender {
    
}

- (IBAction)tappedLineWidthButton:(id)sender {
    
}

- (IBAction)tappedEraserButton:(id)sender {
    
}

@end
