//
//  MGPhotoLibProtocol.h
//  NaXin
//
//  Created by 猪猪 on 2017/2/3.
//  Copyright © 2017年 hzsd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAssetProtocol.h"
#import "MGGroupProtocol.h"

@protocol MGPhotoLibProtocol <NSObject>

@required
//一个相册里面有多少个assets
+ (void)assetsInGroup:(id<MGGroupProtocol>) group WithBlock:(void(^)(NSArray<MGAssetProtocol>* assets)) callBlock;


//存入图片
+ (void)saveImage:(UIImage *)image withBlock:(void(^)(id identify, BOOL success)) callBLock;


//一个lib 里面有多少个group
+ (void)fetchLibGroupsWithBlock:(void(^)(NSArray<MGGroupProtocol>*)) callBlock;

//获取缩略图片
+ (void)fetchThumbImgWith:(id<MGAssetProtocol>) asset withBlock:(void(^)(UIImage *image)) callBlock;

//获取原图
+ (void)fetchOriginImgWith:(id<MGAssetProtocol>) asset withBlock:(void(^)(UIImage *image)) callBlock;


//根据标识符找到图片
+ (void)fetchImageWithIdetify:(id) identify andBlock:(void(^)(id asset)) callBLock;


+ (BOOL)ifCanAccessPhotoLib;

//相机是否能有权限访问
+ (BOOL)ifCanAccessTakePhoto;


+ (NSInteger)imageCountInGroup:(id <MGGroupProtocol>) group;
@end
