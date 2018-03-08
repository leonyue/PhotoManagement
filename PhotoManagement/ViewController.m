//
//  ViewController.m
//  PhotoManagement
//
//  Created by km on 2018/3/8.
//  Copyright © 2018年 ly. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ALAuthorizationStatus authorStatus=[ALAssetsLibrary authorizationStatus];
    
    if (authorStatus != ALAuthorizationStatusAuthorized) {
        return;
    }
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
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
            NSLog(@"group:%@",group);
        }else{
            //group为nil时执行的操作，并停止迭代，回到主线程
//            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
        }
    } failureBlock:^(NSError *error) {
        //获取相册出错时，如该应用没有被授权访问相册时
        NSLog(@"错误Error:%@",error);
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
