//
//  NXPKGroupTableViewCell.h
//  NaXin
//
//  Created by 猪猪 on 2016/11/1.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MGPhotoGroup;

@interface NXPKGroupTableViewCell : UITableViewCell
/**
 *  赋值xib
 */
@property (nonatomic , strong) MGPhotoGroup *group;

+ (instancetype) instanceCell;
@end
