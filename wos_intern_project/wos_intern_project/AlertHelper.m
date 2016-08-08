//
//  AlertHelper.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 4..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "AlertHelper.h"

@implementation AlertHelper

+ (UIAlertController *)createAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    return alertController;
}

+ (UIAlertController *)createAlertControllerWithTitleKey:(NSString *)titleKey messageKey:(NSString *)messageKey {
    return [AlertHelper createAlertControllerWithTitle:NSLocalizedString(titleKey, nil) message:NSLocalizedString(messageKey, nil)];
}

+ (void)addButtonOnAlertController:(UIAlertController *)alertController titleKey:(NSString *)titleKey handler:(void (^)(UIAlertAction *action))handler {
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(titleKey, nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:handler];
    
    [alertController addAction:action];
}

+ (void)showAlertControllerOnViewController:(UIViewController *)viewController alertController:(UIAlertController *)alertController {
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)dismissAlertController:(UIAlertController *)alertController {
    [alertController dismissViewControllerAnimated:YES completion:nil];
}

@end
