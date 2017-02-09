//
//  PhotoPickerHeadView.h
//  NaXin
//
//  Created by 猪猪 on 2016/10/27.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPickerHeadView : UICollectionReusableView
@property (nonatomic, copy) void (^selectedBlock)(NSInteger index);
@end
