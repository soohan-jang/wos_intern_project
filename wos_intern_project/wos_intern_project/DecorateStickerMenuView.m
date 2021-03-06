//
//  PhotoStickerMenuView.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateStickerMenuView.h"

#import "DecorateStickerViewCell.h"

#import "ColorUtility.h"
#import "ImageUtility.h"

NSInteger const StickerItemNumber = 40;

typedef NS_ENUM(NSInteger, StickerColorMenuItem) {
    StickerColorBlack  = 0,
    StickerColorRed    = 1,
    StickerColorGreen  = 2,
    StickerColorBlue   = 3,
    StickerColorYellow = 4,
    StickerClose  = 5
};

@interface DecorateStickerMenuView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *defaultStickerColorButton;
@property (strong, nonatomic) UIButton *prevSelectedStickerColorButton;
@property (strong, nonatomic) UIColor *stickerColor;

@end

@implementation DecorateStickerMenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialize];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden)
        return;
    
    //hidden NO가 되어 화면에 나타날 때, StickerMenuView를 초기화한다.
    self.prevSelectedStickerColorButton = self.defaultStickerColorButton;
    [self.prevSelectedStickerColorButton setSelected:YES];
    self.stickerColor = [ColorUtility colorWithName:ColorNameDarkGray];
    
    [self.collectionView reloadData];
}

- (void)initialize {
    self.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent];
    self.collectionView.backgroundColor = [ColorUtility colorWithName:ColorNameTransparent4f];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}


#pragma mark - EventHandler Methods

- (IBAction)tappedStickerColorButton:(UIButton *)sender {
    if (self.prevSelectedStickerColorButton) {
        [self.prevSelectedStickerColorButton setSelected:NO];
    }
    
    if (sender.tag != StickerClose) {
        self.prevSelectedStickerColorButton = sender;
        [self.prevSelectedStickerColorButton setSelected:YES];
    }
    
    switch (sender.tag) {
        case StickerColorBlack:
            self.stickerColor = [ColorUtility colorWithName:ColorNameDarkGray];
            break;
        case StickerColorRed:
            self.stickerColor = [ColorUtility colorWithName:ColorNameRed];
            break;
        case StickerColorGreen:
            self.stickerColor = [ColorUtility colorWithName:ColorNameGreen];
            break;
        case StickerColorBlue:
            self.stickerColor = [ColorUtility colorWithName:ColorNameBlue];
            break;
        case StickerColorYellow:
            self.stickerColor = [ColorUtility colorWithName:ColorNameYellow];
            break;
        case StickerClose:
            [self.delegate decorateStickerMenuViewDidFinish];
            return;
    }
    
    [self.collectionView reloadData];
}


#pragma mark - CollectionView DataSource Delegate Methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DecorateStickerViewCell *cell = (DecorateStickerViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DecorateStickerViewCell class])
                                                                                                   forIndexPath:indexPath];
    
    UIImage *image = [UIImage imageNamed:[ImageUtility photoStickerImageWithIndex:indexPath.item]];
    cell.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if (!self.stickerColor) {
        self.stickerColor = [ColorUtility colorWithName:ColorNameDarkGray];
    }
    
    cell.imageView.tintColor = self.stickerColor;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return StickerItemNumber;
}


#pragma mark - CollectionView FlowLayout Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = [ImageUtility coloredImageNamed:[ImageUtility photoStickerImageWithIndex:indexPath.item]
                                               color:self.stickerColor];
    
    PEDecorate *data = [[PEDecorate alloc] initWithImage:image];
    [self.delegate decorateStickerMenuViewDidSelectItem:data];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.bounds.size.width / 4 - (10 * 3);
    return CGSizeMake(width, width);
}

@end