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
                                     button:(NSString * __nullable)buttonKey
                              buttonHandler:(void (^ __nullable)(UIAlertAction  * _Nonnull action))buttonHandler
                                otherButton:(NSString * __nullable)otherButtonKey
                         otherButtonHandler:(void (^ __nullable)(UIAlertAction  * _Nonnull action))otherButtonHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    if (buttonKey) {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(buttonKey, nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:buttonHandler]];
    }
    
    if (otherButtonKey) {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(otherButtonKey, nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:otherButtonHandler]];
    }
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                                   titleKey:(NSString * __nullable)titleKey
                                 messageKey:(NSString * __nullable)messageKey
                                     button:(NSString * __nullable)buttonKey
                              buttonHandler:(void (^ __nullable)(UIAlertAction  * _Nonnull action))buttonHandler
                                otherButton:(NSString * __nullable)otherButtonKey
                         otherButtonHandler:(void (^ __nullable)(UIAlertAction  * _Nonnull action))otherButtonHandler {
    
    [self showAlertControllerOnViewController:viewController
                                        title:NSLocalizedString(titleKey, nil)
                                      message:NSLocalizedString(messageKey, nil)
                                       button:buttonKey
                                buttonHandler:buttonHandler
                                  otherButton:otherButtonKey
                           otherButtonHandler:otherButtonHandler];
}

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                                      title:(NSString * __nullable)title
                                    message:(NSString * __nullable)message
                                     button:(NSString * __nullable)buttonKey
                              buttonHandler:(void (^ __nullable)(UIAlertAction  * _Nonnull action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    if (buttonKey) {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(buttonKey, nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:handler]];
    }
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                                   titleKey:(NSString * __nullable)titleKey
                                 messageKey:(NSString * __nullable)messageKey
                                     button:(NSString * __nullable)buttonKey
                              buttonHandler:(void (^ __nullable)(UIAlertAction  * _Nonnull action))handler {
    
    [self showAlertControllerOnViewController:viewController
                                        title:NSLocalizedString(titleKey, nil)
                                      message:NSLocalizedString(messageKey, nil)
                                       button:NSLocalizedString(buttonKey, nil)
                                buttonHandler:handler];
}

@end
