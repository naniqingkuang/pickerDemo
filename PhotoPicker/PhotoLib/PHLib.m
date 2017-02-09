//
//  PHLib.m
//  NaXin
//
//  Created by 猪猪 on 2017/2/3.
//  Copyright © 2017年 hzsd. All rights reserved.
//

#import "PHLib.h"


@interface PHLib()

@end



@implementation PHLib

+ (PHCachingImageManager *)imageCatcher {
    static PHCachingImageManager *imageCachingManager = nil;
    if (imageCachingManager == nil) {
        imageCachingManager = [PHCachingImageManager new];
    }
    return imageCachingManager;
}

//一个相册里面有多少个assets
+ (void)assetsInGroup:(id<MGGroupProtocol>) group WithBlock:(void(^)(NSArray<MGAssetProtocol>* assets)) callBlock {
    if (![group.group isKindOfClass:[PHCollection class]]) {
        return;
    }
    
    PHFetchOptions *option = [PHFetchOptions new];
    PHFetchResult * res = [PHAsset fetchAssetsInAssetCollection:group.group options:nil];
    NSMutableArray *array = [NSMutableArray new];
    for (PHAsset *asset in res) {
        MGPhotoAsset *m_asset = [MGPhotoAsset new];
        m_asset.asset = asset;
        [array addObject:m_asset];
    }
    
    if (callBlock && array.count) {
        callBlock((NSArray<MGAssetProtocol>*) [NSArray arrayWithArray:array]);
    }
    
}

//一个lib 里面有多少个group
+ (void)fetchLibGroupsWithBlock:(void(^)(NSArray<MGGroupProtocol>*)) callBlock {
    PHFetchOptions *options = [PHFetchOptions new];
    //系统的相册
     PHFetchResult *res =[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    //自己建的相册
    PHFetchResult *res1 =[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    
    
    
    NSMutableArray *groups = [NSMutableArray new];
    for (PHCollection *collection in res) {
        MGPhotoGroup *group = [MGPhotoGroup new];
        group.group = collection;
        [groups addObject:group];
    }
    
    for (PHCollection *collection in res1) {
        MGPhotoGroup *group = [MGPhotoGroup new];
        group.group = collection;
        [groups addObject:group];
    }
    
    if (callBlock && groups.count) {
        callBlock((NSArray<MGGroupProtocol>*)[NSArray arrayWithArray:groups]);
    }
}


+ (void)fetchThumbImgWith:(id<MGAssetProtocol>) asset withBlock:(void(^)(UIImage *image)) callBlock {
    if (![asset.asset isKindOfClass:[PHAsset class]]) {
        return;
    }
    [[self imageCatcher] requestImageForAsset:asset.asset targetSize:CGSizeMake(120, 120) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            callBlock(result);
        }
    }];
}

+ (void)fetchOriginImgWith:(id<MGAssetProtocol>) asset withBlock:(void(^)(UIImage *image)) callBlock {
    if (![asset.asset isKindOfClass:[PHAsset class]]) {
        return;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    [[self imageCatcher] requestImageForAsset:asset.asset targetSize:CGSizeMake(size.width * 2, size.width * 2) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            callBlock(result);
        }
    }];
}

+ (void)saveImage:(UIImage *)image withBlock:(void(^)(id identify, BOOL success)) callBLock {
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        assetID = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        callBLock(assetID, success);
    }];
}

//根据标识符找到图片
+ (void)fetchImageWithIdetify:(id) identify andBlock:(void(^)(id asset)) callBLock {
    PHFetchResult *assets = [PHAsset fetchAssetsWithBurstIdentifier:identify options:nil];
    callBLock(assets[0]);
}


+ (BOOL)ifCanAccessPhotoLib {
    
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    
    if(author == PHAuthorizationStatusRestricted || author== PHAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}

//相机是否能有权限访问
+ (BOOL)ifCanAccessTakePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        return NO;
        //无权限
    }
    return YES;
}

+ (NSInteger)imageCountInGroup:(id <MGGroupProtocol>) group {
    if ([group conformsToProtocol:NSProtocolFromString(@"MGGroupProtocol")]) {
       PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:group.group options:nil];
        return result.count;
    }
    return 0;
}
@end
