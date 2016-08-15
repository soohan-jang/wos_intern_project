//
//  PhotoDrawPenMenuView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDrawPenMenuView.h"
#import "PhotoDrawCanvasView.h"

typedef NS_ENUM(NSInteger, LineColorMenuItem) {
    LineColorBlack  = 0,
    LineColorRed    = 1,
    LineColorGreen  = 2,
    LineColorBlue   = 3,
    LineColorYellow = 4,
    LineColorClose  = 5
};

@interface PhotoDrawPenMenuView ()

@property (nonatomic, weak) IBOutlet PhotoDrawCanvasView *canvasView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *eraseButton;

@property (nonatomic, weak) IBOutlet UIView *lineColorSubMenu;
@property (nonatomic, weak) IBOutlet UIButton *defalutLineColorButton;
@property (nonatomic, strong) UIButton *prevSelectedLineColorButton;

@property (nonatomic, weak) IBOutlet UIView *lineWidthSubMenu;
@property (nonatomic, weak) IBOutlet UISlider *lineWidthSlider;
@property (nonatomic, weak) IBOutlet UILabel *lineWidthLabel;

@end

@implementation PhotoDrawPenMenuView

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden)
        return;
    
    //hidden NO가 되어 화면에 나타날 때, DrawPenView를 초기화한다.
    if (self.eraseButton.tag == Selected)
        [self toggleEraseButton];
    
    [self.lineWidthSlider setValue:DefaultLineWidth];
    [self.lineWidthLabel setText:@(DefaultLineWidth).stringValue];
    
    //CanvasView를 초기화한다.
    [self.canvasView clear];
    [self.canvasView setLineColor:[UIColor colorWithRed:51.f / 255.f
                                                  green:51.f / 255.f
                                                   blue:51.f / 255.f
                                                  alpha:1.f]];
    [self.canvasView setLineWidth:DefaultLineWidth];
    
    [self.prevSelectedLineColorButton setSelected:NO];
    self.prevSelectedLineColorButton = self.defalutLineColorButton;
    [self.prevSelectedLineColorButton setSelected:YES];
}


#pragma mark - EventHandle Drawing Menu Methods

- (IBAction)tappedDoneButton:(id)sender {
    [self closeLineColorSubMenu];
    [self closeLineWidthSubMenu];
    [self closeEraseSubMenu];
    
    [self.delegate drawPenMenuViewDidFinished:self WithImage:[self.canvasView getPathImage]];
}

- (IBAction)tappedCancelButton:(id)sender {
    [self closeLineColorSubMenu];
    [self closeLineWidthSubMenu];
    [self closeEraseSubMenu];
    
    [self.delegate drawPenMenuViewDidCancelled:self];
}

- (IBAction)tappedLineColorButton:(id)sender {
    [self closeLineWidthSubMenu];
    [self closeEraseSubMenu];
    
    [self.lineColorSubMenu setHidden:!self.lineColorSubMenu.isHidden];
    [self.prevSelectedLineColorButton setSelected:YES];
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

- (IBAction)tappedLineColorMenuItem:(UIButton *)sender {
    if (self.prevSelectedLineColorButton) {
        [self.prevSelectedLineColorButton setSelected:NO];
    }
    
    if (sender.tag != LineColorClose) {
        self.prevSelectedLineColorButton = sender;
        [self.prevSelectedLineColorButton setSelected:YES];
    }
    
    switch (sender.tag) {
        case LineColorBlack:
            [self.canvasView setLineColor:[UIColor colorWithRed:51.f / 255.f
                                                          green:51.f / 255.f
                                                           blue:51.f / 255.f
                                                          alpha:1.f]];
            break;
        case LineColorRed:
            [self.canvasView setLineColor:[UIColor colorWithRed:231.f / 255.f
                                                          green:76.f / 255.f
                                                           blue:60.f / 255.f
                                                          alpha:1.f]];
            break;
        case LineColorGreen:
            [self.canvasView setLineColor:[UIColor colorWithRed:39.f / 255.f
                                                          green:174.f / 255.f
                                                           blue:96.f / 255.f
                                                          alpha:1.f]];
            break;
        case LineColorBlue:
            [self.canvasView setLineColor:[UIColor colorWithRed:52.f / 255.f
                                                          green:152.f / 255.f
                                                           blue:219.f / 255.f
                                                          alpha:1.f]];
            break;
        case LineColorYellow:
            [self.canvasView setLineColor:[UIColor colorWithRed:241.f / 255.f
                                                          green:196.f / 255.f
                                                           blue:15.f / 255.f
                                                          alpha:1.f]];
            break;
        case LineColorClose:
            [self closeLineColorSubMenu];
            break;
    }
}


#pragma mark - EventHandler Line Width Menu Methods

- (IBAction)valueChnagedLineWidthSlider:(UISlider *)sender {
    int lineWidth = sender.value;
    
    self.lineWidthLabel.text = @(lineWidth).stringValue;
    [self.canvasView setLineWidth:lineWidth];
}

- (IBAction)tappedLineWidthMenuCloseButton:(id)sender {
    [self closeLineWidthSubMenu];
}

@end