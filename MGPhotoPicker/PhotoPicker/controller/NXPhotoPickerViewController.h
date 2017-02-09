//
//  NXPhotoPickerViewController.h
//  NaXin
//
//  Created by 猪猪 on 16/4/6.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGPhotoGroup.h"

typedef NS_ENUM(NSInteger, NXPhotoPickerShowOrder) {   //排序
    NXPhotoPickerShowOrderDesc, //降序,最新的排在前面
    NXPhotoPickerShowOrderAsc    //升序，最新的排在后面
};

typedef NS_ENUM(NSInteger, NXPhotoStyle){
    NXPhotoStyleNormal, //正常的很色背景,隐藏status bar
    NXPhotoStyleCloud, // 正常的f2f2f2 的背景色， 有status bar
    NXPhotoStyleNaXinPhoto
};

//协议
@class NXPhotoPickerViewController;

@protocol NXPhotoPickerControllerDelegate <NSObject>
@required
- (void)PickerView:(NXPhotoPickerViewController *)photoPicker doneWithResult:(NSArray *)data;
@optional
- (void)PickerViewBack:(NXPhotoPickerViewController *)photoPicker;
- (void)PickerViewGoFarward:(NXPhotoPickerViewController *)photoPicker;

@end





@interface NXPhotoPickerViewController : UIViewController
//排序
@property (nonatomic, assign) NXPhotoPickerShowOrder showOrder; //默认升序排列
//最大的选中数量
@property (nonatomic, assign) NSInteger maxSelectedNum;  //默认9张
//最小的选中数量
@property (nonatomic, assign) NSInteger minSelectedNum;
//已经选择的数量
@property (nonatomic, assign) NSInteger alreadySelectedNum; // 已经选择的数量
//预先选择的图片
@property (nonatomic, strong) NSMutableArray *arrPreSelected;
//结果
@property (nonatomic, strong, readonly) NSMutableArray *selectAsstes;
//结果的代理方法
@property (nonatomic, weak) id<NXPhotoPickerControllerDelegate> aseetDelegate;
//刷新数据
- (void)refreshUI;

//清除数据
- (void)clearData;

@property (nonatomic, assign) NXPhotoStyle style;

+ (NXPhotoPickerViewController *)getNXPhotoPickerVC;
@end
