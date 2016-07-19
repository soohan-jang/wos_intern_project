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
#import "PhotoEditorFrameViewCell.h"

@interface PhotoEditorViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet PhotoEditorCollectionView *collectionView;
@property (nonatomic) NSUInteger frameIndex;

- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;

- (IBAction)photoButtonAction:(id)sender;
- (IBAction)penButtonAction:(id)sender;
- (IBAction)textButtonAction:(id)sender;
- (IBAction)stickerButtonAction:(id)sender;
- (IBAction)eraserButtonAction:(id)sender;

- (void)addObservers;
- (void)removeObservers;

@end
