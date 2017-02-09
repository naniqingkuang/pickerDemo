//
//  ALLib.m
//  NaXin
//
//  Created by 猪猪 on 2017/2/4.
//  Copyright © 2017年 hzsd. All rights reserved.
//

#import "ALLib.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+PhotoFIxOrientation.h"

@implementation ALLib

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^
                  {
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}

//一个相册里面有多少个assets
+ (void)assetsInGroup:(id<MGGroupProtocol>) group WithBlock:(void(^)(NSArray<MGAssetProtocol>* assets)) callBlock {
    if (![group.group isKindOfClass:[ALAssetsGroup class]]) {
        return;
    }
    NSMutableArray *assets = [NSMutableArray array];
    ALAssetsGroupEnumerationResultsBlock result = ^(ALAsset *asset , NSUInteger index , BOOL *stop){
        if (asset) {
            MGPhotoAsset *m_asset = [MGPhotoAsset new];
            m_asset.asset = asset;
            [assets addObject:m_asset];
        }else{
            callBlock((NSArray<MGAssetProtocol>* )[NSArray arrayWithArray:assets]);
        }
    };
    [group.group enumerateAssetsUsingBlock:result];
}

//一个lib 里面有多少个group
+ (void)fetchLibGroupsWithBlock:(void(^)(NSArray<MGGroupProtocol>*)) callBlock {
    NSMutableArray *groups = [NSMutableArray array];
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
            MGPhotoGroup *m_group = [MGPhotoGroup new];
            m_group.group = group;
            [groups addObject:group];
        }else{
            callBlock((NSArray<MGGroupProtocol>*)[NSArray arrayWithArray:groups]);
        }
    };
    
    NSInteger type = ALAssetsGroupSavedPhotos;
    
    [[self defaultAssetsLibrary] enumerateGroupsWithTypes:type usingBlock:resultBlock failureBlock:nil];
}


//获取缩略图片
+ (void)fetchThumbImgWith:(id<MGAssetProtocol>) asset withBlock:(void(^)(UIImage *image)) callBlock {
    if (![asset.asset isKindOfClass:[ALAsset class]]) {
        return;
    }
    callBlock([UIImage imageWithCGImage:[asset.asset thumbnail] scale:0.0 orientation:UIImageOrientationUp]);

}

//获取原图
+ (void)fetchOriginImgWith:(id<MGAssetProtocol>) asset withBlock:(void(^)(UIImage *image)) callBlock {
    if (![asset.asset isKindOfClass:[ALAsset class]]) {
        return;
    }
    @autoreleasepool {
        UIImage* image1 = [self fullSizeImageForAssetRepresentation:((ALAsset *)asset.asset).defaultRepresentation highFlag:NO];
        CGImageRef  imageRef = image1.CGImage;
        float height = CGImageGetHeight(imageRef);
        if (height  >= [UIScreen mainScreen].bounds.size.height * 3 * 2) {  //(point * 3 )(像素) * 2(2倍屏幕)
            float defaultSize = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.height * 4 *2;
            long long  size = height*CGImageGetWidth(imageRef);
            __autoreleasing UIImage *image = [UIImage imageWithCGImage:imageRef scale:(double)size/(double)defaultSize orientation:(UIImageOrientation)[((ALAsset *)asset.asset).defaultRepresentation orientation]];
            imageRef = nil;
            callBlock([image fixOrientation]);
        }
        imageRef = nil;
        callBlock([image1 fixOrientation]);
        
    }
}


+(UIImage *)fullSizeImageForAssetRepresentation:(ALAssetRepresentation *)assetRepresentation highFlag:(BOOL)isHigh
{
    UIImage *result = nil;
    NSData *data = nil;
    
    uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t)*[assetRepresentation size]);
    if (buffer != NULL) {
        NSError *error = nil;
        NSUInteger bytesRead = [assetRepresentation getBytes:buffer fromOffset:0 length:[assetRepresentation size] error:&error];
        data = [NSData dataWithBytes:buffer length:bytesRead];
        
        free(buffer);
    }
    
    if ([data length])
    {
        CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        
        [options setObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceShouldAllowFloat];
        [options setObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceCreateThumbnailFromImageAlways];
        [options setObject:(id)[NSNumber numberWithFloat:[UIScreen mainScreen].scale * [UIScreen mainScreen].bounds.size.height*2] forKey:(id)kCGImageSourceThumbnailMaxPixelSize];
        //[options setObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceCreateThumbnailWithTransform];
        
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
        
        if (imageRef) {
            result = [UIImage imageWithCGImage:imageRef scale:[assetRepresentation scale] orientation:[assetRepresentation orientation]];
            CGImageRelease(imageRef);
        }
        
        if (sourceRef)
            CFRelease(sourceRef);
    }
    
    return result;
}


+ (void)saveImage:(UIImage *)image withBlock:(void(^)(id identify, BOOL success)) callBLock {
    if(image) {
        [[self defaultAssetsLibrary] writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            callBLock(assetURL, error == nil ? YES : NO);
        }];
    }

}

//根据标识符找到图片
+ (void)fetchImageWithIdetify:(id) identify andBlock:(void(^)(id asset)) callBLock {
    [[self defaultAssetsLibrary] assetForURL:identify resultBlock:^(ALAsset *asset) {
        callBLock(asset);
    } failureBlock:^(NSError *error) {
    
    }];
}

+ (BOOL)ifCanAccessPhotoLib {
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    
    if(author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}

//相机是否能有权限访问
+ (BOOL)ifCanAccessTakePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == ALAuthorizationStatusRestricted || authStatus ==ALAuthorizationStatusDenied)
    {
        return NO;
        //无权限
    }
    return YES;
}
@end
