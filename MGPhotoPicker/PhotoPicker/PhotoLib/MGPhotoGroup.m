//
//  MGPhotoGroup.m
//  NaXin
//
//  Created by 猪猪 on 2017/2/3.
//  Copyright © 2017年 hzsd. All rights reserved.
//

#import "MGPhotoGroup.h"
#import "PHLib.h"
#import "ALLib.h"

@implementation MGPhotoGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assetsCount = 0;
    }
    return self;
}
- (NSString *)groupName {
    if ([self.group isKindOfClass:[PHAssetCollection class]]) {
        PHAssetCollection *group = self.group;
        return group.localizedTitle;
    } else if ([self.group isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = self.group;
        return [group valueForProperty:@"ALAssetsGroupPropertyName"];
    }
    return @"";
}

- (UIImage *)thumbImageWIthBlock:(void(^)(UIImage *thumbImage)) callBlock {
    if ([self.group isKindOfClass:[PHAssetCollection class]]) {
        PHAssetCollection *group = self.group;
       PHFetchResult *res = [PHAsset fetchAssetsInAssetCollection:group options:nil];
        if (res.count) {
            PHAsset *firstAsset = res[0];
            MGPhotoAsset *asset = [MGPhotoAsset new];
            asset.asset = firstAsset;
            [PHLib fetchThumbImgWith:asset withBlock:callBlock];
        }
        
    } else if ([self.group isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = self.group;
        callBlock([UIImage imageWithCGImage:[group posterImage]]);
    }
    return [UIImage new];

}

- (NSInteger)assetsCount {
    if ([self.group isKindOfClass:[PHAssetCollection class]]) {
        return [PHLib imageCountInGroup:self];
    } else if ([self.group isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = self.group;
        return [group numberOfAssets];
    }
    return 0;
}

@end
