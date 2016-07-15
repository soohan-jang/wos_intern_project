//
//  PhotoEditorViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@interface PhotoEditorViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;

- (void)setupUI:(NSArray *)frameIndexArray;

@end
