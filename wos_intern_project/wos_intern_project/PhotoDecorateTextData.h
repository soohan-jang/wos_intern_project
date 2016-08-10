//
//  PhotoDecorateTextData.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDecorateData.h"

@interface PhotoDecorateTextData : PhotoDecorateData

- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithText:(NSString *)text timestamp:(NSNumber *)timestamp;

@end
