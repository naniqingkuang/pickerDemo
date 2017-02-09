//
//  PhotoManager.m
//  NaXin
//
//  Created by 猪猪 on 2017/2/3.
//  Copyright © 2017年 hzsd. All rights reserved.
//

#import "PhotoManager.h"
#import "PHLib.h"
#import "ALLib.h"

#define ios8x ([[[UIDevice currentDevice] systemVersion ] floatValue] >= 8.0)

@implementation PhotoManager
//一个相册里面有多少个assets
+ (void)assetsInGroup:(id<MGGroupProtocol>) group WithBlock:(void(^)(NSArray<MGAssetProtocol>* assets)) callBlock {
    
    if (ios8x) {
        [PHLib assetsInGroup:group WithBlock:callBlock];
    } else {
        [ALLib assetsInGroup:group WithBlock:callBlock];
    }
}

//一个lib 里面有多少个group
+ (void)fetchLibGroupsWithBlock:(void(^)(NSArray<MGGroupProtocol>*)) callBlock {
    if (ios8x) {
        [PHLib fetchLibGroupsWithBlock:callBlock];
    } else {
        [ALLib fetchLibGroupsWithBlock:callBlock];

    }
}


+ (void)fetchThumbImgWith:(id<MGAssetProtocol>) asset withBlock:(void(^)(UIImage *image)) callBlock {
    if (ios8x) {
        [PHLib fetchThumbImgWith:asset withBlock:callBlock];
    } else {
        [ALLib fetchThumbImgWith:asset withBlock:callBlock];

    }
}


//获取原图
+ (void)fetchOriginImgWith:(id<MGAssetProtocol>) asset withBlock:(void(^)(UIImage *image)) callBlock {
    if (ios8x) {
        [PHLib fetchOriginImgWith:asset withBlock:callBlock];
    } else {
        [ALLib fetchOriginImgWith:asset withBlock:callBlock];
        
    }

}

//存入图片
+ (void)saveImage:(UIImage *)image withBlock:(void(^)(id identify, BOOL success)) callBLock {
    if (ios8x) {
        [PHLib saveImage:image withBlock:callBLock];
    } else {
        [ALLib saveImage:image withBlock:callBLock];
        
    }

}

+ (void)fetchImageWithIdetify:(id) identify andBlock:(void(^)(id asset)) callBLock {
    if (ios8x) {
        [PHLib fetchImageWithIdetify:identify andBlock:callBLock];
    } else {
        [ALLib fetchImageWithIdetify:identify andBlock:callBLock];

    }
}


+ (BOOL)ifCanAccessPhotoLib {
    
    if (ios8x) {
       return  [PHLib ifCanAccessPhotoLib];
    } else {
       return  [ALLib ifCanAccessPhotoLib];
        
    }
    return YES;
}

//相机是否能有权限访问
+ (BOOL)ifCanAccessTakePhoto {
    if (ios8x) {
        return [PHLib ifCanAccessTakePhoto];
    } else {
       return  [ALLib ifCanAccessTakePhoto];
        
    }
    return YES;

}

+ (NSInteger)imageCountInGroup:(id <MGGroupProtocol>) group  {
    if (ios8x) {
       return [PHLib imageCountInGroup:group];
    } else {
       return [ALLib imageCountInGroup:group];
    }
    return 0;
}
@end
