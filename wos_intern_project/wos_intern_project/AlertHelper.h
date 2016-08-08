//
//  AlertHelper.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 4..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AlertStyle) {
    AlertStyleButtonNone    = 0,
    AlertStyleButtonOne     = 1,
    AlertStyleButtonTwo     = 2
};

@interface AlertHelper : NSObject

+ (UIAlertController * _Nonnull)createAlertControllerWithTitle:(NSString * __nullable)title message:(NSString * __nullable)message;
+ (UIAlertController * _Nonnull)createAlertControllerWithTitleKey:(NSString * __nullable)titleKey messageKey:(NSString * __nullable)messageKey;
+ (void)addButtonOnAlertController:(UIAlertController * _Nonnull)alertController titleKey:(NSString  * __nullable)titleKey handler:(void (^ __nullable)(UIAlertAction * _Nonnull action))handler;
+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController alertController:(UIAlertController * _Nonnull)alertController;
+ (void)dismissAlertController:(UIAlertController * _Nonnull)alertController;

@end
