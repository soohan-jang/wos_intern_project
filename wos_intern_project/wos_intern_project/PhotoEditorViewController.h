//
//  PhotoEditorViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "PhotoEditorFrameViewCell.h"

@interface PhotoEditorViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSUInteger frameIndex;

- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;

- (void)setupUI:(NSInteger)frameIndex;

@end
