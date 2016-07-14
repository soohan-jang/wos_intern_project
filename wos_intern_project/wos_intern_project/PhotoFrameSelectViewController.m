//
//  PhotoFrameSelectViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//
#import "PhotoFrameSelectViewController.h"

@implementation PhotoFrameSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.isEnableFrameSelect) {
        self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:@"Waiting..." detail:@"If you like current photo frame,\nclick a like button." alpha:0.5f];
    }
    
    [self addObservers];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self removeObservers];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    if (self.progressView != nil && !self.progressView.isHidden) {
        [self.progressView dismissProgress];
    }
    
    [[ConnectionManager sharedInstance] disconnectSession];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneAction:(id)sender {
    //원래는 선택된 액자의 인덱스를 보내야하는데, 테스트 목적으로 0을 보낸다.
    NSDictionary *data = @{[ConnectionManager sharedInstance].KEY_DATA_TYPE: [ConnectionManager sharedInstance].VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED,
                           [ConnectionManager sharedInstance].KEY_PHOTO_FRAME_INDEX: [NSNumber numberWithInteger:0]};
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:data]];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}

- (void)addObservers {
    //Browser 상태에서 연결이 됨. 사진 액자 선택 가능.
    //상대방에게서 현재 보여지는 사진 액자가 마음에 든다는 의사를 전달받기 위한 노티피케이션 옵저버를 등록한다.
    if (self.isEnableFrameSelect) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFrameLiked:) name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_LIKED object:nil];
    }
    //Advertiser 상태에서 연결이 됨. 사진 액자 선택 불가능.
    //상다뱅에게서 현재 보여지는 사진 액자가 변경되었음과 현재 보여지는 사진 액자가 선택되었음을 전달받기 위한 노티피케이션 옵저버를 등록한다.
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFrameIndexChanged:) name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_INDEX object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFrameSelected:) name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil];
    }
}

- (void)removeObservers {
    if (self.isEnableFrameSelect) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_LIKED object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_INDEX object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil];
    }
}

- (void)doneProgress {
    if (!self.progressView.isHidden) {
        [self.progressView doneProgressWithTitle:@"Completed!" delay:1];
    }
}

- (void)loadPhotoEditorViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"photoFrameEditorViewController"];
    
    [self.navigationController pushViewController:viewController animated:YES];
    [self removeObservers];
}


- (void)receivedFrameIndexChanged:(NSNotification *)notification {
    
}

- (void)receivedFrameLiked:(NSNotification *)notification {
    
}

- (void)receivedFrameSelected:(NSNotification *)notification {
    
    [self performSelectorOnMainThread:@selector(doneProgress) withObject:nil waitUntilDone:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self performSelectorOnMainThread:@selector(loadPhotoEditorViewController) withObject:nil waitUntilDone:YES];
//    });
}

@end
