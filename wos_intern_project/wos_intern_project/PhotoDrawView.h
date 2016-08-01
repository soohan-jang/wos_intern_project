//
//  PhotoEditorDrawViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SmoothLineView.h"

@protocol PhotoDrawViewDelegate;

@interface PhotoDrawView : UIView

@property (nonatomic, weak) id<PhotoDrawViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet SmoothLineView *canvasView;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

@protocol PhotoDrawViewDelegate <NSObject>
@required
- (void)drawViewDidTouchedDone:(PhotoDrawView *)drawView WithImage:(UIImage *)image;

@end