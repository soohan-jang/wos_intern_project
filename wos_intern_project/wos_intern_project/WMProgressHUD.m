//
//  WMProgressHUD.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 14..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMProgressHUD.h"

@implementation WMProgressHUD

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated title:(NSString *)title {
    WMProgressHUD *hud = [super showHUDAddedTo:view animated:animated];
    hud.label.text = title;
    hud.square = YES;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];
    
    return hud;
}

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated title:(NSString *)title detail:(NSString *)detail {
    WMProgressHUD *hud = [super showHUDAddedTo:view animated:animated];
    hud.label.text = title;
    hud.detailsLabel.text = detail;
    hud.square = YES;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];
    
    return hud;
}

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated title:(NSString *)title detail:(NSString *)detail alpha:(CGFloat)alpha {
    WMProgressHUD *hud = [super showHUDAddedTo:view animated:animated];
    hud.label.text = title;
    hud.detailsLabel.text = detail;
    hud.square = YES;
    hud.contentColor = [UIColor colorWithWhite:0.f alpha:0.5f];
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:alpha];
    
    return hud;
}

- (void)doneProgressWithTitle:(NSString *)title delay:(NSTimeInterval)delay {
    self.mode = MBProgressHUDModeCustomView;
    self.label.text =  title;
    self.detailsLabel.text = nil;
    
    UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.customView = [[UIImageView alloc] initWithImage:image];
    
    [self hideAnimated:YES afterDelay:delay];
}

- (void)dismissProgress {
    [self hideAnimated:YES];
}

@end
