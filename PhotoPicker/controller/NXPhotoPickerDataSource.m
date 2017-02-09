 //
//  NXPhotoPickerDataSource.m
//  NaXin
//
//  Created by 猪猪 on 16/4/6.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import "NXPhotoPickerDataSource.h"
#import "PhotoManager.h"

@interface NXPhotoPickerDataSource()
@property (nonatomic, assign) NSInteger type;
@end

@implementation NXPhotoPickerDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self getAllGroup:NXPickerViewShowStatusAllPhotos withFinishBlock:nil];
    }
    return self;
}
- (NSArray<MGPhotoGroup*>*)getAllGroup:(NXPickerViewShowStatus)type
                            withFinishBlock:(void(^)(NSArray<MGPhotoGroup*>*)) block {
    self.type = type;
    if(!(self.groups && self.groups.count)) {
        if (type == NXPickerViewShowStatusAllPhotos){
            [PhotoManager fetchLibGroupsWithBlock:^(NSArray<MGGroupProtocol> *arr) {
                self.groups = arr;
                if(block) {
                    block(self.groups);
                }
            }];
        }

    }
    if(block){
        block(self.groups);
    }
    return self.groups;
}


//获取图片assets
- (void)getAsssets:(MGPhotoGroup *)group withFinishBlock:(void(^)(NSArray<MGPhotoAsset*>*)) block {
    __block NSMutableArray *assetsM = [NSMutableArray array];    
    [PhotoManager assetsInGroup:group WithBlock:^(NSArray<MGAssetProtocol> *assets) {
        if (block) {
            block(assets);
        }
    }];
}
//- (void)translateToChinese:(NXPickerViewShowStatus)type {
//    // 如果是相册
//    for (NXPhotoPickerGroup *group in self.groups) {
//        if ((type == NXPickerViewShowStatusCameraRoll || type == NXPickerViewShowStatusVideo) && ([group.groupName isEqualToString:@"Camera Roll"] || [group.groupName isEqualToString:@"相机胶卷"])) {
//            group.groupName = @"相机胶卷";
//            self.currentGroup = group;
//            break;
//        }else if (type == NXPickerViewShowStatusSavePhotos && ([group.groupName isEqualToString:@"Saved Photos"] || [group.groupName isEqualToString:@"保存相册"])){
//            group.groupName = @"保存相册";
//            break;
//        }else if (type == NXPickerViewShowStatusPhotoStream &&  ([group.groupName isEqualToString:@"Stream"] || [group.groupName isEqualToString:@"我的照片流"])){
//            group.groupName = @"我的照片流";
//            break;
//        } else if ([group.groupName isEqualToString:@"所有照片"] || [group.groupName isEqualToString:@"All Photos"]) {
//            group.groupName = @"所有照片";
//            self.currentGroup = group;
//            break;
//        }
//    }
//}
- ( NSArray *)getOutSideAseet:(NSArray *)allAseet
        withPreSelectedAseets:(NSArray *)preSelectedData{
    NSMutableArray<MGPhotoAsset*> *arr = (NSMutableArray<MGPhotoAsset*> *)[NSMutableArray arrayWithCapacity:20];
    [arr addObjectsFromArray:preSelectedData];
    for (MGPhotoAsset *temp in preSelectedData) {
        for (MGPhotoAsset *aseet in allAseet) {
            if ([aseet  isTheSameAsset:temp]) {
                [arr removeObject:temp];
                break;
            }
        }
    }
    return arr;
}


- (void)writeToLibImage:(UIImage *)image
              withBlock:(void(^)(id assetURL)) block {
    
   [PhotoManager saveImage:image withBlock:^(id identify, BOOL success) {
       if (success) {
           block(identify);
       }
   }];
}
@end
