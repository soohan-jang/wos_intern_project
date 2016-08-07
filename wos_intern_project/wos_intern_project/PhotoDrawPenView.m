//
//  PhotoEditorDrawViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawPenView.h"
#import "PhotoDrawCanvasView.h"

typedef NS_ENUM(NSInteger, LineColorMenuItem) {
    LineColorBlack  = 0,
    LineColorRed    = 1,
    LineColorGreen  = 2,
    LineColorBlue   = 3,
    LineColorYellow = 4,
    LineColorClose  = 5
};

@interface PhotoDrawPenView ()

@property (nonatomic, weak) IBOutlet PhotoDrawCanvasView *canvasView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *eraseButton;

@property (nonatomic, weak) IBOutlet UIView *lineColorSubMenu;
@property (nonatomic, weak) IBOutlet UIView *lineWidthSubMenu;

@property (nonatomic, weak) IBOutlet UISlider *lineWidthSlider;
@property (nonatomic, weak) IBOutlet UILabel *lineWidthLabel;

@end

@implementation PhotoDrawPenView

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (!hidden)
        return;
    
    //hidden되어 화면에서 사라질 때, DrawPenView를 초기화한다.
    if (self.eraseButton.tag == Selected)
        [self toggleEraseButton];
    
    [self.lineWidthSlider setValue:10.f];
    [self.lineWidthLabel setText:@"10"];
    
    //CanvasView를 초기화한다.
    [self.canvasView clear];
    [self.canvasView setLineColor:[UIColor blackColor]];
    [self.canvasView setLineWidth:10.f];
}


#pragma mark - EventHandle Drawing Menu Methods

- (IBAction)tappedDoneButton:(id)sender {
    [self closeLineColorSubMenu];
    [self closeLineWidthSubMenu];
    [self closeEraseSubMenu];
    
    [self.delegate drawPenViewDidFinished:self WithImage:[self.canvasView getPathImage]];
}

- (IBAction)tappedCancelButton:(id)sender {
    [self closeLineColorSubMenu];
    [self closeLineWidthSubMenu];
    [self closeEraseSubMenu];
    
    [self.delegate drawPenViewDidCancelled:self];
}

- (IBAction)tappedPaletteButton:(id)sender {
    [self closeLineWidthSubMenu];
    [self closeEraseSubMenu];
    
    [self.lineColorSubMenu setHidden:!self.lineColorSubMenu.isHidden];
}

- (IBAction)tappedLineWidthButton:(id)sender {
    [self closeLineColorSubMenu];
    [self closeEraseSubMenu];
    
    [self.lineWidthSubMenu setHidden:!self.lineWidthSubMenu.isHidden];
}

NSInteger const Normal   = 0;
NSInteger const Selected = 1;

- (IBAction)tappedEraserButton:(id)sender {
    [self closeLineWidthSubMenu];
    [self closeLineColorSubMenu];
    
    [self toggleEraseButton];
}

- (void)toggleEraseButton {
    if (self.eraseButton.tag == Normal) {
        self.eraseButton.tintColor = [UIColor colorWithRed:243 / 255.0f
                                                     green:156 / 255.0f
                                                      blue:18 / 255.0f
                                                     alpha:1];
        self.eraseButton.tag = Selected;
        self.canvasView.drawMode = ModeErase;
    } else if (self.eraseButton.tag == Selected) {
        self.eraseButton.tintColor = nil;
        self.eraseButton.tag = Normal;
        self.canvasView.drawMode = ModeDraw;
    }
}

- (void)closeLineColorSubMenu {
    [self.lineColorSubMenu setHidden:YES];
}

- (void)closeLineWidthSubMenu {
    [self.lineWidthSubMenu setHidden:YES];
}

- (void)closeEraseSubMenu {
    if (self.eraseButton.tag == Selected)
        [self toggleEraseButton];
}


#pragma mark - EventHandler Line Color Menu Methods

- (IBAction)tappedLineColorMenuItem:(UIView *)sender {
    switch (sender.tag) {
        case LineColorBlack:
            [self.canvasView setLineColor:[UIColor blackColor]];
            break;
        case LineColorRed:
            [self.canvasView setLineColor:[UIColor redColor]];
            break;
        case LineColorGreen:
            [self.canvasView setLineColor:[UIColor greenColor]];
            break;
        case LineColorBlue:
            [self.canvasView setLineColor:[UIColor blueColor]];
            break;
        case LineColorYellow:
            [self.canvasView setLineColor:[UIColor yellowColor]];
            break;
        case LineColorClose:
            [self closeLineColorSubMenu];
            break;
    }
}


#pragma mark - EventHandler Line Width Menu Methods

- (IBAction)valueChnagedLineWidthSlider:(UISlider *)sender {
    float lineWidth = sender.value;
    
    self.lineWidthLabel.text = @(lineWidth).stringValue;
    [self.canvasView setLineWidth:lineWidth];
}

- (IBAction)tappedLineWidthMenuCloseButton:(id)sender {
    [self closeLineWidthSubMenu];
}

@end