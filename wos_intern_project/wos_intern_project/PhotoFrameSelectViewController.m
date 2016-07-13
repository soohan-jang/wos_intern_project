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
    // Do any additional setup after loading the view, typically from a nib.
    self.connectionManager = [ConnectionManager sharedInstance];
    self.notificationCenter = [NSNotificationCenter defaultCenter];
}

- (void)viewDidAppear:(BOOL)animated {
    //Browser 상태에서 연결이 됨. 사진 액자 선택 가능.
    //상대방에게서 현재 보여지는 사진 액자가 마음에 든다는 의사를 전달받기 위한 노티피케이션 옵저버를 등록한다.
    if (self.isEnableFrameSelect) {
        [self.notificationCenter addObserver:self selector:@selector(receivedFrameLiked:) name:self.connectionManager.NOTIFICATION_RECV_PHOTO_FRAME_LIKED object:nil];
    }
    //Advertiser 상태에서 연결이 됨. 사진 액자 선택 불가능.
    //상다뱅에게서 현재 보여지는 사진 액자가 변경되었음과 현재 보여지는 사진 액자가 선택되었음을 전달받기 위한 노티피케이션 옵저버를 등록한다.
    else {
        [self.notificationCenter addObserver:self selector:@selector(receivedFrameIndexChanged:) name:self.connectionManager.NOTIFICATION_RECV_PHOTO_FRAME_INDEX object:nil];
        [self.notificationCenter addObserver:self selector:@selector(receivedFrameSelected:) name:self.connectionManager.NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isEnableFrameSelect) {
        [self.notificationCenter removeObserver:self name:self.connectionManager.NOTIFICATION_RECV_PHOTO_FRAME_LIKED object:nil];
    }
    else {
        [self.notificationCenter removeObserver:self name:self.connectionManager.NOTIFICATION_RECV_PHOTO_FRAME_INDEX object:nil];
        [self.notificationCenter removeObserver:self name:self.connectionManager.NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil];
    }
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.connectionManager.ownSession disconnect];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneAction:(id)sender {
    //원래는 현재 보이는 액자의 인덱스를 보내야하는데, 테스트 목적으로 0을 보낸다.
    NSDictionary *data = @{self.connectionManager.KEY_DATA_TYPE: self.connectionManager.VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED, self.connectionManager.KEY_FRAME_INDEX: [NSNumber numberWithInteger:0]};
    [self.connectionManager.ownSession sendData:[NSKeyedArchiver archivedDataWithRootObject:data] toPeers:self.connectionManager.ownSession.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}

- (void)receivedFrameIndexChanged:(NSNotification *)notification {
    
}

- (void)receivedFrameLiked:(NSNotification *)notification {
    
}

- (void)receivedFrameSelected:(NSNotification *)notification {
    
}

@end
