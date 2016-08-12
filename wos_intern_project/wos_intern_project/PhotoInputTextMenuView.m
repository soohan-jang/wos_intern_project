//
//  PhotoInputTextMenuView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoInputTextMenuView.h"

CGFloat const DefaultFontSize = 20;

@interface PhotoInputTextMenuView ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) UIColor *textColor;
@property (assign, nonatomic) NSInteger textSize;
@property (strong, nonatomic) UIFont *textFont;

@end

@implementation PhotoInputTextMenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupViews];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (!hidden)
        return;
    
    //hidden되어 화면에서 사라질 때, DrawPenView를 초기화한다.
    self.textView.text = @"";
    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont systemFontOfSize:DefaultFontSize];
}

- (void)setupViews {
    self.backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.textView.backgroundColor = [UIColor clearColor];
}

CGFloat const Scale = 4.0f;

- (UIImage *)textViewConvertToImage {
    NSString *originText = self.textView.text;
    NSString *Trimedtext = [originText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([Trimedtext isEqualToString:@""]) {
        return nil;
    }
    
    //텍스트가 그려질 UIImage 객체를 생성한다.
    CGSize imageSize = CGSizeMake(self.textView.bounds.size.width * Scale, self.textView.bounds.size.height * Scale);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //이후 만들어진 UIImage 객체 위에 Text를 그린다.
    UIGraphicsBeginImageContext(imageSize);
    
    [[UIColor blackColor] set];
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    CGSize textSize = [originText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20 * Scale]}];
    CGRect rect = CGRectMake((imageSize.width - textSize.width) / Scale,
                             (imageSize.height - textSize.height) / Scale,
                             imageSize.width,
                             imageSize.height);
    
    [originText drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20 * Scale]}];
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
    [self.delegate inputTextMenuViewDidFinished:self WithImage:[self textViewConvertToImage]];
}

- (IBAction)tappedCancelButton:(id)sender {
    [self.delegate inputTextMenuViewDidCancelled:self];
}

- (IBAction)tappedTextColorButton:(id)sender {
    
}

- (IBAction)tappedTextSizeButton:(id)sender {
    
}

- (IBAction)tappedTextStyleButton:(id)sender {
    
}

@end
