//
//  DecorateView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 19..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DecorateView : UIImageView

@property (nonatomic, strong, readonly) NSUUID *uuid;
@property (nonatomic, strong, readonly) NSNumber *timestamp;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL enabled;

- (instancetype)initWithUUID:(NSUUID *)uuid timestamp:(NSNumber *)timestamp;
- (void)setSelected:(BOOL)selected;
- (void)setEnabled:(BOOL)enabled;

@end
