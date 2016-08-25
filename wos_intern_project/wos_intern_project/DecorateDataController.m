//
//  DecorateDataController.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateDataController.h"
#import "DecorateDataDisplayView.h"

#import "SessionManager.h"
#import "MessageSender.h"
#import "MessageReceiver.h"

@interface DecorateDataSender ()

@property (strong, nonatomic) MessageSender *messageSender;

@end

@implementation DecorateDataSender

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.messageSender = [SessionManager sharedInstance].messageSender;
    }
    
    return self;
}

- (BOOL)sendScreenSizeDeviceDataMessage:(CGSize)screenSize {
    return [self.messageSender sendScreenSizeDeviceDataMessage:screenSize];
}

- (BOOL)sendSelectDecorateDataMessage:(NSUUID *)uuid {
    return [self.messageSender sendSelectDecorateDataMessage:uuid];
}

- (BOOL)sendDeselectDecorateDataMessage:(NSUUID *)uuid {
    return [self.messageSender sendDeselectDecorateDataMessage:uuid];
}

- (BOOL)sendInsertDecorateDataMessage:(DecorateData *)insertData {
    return [self.messageSender sendInsertDecorateDataMessage:insertData];
}

- (BOOL)sendUpdateDecorateDataMessage:(NSUUID *)uuid updateFrame:(CGRect)updateFrame {
    return [self.messageSender sendUpdateDecorateDataMessage:uuid updateFrame:updateFrame];
}

- (BOOL)sendDeleteDecorateDataMessage:(NSUUID *)uuid {
    return [self.messageSender sendDeleteDecorateDataMessage:uuid];
}

@end

@interface DecorateDataController () <DecorateDataDisplayViewDataSource, MessageReceiverDeviceDataDelegate, MessageReceiverDecorateDataDelegate>

@property (atomic, strong) NSMutableArray<DecorateData *> *decorateDataArray;
@property (nonatomic, assign) CGFloat widthRatio, heightRatio;

@end

@implementation DecorateDataController


#pragma mark - init method

- (instancetype)init {
    self = [super init];
    
    if (self) {
        SessionManager *sessionManager = [SessionManager sharedInstance];
        sessionManager.messageReceiver.deviceDataDelegate = self;
        sessionManager.messageReceiver.decorateDataDelegate = self;
        
        self.dataSender = [[DecorateDataSender alloc] init];
        
        if (![self.dataSender sendScreenSizeDeviceDataMessage:[UIScreen mainScreen].bounds.size]) {
            //스크린 사이즈 송신 실패 시, Alert 표시하고 MainVC로 돌아간다.
        }
    }
    
    return self;
}


#pragma mark - Add & Update & Delete Decorate Data Methods

- (void)addDecorateData:(DecorateData *)decorateData {
    if (!decorateData) {
        return;
    }
    
    if (!self.decorateDataArray) {
        self.decorateDataArray = [[NSMutableArray alloc] init];
    }
    
    [self.decorateDataArray addObject:decorateData];
    [self sortDecorateDataArray];
    
    if (self.delegate) {
        [self.delegate didUpdateDecorateData:decorateData.uuid];
    }
}

- (void)selectDecorateData:(NSUUID *)uuid selected:(BOOL)selected {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (!data) {
        return;
    }
    
    data.selected = selected;
    
    if (self.delegate) {
        [self.delegate didUpdateDecorateData:uuid];
    }
}

- (void)updateDecorateData:(NSUUID *)uuid frame:(CGRect)frame {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (!data) {
        return;
    }
    
    data.frame = frame;
    
    if (self.delegate) {
        [self.delegate didUpdateDecorateData:uuid];
    }
}

- (void)deleteDecorateData:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (!data) {
        return;
    }
    
    [self.decorateDataArray removeObject:data];
        
    if (self.delegate) {
        [self.delegate didUpdateDecorateData:uuid];
    }
}


#pragma mark - Utility Methods

- (BOOL)isDecorateDataArrayNilOrEmpty {
    if (!self.decorateDataArray || self.decorateDataArray.count == 0) {
        return YES;
    }
    
    return NO;
}

