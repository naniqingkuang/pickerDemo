//
//  PickerImageView.h
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^buttonClickedBlock_t) (void);
@interface NXPhotoPickerImageView : UIImageView

/**
 *  是否有蒙版层 (Abei - 通过外部是否为编辑状态来控制是否有蒙版)
 */
@property (nonatomic , assign , getter=isMaskViewFlag) BOOL maskViewFlag;
/**
 *  蒙版层的颜色,默认白色
 */
@property (nonatomic , strong) UIColor *maskViewColor;
/**
 *  蒙版的透明度,默认 0.5
 */
@property (nonatomic , assign) CGFloat maskViewAlpha;
/**
 *  是否有右上角打钩的按钮
 */
@property (nonatomic , assign) BOOL animationRightTick;
/**
 *  是否视频类型
 */
@property (assign,nonatomic) BOOL isVideoType;
//右上角的角标数量
@property (nonatomic, assign) NSInteger count;

/**
 * cell的IndexPath 用来标记右上角图片是否被点击
 */
@property (nonatomic, copy) buttonClickedBlock_t buttonBlock;


@end
