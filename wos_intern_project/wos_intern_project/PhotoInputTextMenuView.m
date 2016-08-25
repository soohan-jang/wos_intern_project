//
//  PhotoInputTextMenuView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoInputTextMenuView.h"
#import "ColorUtility.h"

CGFloat const DefaultFontSize = 20;

typedef NS_ENUM(NSInteger, TextColorMenuItem) {
    TextColorBlack  = 0,
    TextColorRed    = 1,
    TextColorGreen  = 2,
    TextColorBlue   = 3,
    TextColorYellow = 4,
    TextColorClose  = 5
};

@interface PhotoInputTextMenuView ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIView *textColorSubMenu;
@property (weak, nonatomic) IBOutlet UIButton *defaultTextColorButton;
@property (strong, nonatomic) UIButton *prevSelectedTextColorButton;

@property (weak, nonatomic) IBOutlet UIView *textSizeSubMenu;
@property (weak, nonatomic) IBOutlet UISlider *textSizeSlider;
@property (weak, nonatomic) IBOutlet UILabel *textSizeLabel;

//한가지 남은 추가 기능에 대해선 조금 더 생각해보자. 폰트 종류로 할 것인지, 스타일로 할 것인지...
//@property (weak, nonatomic) IBOutlet UIView *textFontSubMenu;
//@property (weak, nonatomic) IBOutlet UIButton *defalutTextFontButton;
//@property (strong, nonatomic) UIButton *prevSelectedTextFontButton;

@property (assign, nonatomic) NSInteger textSize;
@property (assign, nonatomic) BOOL isBold, isItalic, isUnderLine;

@end

@implementation PhotoInputTextMenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialize];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden)
        return;
    
    //hidden NO가 되어 화면에 나타날 때, DrawPenView를 초기화한다.
    self.textSize = DefaultFontSize;
    
    self.textView.text = @"";
    self.textView.textColor = [ColorUtility colorWithName:ColorNameDarkGray];
    self.textView.font = [UIFont systemFontOfSize:self.textSize];
    
    [self.textSizeSlider setValue:DefaultFontSize];
    [self.textSizeLabel setText:@(DefaultFontSize).stringValue];
    
    [self.prevSelectedTextColorButton setSelected:NO];
    self.prevSelectedTextColorButton = self.defaultTextColorButton;
    [self.prevSelectedTextColorButton setSelected:YES];
}

- (void)initialize {
    self.backgroundView.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent4f];
    self.textView.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent];
}

CGFloat const Scale = 4.0f;

- (UIImage *)textViewConvertToImage {
    NSString *originText = self.textView.text;
    NSString *Trimedtext = [originText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([Trimedtext isEqualToString:@""]) {
        return nil;
    }
    
    UIFont *font = [UIFont systemFontOfSize:self.textSize * Scale];
    
    //텍스트가 그려질 UIImage 객체를 생성한다.
    CGSize imageSize = CGSizeMake(self.textView.bounds.size.width * Scale, self.textView.bounds.size.height * Scale);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[ColorUtility colorWithName:ColorNameTransparent] setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //이후 만들어진 UIImage 객체 위에 Text를 그린다.
    UIGraphicsBeginImageContext(imageSize);
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    CGSize textSize = [originText sizeWithAttributes:@{NSFontAttributeName:font}];
    CGRect rect = CGRectMake((imageSize.width - textSize.width) / Scale,
                             (imageSize.height - textSize.height) / Scale,
                             imageSize.width,
                             imageSize.height);
    
    [originText drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:font,
                                                                 NSForegroundColorAttributeName:self.textView.textColor}];
    
    UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return textImage;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.textView isFirstResponder]) {
        [self.textView endEditing:YES];
    } else {
        [self.textView becomeFirstResponder];
    }
}

- (IBAction)tappedDoneButton:(id)sender {
    [self closeTextColorSubMenu];
    [self closeTextSizeSubMenu];
    
    DecorateData *data = [[DecorateData alloc] initWithImage:[self textViewConvertToImage] scale:Scale];
    [self.delegate inputTextMenuViewDidFinished:data];
}

- (IBAction)tappedCancelButton:(id)sender {
    [self closeTextColorSubMenu];
    [self closeTextSizeSubMenu];
    
    [self.delegate inputTextMenuViewDidCancelled];
}

- (IBAction)tappedTextColorButton:(id)sender {
    [self closeTextSizeSubMenu];
    
    [self.textColorSubMenu setHidden:!self.textColorSubMenu.isHidden];
    [self.prevSelectedTextColorButton setSelected:YES];
}

- (IBAction)tappedTextSizeButton:(id)sender {
    [self closeTextColorSubMenu];
    
    [self.textSizeSubMenu setHidden:!self.textSizeSubMenu.isHidden];
}

- (IBAction)tappedTextStyleButton:(id)sender {
    
}

- (void)closeTextColorSubMenu {
    [self.textColorSubMenu setHidden:YES];
}

- (void)closeTextSizeSubMenu {
    [self.textSizeSubMenu setHidden:YES];
}


#pragma mark - EventHandler Text Color Menu Methods

- (IBAction)tappedTextColorMenuItem:(UIButton *)sender {
    if (self.prevSelectedTextColorButton) {
        [self.prevSelectedTextColorButton setSelected:NO];
    }
    
    if (sender.tag != TextColorClose) {
        self.prevSelectedTextColorButton = sender;
        [self.prevSelectedTextColorButton setSelected:YES];
    }
    
    switch (sender.tag) {
        case TextColorBlack:
            self.textView.textColor = [ColorUtility colorWithName:ColorNameDarkGray];
            break;
        case TextColorRed:
            self.textView.textColor = [ColorUtility colorWithName:ColorNameRed];
            break;
        case TextColorGreen:
            self.textView.textColor = [ColorUtility colorWithName:ColorNameGreen];
            break;
        case TextColorBlue:
             self.textView.textColor = [ColorUtility colorWithName:ColorNameBlue];
            break;
        case TextColorYellow:
             self.textView.textColor = [ColorUtility colorWithName:ColorNameYellow];
            break;
        case TextColorClose:
            [self closeTextColorSubMenu];
            break;
    }
}


#pragma mark - EventHandler Text Size Menu Methods

- (IBAction)valueChnagedLineWidthSlider:(UISlider *)sender {
    self.textSize = sender.value;
    self.textView.font = [UIFont systemFontOfSize:self.textSize];
    self.textSizeLabel.text = @(self.textSize).stringValue;
}

- (IBAction)tappedLineWidthMenuCloseButton:(id)sender {
    [self closeTextSizeSubMenu];
}

@end