- (DecorateData *)decorateDataOfUUID:(NSUUID *)uuid {
    if (!uuid || [self isDecorateDataArrayNilOrEmpty]) {
        return nil;
    }
    
    NSString *uuidString = uuid.UUIDString;
    
    for (DecorateData *data in self.decorateDataArray) {
        if ([data.uuid.UUIDString isEqualToString:uuidString]) {
            return data;
        }
    }
    
    return nil;
}

//동기식 정렬을 수행한다. 따라서 이 메소드를 호출한 뒤에 작업을 진행한다고 비동기성으로 문제가 발생하지 않는다.
- (void)sortDecorateDataArray {
    if (![self isDecorateDataArrayNilOrEmpty]) {
        [self.decorateDataArray sortUsingComparator:^NSComparisonResult(DecorateData  *_Nonnull data1, DecorateData  *_Nonnull data2) {
            return [data1.timestamp compare:data2.timestamp];
        }];
    }
}


#pragma mark - Decorate DisplayView DataSource Methods

- (DecorateView *)decorateDisplayView:(DecorateDataDisplayView *)decorateDisplayView decorateViewOfUUID:(NSUUID *)uuid {
    DecorateView *view = [decorateDisplayView decorateViewOfUUID:uuid];
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    //Update
    if (view && data) {
        view.frame = data.frame;
        
        view.enabled = data.enabled;
        
        //enabled가 NO로 설정된 객체에 대해선 선택을 수행할 수 없으므로, 선택관련 로직을 무시한다.
//        if (!view.enabled) {
//            return nil;
//        }
        
        //선택해제된 경우
        if (view.selected && !data.selected) {
            view.selected = data.selected;
            [decorateDisplayView removeControlButtonsFromSelectedDecorateView];
            return nil;
        }
        
        if (data.selected) {
            view.selected = data.selected;
            [decorateDisplayView drawControlButtonsOnSelectedDecorateView];
            return nil;
        }
    }
    
    //Delete
    if (view && !data) {
        if (view.selected) {
            [decorateDisplayView removeControlButtonsFromSelectedDecorateView];
        }
        
        [view removeFromSuperview];
        view = nil;
        
        return nil;
    }
    
    //Insert
    if (!view && data) {
        return data.decorateView;
    }
    
    return nil;
}


#pragma mark - MessageReceiverDeviceDataDelegate Methods

- (void)didReceiveDeviceScreenSize:(CGSize)screenSize {
    CGSize myScreenSize = [UIScreen mainScreen].bounds.size;
    _widthRatio = myScreenSize.width / screenSize.width;
    _heightRatio = myScreenSize.height / screenSize.height;
    
    if (self.delegate) {
        [self.delegate didReceiveScreenSize];
    }
}


#pragma mark - MessageReceiverDecorateDataDelegate Methods

- (void)didReceiveSelectDecorateData:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data.selected && self.delegate) {
        [self.delegate didInterruptDecorateDataSelection:uuid];
    }
    
    if (data) {
        data.enabled = NO;
    }
    
    if (self.delegate) {
        [self.delegate didUpdateDecorateData:uuid];
    }
}

- (void)didReceiveDeselectDecorateData:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data) {
        data.enabled = YES;
    }
    
    if (self.delegate) {
        [self.delegate didUpdateDecorateData:uuid];
    }
}

- (void)didReceiveInsertDecorateData:(DecorateData *)insertData {
    if (!insertData) {
        return;
    }
    
    insertData.frame = CGRectMake(insertData.frame.origin.x,
                                  insertData.frame.origin.y,
                                  insertData.frame.size.width * self.widthRatio,
                                  insertData.frame.size.height * self.heightRatio);
    
    [self addDecorateData:insertData];
}

- (void)didReceiveUpdateDecorateData:(NSUUID *)uuid updateFrame:(CGRect)updateFrame {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data) {
        data.frame = CGRectMake(updateFrame.origin.x * self.widthRatio,
                                updateFrame.origin.y * self.heightRatio,
                                updateFrame.size.width * self.widthRatio,
                                updateFrame.size.height * self.heightRatio);
    }
    
    if (self.delegate) {
        [self.delegate didUpdateDecorateData:uuid];
    }
}

- (void)didReceiveDeleteDecorateData:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data) {
        [self deleteDecorateData:uuid];
    }
}

@end
