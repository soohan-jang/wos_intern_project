//
//  PhotoEditorViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoEditorViewController : UIViewController

/**
 선택된 사진 액자를 전달한다. 파라메터는 NSInteger로 선택된 사진 액자의 indexPath.item을 받는다.
 전달된 indexPath.item의 값에 따라 정해진 사진 액자를 구성하도록 설정한다.
 */
- (void)setPhotoFrameNumber:(NSInteger)frameNumber;

@end
