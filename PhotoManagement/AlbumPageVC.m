//
//  AlbumPageVC.m
//  PhotoManagement
//
//  Created by km on 2018/3/9.
//  Copyright © 2018年 ly. All rights reserved.
//

#import "AlbumPageVC.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AlbumPageVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<ALAsset *> *raw_asserts;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation AlbumPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.raw_asserts = [NSMutableArray new];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                [weakSelf.raw_asserts addObject:result];
            }
        }];
        [weakSelf.collectionView reloadData];
    });

}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.raw_asserts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell0" forIndexPath:indexPath];
    UIImageView *iv = [cell viewWithTag:123];
    ALAsset *raw = self.raw_asserts[indexPath.item];
    iv.image = [UIImage imageWithCGImage:raw.aspectRatioThumbnail];
    ALAssetRepresentation *rep = [raw defaultRepresentation];
    if (rep != nil) {
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat width = (screenSize.width - 1.f * 3) / 4.f;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}

@end
