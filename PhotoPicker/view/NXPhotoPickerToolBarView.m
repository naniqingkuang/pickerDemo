//
//  NXPhotoPickerToolView.m
//  NXPhotoPickerTest
//
//  Created by HZSD on 16/3/22.
//  Copyright © 2016年 HZSD. All rights reserved.
//

#import "NXPhotoPickerToolBarView.h"
#import "NXPhotoPickerToolBarThumbCollectionViewCell.h"
#import "MGPhotoAsset.h"
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";

@implementation NXPhotoPickerToolBarView
- (void)awakeFromNib {
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        UINib *nib = [UINib nibWithNibName:@"NXPhotoPickerToolBarThumbCollectionViewCell" bundle:[NSBundle mainBundle]];
        [self registerNib:nib forCellWithReuseIdentifier:_identifier];
    }

}
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        UINib *nib = [UINib nibWithNibName:@"NXPhotoPickerToolBarThumbCollectionViewCell" bundle:[NSBundle mainBundle]];
        [self registerNib:nib forCellWithReuseIdentifier:_identifier];
    }
    return self;
}


#pragma mark 代理 和 datasource
#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrDataSource.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NXPhotoPickerToolBarThumbCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    if(self.arrDataSource.count > indexPath.row) {
        if ([self.arrDataSource[indexPath.row] isKindOfClass:[NXPhotoAssets class]]) {
            cell.imageView.image = [self.arrDataSource[indexPath.item] aspectRatioImage];
        }else if ([self.arrDataSource[indexPath.item] isKindOfClass:[UIImage class]]){
            cell.imageView.image = (UIImage *)self.arrDataSource[indexPath.item];
        }
        cell.index = indexPath.row;
        //删除的处理方法
        __weak typeof(cell) weakCell = cell;
        cell.deleteBlock = ^(NSInteger num) {
            if (self.toolBarDelegate) {
                [_toolBarDelegate toolBarView:self didDeleteItemAtIndexPath:weakCell.index];
                [self reloadData];
            }
        };
    }
    return cell;
}


#pragma mark UICollectionViewDelegate
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.toolBarDelegate toolBarView:self didSelectItemAtIndexPath:indexPath];
//    ZLPhotoPickerBrowserViewController *browserVc = [[ZLPhotoPickerBrowserViewController alloc] init];
//    //    browserVc.toView = [cell.contentView.subviews lastObject];
//    browserVc.currentIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
//    //    browserVc.editing = YES;
//    browserVc.delegate = self;
//    browserVc.dataSource = self;
//    [[self myViewController] presentViewController:browserVc animated:NO completion:nil];
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return self.arrDataSource.count;
}

-  (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    ZLPhotoPickerBrowserPhoto *photo = [[ZLPhotoPickerBrowserPhoto alloc] init];
    NXPhotoPickerToolBarThumbCollectionViewCell *cell = (NXPhotoPickerToolBarThumbCollectionViewCell*)[self cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = cell.imageView;
    if (self.arrDataSource.count && self.arrDataSource.count - 1 >= indexPath.item) {
        NXPhotoAssets *asset = (NXPhotoAssets*)self.arrDataSource[indexPath.row];
        //imageView.image = asset.originImage;
        if ([asset isKindOfClass:[NXPhotoAssets class]]) {
            photo.thumbImage = asset.originImage;
            photo.asset = self.arrDataSource[indexPath.row];
        }else if ([asset isKindOfClass:[UIImage class]]){
            photo.thumbImage = (UIImage *)asset.thumbImage;
            photo.photoImage = (UIImage *)asset.originImage;
        }
    }
    photo.toView = imageView;
    return photo;
}
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (UIViewController *)myViewController {
    UIResponder *Rs = self;
    for(; ; Rs = [Rs nextResponder]) {
        if([Rs isKindOfClass:[UIViewController class]]){
            return (UIViewController*)Rs;
        }
    }
    return (UIViewController*)Rs;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//- (void)setArrDataSource:(NSMutableArray *)arrDataSource {
//    _arrDataSource = arrDataSource;
//}
@end
