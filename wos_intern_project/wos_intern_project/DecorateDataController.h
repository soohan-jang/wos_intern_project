//
//  DecorateDataController.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecorateData.h"

@protocol DecorateDataControllerDelegate;

@interface DecorateDataController : NSObject

@property (weak, nonatomic) id<DecorateDataControllerDelegate> delegate;

- (void)addDecorateData:(DecorateData *)decorateData;
- (void)selectDecorateData:(NSUUID *)uuid selected:(BOOL)selected;
- (void)updateDecorateData:(NSUUID *)uuid frame:(CGRect)frame;
- (void)deleteDecorateData:(NSUUID *)uuid;

@end

@protocol DecorateDataControllerDelegate <NSObject>
@required
- (void)didUpdateDecorateData:(NSUUID *)uuid;
- (void)didInterruptDecorateDataSelection:(NSUUID *)uuid;

@end