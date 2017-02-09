//
//  PickerCollectionViewCell.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "NXPhotoPickerCollectionViewCell.h"

static NSString *const _cellIdentifier = @"cell";

@implementation NXPhotoPickerCollectionViewCell

+ (instancetype) cellWithCollectionView : (UICollectionView *) collectionView cellForItemAtIndexPath:(NSIndexPath *) indexPath withIndentify:(NSString *)idStr {
    NXPhotoPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:idStr forIndexPath:indexPath];

    if ([[cell.contentView.subviews lastObject] isKindOfClass:[UIImageView class]]) {
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    
    return cell;
}
- (NXPhotoPickerImageView *)ImageView {
    if(!_ImageView) {
        _ImageView = [[NXPhotoPickerImageView alloc]initWithFrame:self.bounds];
        [self addSubview:_ImageView];
    }
    return _ImageView;
}

@end
