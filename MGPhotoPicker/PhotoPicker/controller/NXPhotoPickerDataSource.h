//
//  NXPhotoPickerDataSource.h
//  NaXin
//
//  Created by 猪猪 on 16/4/6.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPhotoGroup.h"
#import "MGPhotoAsset.h"

// 状态组
typedef NS_ENUM(NSInteger , NXPickerViewShowStatus) {
    NXPickerViewShowStatusGroup = 0, // default groups .
    NXPickerViewShowStatusCameraRoll ,
    NXPickerViewShowStatusSavePhotos ,
    NXPickerViewShowStatusPhotoStream ,
    NXPickerViewShowStatusVideo,
    NXPickerViewShowStatusAllPhotos,
};
@interface NXPhotoPickerDataSource : NSObject

@property (strong, nonatomic) MGPhotoGroup *currentGroup; //当前的图片组
@property (strong, nonatomic) NSArray *currentGroupAsseets; //当前的图片组所有的图片
@property (nonatomic, strong) NSArray<MGGroupProtocol> *groups;

//获取所有的图片Group
- (NSArray<MGGroupProtocol>*)getAllGroup:(NXPickerViewShowStatus)type withFinishBlock:(void(^)(NSArray<MGGroupProtocol>*)) block;

//根据group 获取 assets
- (void)getAsssets:(MGPhotoGroup *)group withFinishBlock:(void(^)(NSArray<MGPhotoAsset *>*)) block;
//获取选中图片中不在此组中的assets
- ( NSArray<MGPhotoAsset *> *)getOutSideAseet:(NSArray *)allAseet withPreSelectedAseets:(NSArray *)preSelectedData;

- (void)writeToLibImage:(UIImage *)image
              withBlock:(void(^)(id assetURL)) block;
@end
