//
//  MGPhotoAsset.m
//  NaXin
//
//  Created by 猪猪 on 2017/2/3.
//  Copyright © 2017年 hzsd. All rights reserved.
//

#import "MGPhotoAsset.h"
#import "ALLib.h"
#import "PHLib.h"

@implementation MGPhotoAsset

- (void)thumbImageWithBlock:(void(^)(UIImage *image)) callBlock {
    if ([self.asset isKindOfClass:[ALAsset class]]) {
        [ALLib fetchThumbImgWith:self withBlock:callBlock];
    } else if ([self.asset isKindOfClass:[PHAsset class]]) {
        [PHLib fetchThumbImgWith:self withBlock:callBlock];
    }
}


- (void)originImageWithBlock:(void(^)(UIImage *image)) callBlock {
    if ([self.asset isKindOfClass:[ALAsset class]]) {
        [ALLib fetchOriginImgWith:self withBlock:callBlock];
    } else if ([self.asset isKindOfClass:[PHAsset class]]) {
        [PHLib fetchOriginImgWith:self withBlock:callBlock];
    }
}

- (id)assetURL {
    if ([self.asset isKindOfClass:[ALAsset class]]) {
        return [[self.asset defaultRepresentation] url];
    } else if ([self.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = self.asset;
        return asset.localIdentifier;
    }
    return @"";

}


- (BOOL)isTheSameAsset:(MGPhotoAsset *)asset2{
    
    if (asset2 == nil) {
        return NO;
    }
    
    id url = self.assetURL;
    id url2 = asset2.assetURL;
    
    return [MGPhotoAsset isTheSameUrl:url andUrl2:url2];
}

+ (BOOL)isTheSameUrl:(id) url andUrl2:(id) url2 {
    if (url == nil || url2 == nil) {
        return NO;
    }
    
    if (![url2 isKindOfClass:[url class]] ) {
        return NO;
    }
    if ([url isKindOfClass:[NSString class]]) {
        if ([url isEqualToString:url2]) {
            return YES;
        } else {
            return NO;
        }
    } else if ([url isKindOfClass:[NSURL class]] ) {
        if ([url isEqual:url2]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;

}
@end
