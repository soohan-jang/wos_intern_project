//
//  PhotoEditorFrameCellData.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorFrameCellData.h"

@implementation PhotoEditorFrameCellData

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.state = 0;
        self.fullscreenImage = nil;
        self.croppedImage = nil;
    }
    
    return self;
}

@end
