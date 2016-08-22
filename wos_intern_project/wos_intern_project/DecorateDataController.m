//
//  DecorateDataController.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateDataController.h"
#import "ConnectionManager.h"
#import "DecorateDataDisplayView.h"

@interface DecorateDataController () <DecorateDataDisplayViewDataSource, ConnectionManagerDecorateDataDelegate>

@property (atomic, strong) NSMutableArray<DecorateData *> *decorateDataArray;

@end

@implementation DecorateDataController


#pragma mark - init method

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [ConnectionManager sharedInstance].decorateDataDelegate = self;
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
        [self.delegate didDecorateDataArrayUpdate:decorateData.uuid];
    }
}

- (void)selectDecorateData:(NSUUID *)uuid selected:(BOOL)selected {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (!data) {
        return;
    }
    
    data.selected = selected;
    
    if (self.delegate) {
        [self.delegate didDecorateDataArrayUpdate:uuid];
    }
}

- (void)updateDecorateData:(NSUUID *)uuid frame:(CGRect)frame {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (!data) {
        return;
    }
    
    data.frame = frame;
    
    if (self.delegate) {
        [self.delegate didDecorateDataArrayUpdate:uuid];
    }
}

- (void)deleteDecorateData:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (!data) {
        return;
    }
    
    [self.decorateDataArray removeObject:data];
        
    if (self.delegate) {
        [self.delegate didDecorateDataArrayUpdate:uuid];
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
        if (!view.enabled) {
            return nil;
        }
        
        //선택해제된 경우
        if (view.selected && !data.selected) {
            view.selected = data.selected;
            [decorateDisplayView removeControlButtonsFromSelectedDecorateView];
            return nil;
        }
        
        if (data.selected) {
            view.selected = data.selected;
            [decorateDisplayView drawControlButtonsOnSelectedDecorateView];
        }
        
        return nil;
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


#pragma mark - ConnectionManager Decorate DataDelegate Methods

- (void)receivedDecorateDataEditing:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data) {
        data.enabled = NO;
    }
    
    if (self.delegate) {
        [self.delegate didDecorateDataArrayUpdate:uuid];
    }
}

- (void)receivedDecorateDataEditCancelled:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data) {
        data.enabled = YES;
    }
    
    if (self.delegate) {
        [self.delegate didDecorateDataArrayUpdate:uuid];
    }
}

- (void)receivedDecorateDataInsert:(DecorateData *)data {
    if (!data) {
        return;
    }
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    data.frame = CGRectMake(data.frame.origin.x,
                            data.frame.origin.y,
                            data.frame.size.width / connectionManager.widthRatio,
                            data.frame.size.height / connectionManager.heightRatio);
    
    [self addDecorateData:data];
}

- (void)receivedDecorateDataUpdate:(NSUUID *)uuid frame:(CGRect)frame {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data) {
        data.frame = frame;
    }
    
    if (self.delegate) {
        [self.delegate didDecorateDataArrayUpdate:uuid];
    }
}

- (void)receivedDecorateDataDeleted:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data) {
        [self deleteDecorateData:uuid];
    }
}

- (void)interruptedDecorateDataEditing:(NSUUID *)uuid {
    DecorateData *data = [self decorateDataOfUUID:uuid];
    
    if (data) {
        data.selected = NO;
    }
    
    if (self.delegate) {
        [self.delegate didDecorateDataArrayUpdate:uuid];
    }
}

@end
