//
//  ViewController.m
//  PhotoManagement
//
//  Created by km on 2018/3/8.
//  Copyright © 2018年 ly. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "PhotoGroupCollectionViewCell.h"
#import "ALAsset+RequestDefaultRepresentation.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate>

@property (nonatomic, copy) NSMutableArray<ALAssetsGroup *> *groups;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChangedNotif:) name:ALAssetsLibraryChangedNotification object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
}

#pragma mark - private
- (void)refresh {
    ALAuthorizationStatus authorStatus=[ALAssetsLibrary authorizationStatus];
    
    if (authorStatus != ALAuthorizationStatusAuthorized) {
        return;
    }
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    self.assetsLibrary = assetsLibrary;
    //通过URL地址获取在相册中ALAsset，该方法是异步的
    [assetsLibrary assetForURL:[NSURL URLWithString:@""] resultBlock:^(ALAsset *asset) {
        NSLog(@"asset:%@",asset);
        //成功返回ALAsset
    } failureBlock:^(NSError *error) {
        NSLog(@"error:%@",error);
        //获取失败
    }];
    //通过URL地址获取相册ALAssetsGroup，该方法是异步的
    [assetsLibrary groupForURL:[NSURL URLWithString:@""] resultBlock:^(ALAssetsGroup *group) {
        //成功返回ALAssetsGroup
        NSLog(@"group:%@",group);
    } failureBlock:^(NSError *error) {
        NSLog(@"error:%@",error);
        //获取失败
    }];
    
    NSMutableArray *arrayAssetsGroup=[[NSMutableArray alloc]init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            //group不为nil执行的操作，并将继续迭代下去
            [arrayAssetsGroup addObject:group];
        }else{
            self.groups = arrayAssetsGroup;
            [self.collectionView reloadData];
            //group为nil时执行的操作，并停止迭代，回到主线程
            //            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
        }
    } failureBlock:^(NSError *error) {
        //获取相册出错时，如该应用没有被授权访问相册时
        NSLog(@"错误Error:%@",error);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.groups.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoGroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell0" forIndexPath:indexPath];
    ALAssetsGroup *group = self.groups[indexPath.item];
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        UIImage *image = [UIImage imageWithCGImage:[result aspectRatioThumbnail]];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = image;
            });
            *stop = YES;
        }

    }];
//
    cell.label.text  = [group valueForProperty:ALAssetsGroupPropertyName];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = self.groups[indexPath.item];
    NSString *title = [group valueForProperty:ALAssetsGroupPropertyName];
    NSUInteger number = group.numberOfAssets;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:[NSString stringWithFormat:@"%ld张照片",number]
                                                   delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"下载", nil];
    alert.tag = indexPath.item;
    [alert show];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat width = (screenSize.width - 20 * 5) / 4.f;
    return CGSizeMake(width, width + 20);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        ALAssetsGroup *group = self.groups[alertView.tag];
        dispatch_group_t group_t = dispatch_group_create();
        
        NSMutableArray<NSURL *> *urls = [NSMutableArray new];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            id type = [result valueForProperty:ALAssetPropertyType];
            [result requestDefaultRepresentation];
//            NSURL *url = [result defaultRepresentation].url;
//            NSLog(@"type is %@, url is %@",type,url);
//            if (url != nil) {
//                NSLog(@"added");
//                [urls addObject:url];
//            } else {
//            }
        }];
        NSLog(@"end");
        return;
        for (NSUInteger i =0; i<urls.count; i++) {
            NSURL *url = urls[i];
            dispatch_group_async(group_t, dispatch_get_main_queue(), ^{
                dispatch_group_enter(group_t);
                [self.assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                    
                    ALAssetRepresentation *image_representation = [asset defaultRepresentation];
                    Byte *buffer = (Byte*)malloc(image_representation.size);
                    NSUInteger length = [image_representation getBytes:buffer fromOffset: 0.0 length:image_representation.size error:nil];
                    if (length != 0)  {
                        NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:image_representation.size freeWhenDone:YES];
                        
                        
                        [self.assetsLibrary writeImageDataToSavedPhotosAlbum:adata metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                            NSLog(@"writeImageData error:%@",error);
                            dispatch_group_leave(group_t);
                        }];
                    } else {
                        NSLog(@"length = 0");
                        dispatch_group_leave(group_t);
                    }
                } failureBlock:^(NSError *error) {
                    NSLog(@"failure:%@",error);
                    dispatch_group_leave(group_t);
                }];
            });
        }
        return;

        
    }
}

static int kkkk = 0;
- (void)assetsLibraryChangedNotif:(NSNotification *)notif {
    kkkk ++;
    NSLog(@"kkkk:%ld",kkkk);
//    NSLog(@"notif:%@",notif)2;
}
@end
