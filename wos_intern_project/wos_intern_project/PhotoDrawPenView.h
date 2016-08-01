//
//  PhotoEditorDrawViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SmoothLineView.h"

@protocol PhotoDrawPenViewDelegate;

@interface PhotoDrawPenView : UIView

@property (nonatomic, weak) id<PhotoDrawPenViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet SmoothLineView *canvasView;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

@protocol PhotoDrawPenViewDelegate <NSObject>
@required
- (void)drawPenViewDidFinished:(PhotoDrawPenView *)drawPenView WithImage:(UIImage *)image;
- (void)drawPenViewDidCancelled:(PhotoDrawPenView *)drawPenView;

@end