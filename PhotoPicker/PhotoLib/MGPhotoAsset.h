//
//  MGPhotoAsset.h
//  NaXin
//
//  Created by 猪猪 on 2017/2/3.
//  Copyright © 2017年 hzsd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAssetProtocol.h"

@interface MGPhotoAsset : NSObject <MGAssetProtocol>
@property (nonatomic, strong) id asset;
- (id)assetURL;


//add by lmz 本地使用跟库无关
/**
 *  记录被选择的次序计数
 */
@property (nonatomic, assign) NSInteger selectedIndex;

//originImage 用的是否是高清图压缩的
@property (assign, nonatomic) BOOL isHigh;

//是否被选中
@property (assign, nonatomic) BOOL isSeleceted;
//记录selected 次数
@property (nonatomic, assign) NSInteger selectedCount;
@end
