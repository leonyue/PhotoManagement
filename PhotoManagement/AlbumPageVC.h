//
//  AlbumPageVC.h
//  PhotoManagement
//
//  Created by km on 2018/3/9.
//  Copyright © 2018年 ly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;
@class ALAssetsLibrary;
@interface AlbumPageVC : UIViewController

@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end
