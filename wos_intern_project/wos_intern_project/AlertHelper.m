//
//  AlertHelper.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 4..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "AlertHelper.h"

@implementation AlertHelper

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                                      title:(NSString * __nullable)title
                                    message:(NSString * __nullable)message
                                firstButton:(UIAlertAction * __nullable)firstButton
                               secondButton:(UIAlertAction * __nullable)secondButton {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    
    if (firstButton) {
        [alertController addAction:firstButton];
    }
    
    if (secondButton) {
        [alertController addAction:secondButton];
    }
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                      titleKey:(NSString * __nullable)titleKey
                    messageKey:(NSString * __nullable)messageKey
                firstButton:(UIAlertAction * __nullable)firstButton
               secondButton:(UIAlertAction * __nullable)secondButton {
    
    [self showAlertControllerOnViewController:viewController
                                        title:NSLocalizedString(titleKey, nil)
                                      message:NSLocalizedString(messageKey, nil)
                                  firstButton:firstButton
                                 secondButton:secondButton];
}

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                                      title:(NSString * __nullable)title
                                    message:(NSString * __nullable)message
                                     button:(UIAlertAction * __nullable)button {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    
    if (button) {
        [alertController addAction:button];
    }
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                                   titleKey:(NSString * __nullable)titleKey
                                 messageKey:(NSString * __nullable)messageKey
                                     button:(UIAlertAction * __nullable)button {
    
    [self showAlertControllerOnViewController:viewController
                                        title:NSLocalizedString(titleKey, nil)
                                      message:NSLocalizedString(messageKey, nil)
                                  button:button];
}

+ (UIAlertAction * _Nonnull)createActionWithTitleKey:(NSString * _Nonnull)titleKey handler:(void (^ __nullable)(UIAlertAction  * _Nonnull action))handler {
    return [UIAlertAction actionWithTitle:NSLocalizedString(titleKey, nil) style:UIAlertActionStyleDefault handler:handler];
}

@end
