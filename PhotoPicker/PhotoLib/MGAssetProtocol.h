//
//  MGAssetProtocol.h
//  NaXin
//
//  Created by 猪猪 on 2017/2/3.
//  Copyright © 2017年 hzsd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MGAssetProtocol <NSObject>


@property (nonatomic, strong) id asset;

- (BOOL)isTheSameAsset:(id)asset2;

+ (BOOL)isTheSameUrl:(id) url andUrl2:(id) url2;

/**
 *  获取图片的URL
 */
- (id)assetURL;

//唯一标识符是否相等

//缩略图
- (void)thumbImageWithBlock:(void(^)(UIImage *image)) callBlock;

//原图
- (void)originImageWithBlock:(void(^)(UIImage *image)) callBlock;
@end
