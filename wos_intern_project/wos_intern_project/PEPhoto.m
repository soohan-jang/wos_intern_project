//
//  PhotoData.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PEPhoto.h"

@implementation PEPhoto

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.state = 0;
        self.originalImage = nil;
        self.croppedImage = nil;
        self.filterType = 0;
    }
    
    return self;
}

@end
