//
//  NXPhotoPickerBrowserView.h
//  NaXin
//
//  Created by 猪猪 on 16/4/6.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^tapActionBlock_t) (void);
@interface NXPhotoPickerBrowserView : UIScrollView
//当前选中的图片序号
- (void)setIndex:(NSInteger)index;
//数据源
@property (nonatomic, strong) NSArray *arrData;

//轻拍block
@property (nonatomic, copy) tapActionBlock_t tapActionBlock;
@end
