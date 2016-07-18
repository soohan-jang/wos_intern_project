//
//  PhotoEditorViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "PhotoEditorCollectionView.h"

@interface PhotoEditorViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet PhotoEditorCollectionView *collectionView;

- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;

- (void)addObservers;
- (void)removeObservers;

- (void)setFrameIndex:(NSUInteger)frameIndex;

@end
