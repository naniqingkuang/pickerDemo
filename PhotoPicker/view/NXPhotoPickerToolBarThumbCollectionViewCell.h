//
//  ZLPhotoPickerFootCollectionVewCellCollectionViewCell.h
//  NaXin
//
//  Created by HZSD on 16/3/21.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^deleteBlock_t)(NSInteger);
@interface NXPhotoPickerToolBarThumbCollectionViewCell : UICollectionViewCell
@property (nonatomic, copy) deleteBlock_t deleteBlock;
@property (weak, nonatomic)IBOutlet UIImageView *imageView;
@property (assign, nonatomic) NSInteger index;
@end
