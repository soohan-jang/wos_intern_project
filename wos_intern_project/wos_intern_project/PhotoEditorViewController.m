//
//  PhotoEditorViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [[ConnectionManager sharedInstance] disconnectSession];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
    [[ConnectionManager sharedInstance] disconnectSession];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
