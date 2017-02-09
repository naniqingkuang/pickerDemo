//
//  NXPhotoPickerCollectionView.m
//  NXPhotoPickerTest
//
//  Created by HZSD on 16/3/22.
//  Copyright © 2016年 HZSD. All rights reserved.
//

#import "NXPhotoPickerCollectionView.h"
#import "NXPhotoPickerCollectionViewCell.h"
#import "MGPhotoAsset.h"
#import "NXPhotoPickerImageView.h"
#import "NXPhotoPickerFooterCollectionReusableView.h"

static const NSString * myPhotoPickerCollectionViewCellID = @"NXPhotoPickerCollectionViewCellID";
static const NSString *_footerIdentifier = @"_footerIdentifier";

@interface NXPhotoPickerCollectionView()
@property (nonatomic, strong) NXPhotoPickerFooterCollectionReusableView *footerView;
@end

@implementation NXPhotoPickerCollectionView
- (void)awakeFromNib {
    if (self != nil) {
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _arrSelectedAssets = [NSMutableArray array];
        [self registerClass:[NXPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:myPhotoPickerCollectionViewCellID];
        [self registerClass:[NXPhotoPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
    }
    
}
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _arrSelectedAssets = [NSMutableArray array];
        [self registerClass:[NXPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:myPhotoPickerCollectionViewCellID];
        [self registerClass:[NXPhotoPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];

    }
    return self;
}

#pragma mark UICollectionViewDelegate and UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.arrDataSource) {
        return _arrDataSource.count;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [self.photoDelegate PickerCollectionView:self selectedData:self.arrSelectedAssets];
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NXPhotoPickerCollectionViewCell *cell = [NXPhotoPickerCollectionViewCell cellWithCollectionView:collectionView cellForItemAtIndexPath:indexPath withIndentify:myPhotoPickerCollectionViewCellID];
    if(self.arrDataSource.count > indexPath.row) {
       
        MGPhotoAsset *asset = nil;
        if(NXPhotoPickerShowOrderDesc == self.showOrder) {
            asset = self.arrDataSource[self.arrDataSource.count - indexPath.row -1];  //降序
        } else if(NXPhotoPickerShowOrderAsc == self.showOrder) {
            asset = self.arrDataSource[indexPath.row]; //升序
        }
#pragma mark cell 在单选和多选的时候
        if(NXPhotoPickerSingleSelected == self.selectedModel) {  //单选
            if(asset.selectedCount >1) {
                asset.selectedCount = 1;
            }
        } else {
            
        }
        [asset thumbImageWithBlock:^(UIImage *image) {
            cell.ImageView.image = image;
        }];
        
        cell.ImageView.maskViewFlag = YES;
        cell.ImageView.animationRightTick = YES;
        cell.ImageView.count = asset.selectedCount;
        __weak typeof(self) weakSelf = self;
        cell.ImageView.buttonBlock = ^ {
            __strong typeof (self) strongSelf = weakSelf;
            [strongSelf.photoDelegate PickerCollectionView:strongSelf clickedIndex:indexPath.row];
        };
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
#pragma mark 单选和复选的功能实现
    MGPhotoAsset *asset = nil;
    if(NXPhotoPickerShowOrderDesc == self.showOrder) {
        asset = self.arrDataSource[self.arrDataSource.count - indexPath.row -1];  //降序
    } else if(NXPhotoPickerShowOrderAsc == self.showOrder) {
        asset = self.arrDataSource[indexPath.row]; //升序
    }
    if(NXPhotoPickerSingleSelected == self.selectedModel) {  //单选
        [self singleModelDeal:asset];
    } else if(NXPhotoPickerMultableSelected == self.selectedModel) {
        [self multableModelDeal:asset];
    }
    [self reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    [self.photoDelegate PickerCollectionView:self selectedData:self.arrSelectedAssets];
    //
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NXPhotoPickerFooterCollectionReusableView *footerView = nil;
   
    if (kind == UICollectionElementKindSectionFooter) {
         footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier forIndexPath:indexPath];
        _footerView = footerView;
        footerView.count = self.arrDataSource.count;
    }
    return footerView;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = (screenwidth - (3 *3))/4;
    return CGSizeMake(cellWidth, cellWidth);
}

- (void)alertShow:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
   
}
#pragma mark 单选模式
- (void)singleModelDeal:(MGPhotoAsset *)asset {
    if (asset.selectedCount > 0) {
        asset.selectedCount = 0;
        [self unSelectedAsset:asset];
    } else if (asset.selectedCount == 0) {
        NSInteger selectedCount = [self selectedCountAssets];
        if(selectedCount >= self.maxSelectedNum) {//self.maxSelectedNum
            asset.selectedCount = 0;  //超过上限的时候不选中，并且提示用户
            NSString *format = [NSString stringWithFormat:@"亲，您最多能选%ld张图片",self.maxSelectedNum];//_maxSelectedNum
            [self alertShow:format];
        } else {
            asset.selectedCount = 1;
            [self.arrSelectedAssets addObject:asset];
        }
    }
}
#pragma mark 复选模式
- (void)multableModelDeal:(MGPhotoAsset *)asset {
    NSInteger selectedCount = [self selectedCountAssets];
    if(selectedCount < self.maxSelectedNum) {
        asset.selectedCount ++;
        [self.arrSelectedAssets addObject:asset];
    } else if(selectedCount >= self.maxSelectedNum) {
        if(asset.selectedCount > 0) { //说明选择这张图片是之前已经选过了的
            [self unSelectedAsset:asset];
            asset.selectedCount --;
        } else {
            NSString *format = [NSString stringWithFormat:@"亲，你还能选择%ld张图片",_maxSelectedNum - selectedCount];
            [self alertShow:format];
        }
    }
}
#pragma mark private methods
//arrDataSource 的setter 方法
- (void)setArrDataSource:(NSArray *)arrDataSource {
    MGPhotoAsset * temp = nil;
    [_arrSelectedAssets removeAllObjects];
    _arrDataSource = [NSArray arrayWithArray:arrDataSource];
    if(_arrDataSource.count && _arrPreSelectedAssets.count) {
        for (MGPhotoAsset *asset in _arrPreSelectedAssets) {
            for (int  i = 0; i < _arrDataSource.count; i ++) {
                temp = _arrDataSource[i];
                if( [asset isTheSameAsset:temp]) {
                    if(NXPhotoPickerSingleSelected == _selectedModel) {
                        temp.selectedCount = 1;
                    } else if (NXPhotoPickerMultableSelected == _selectedModel) {
                        temp.selectedCount++;
                    }
                    [self.arrSelectedAssets addObject:temp];
                    break;
                }
            }
        }
        [self.photoDelegate PickerCollectionView:self selectedData:self.arrSelectedAssets];
    }
}
//计算选中的图片的个数，包含多选和单选
- (NSInteger)selectedCountAssets {
    NSInteger count = 0;
    for (MGPhotoAsset *asset in self.arrDataSource) {
        if(asset.selectedCount >0) {
            count += asset.selectedCount;
        }
    }
    return count;
}
//得到视图控制器
- (UIViewController *)viewController {
    UIResponder *responder = self;
    for (responder = self; ;responder = [responder nextResponder] ) {
        if([responder isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return (UIViewController*)responder;
}

//PreSelectedAssets setter 方法
- (void)setArrPreSelectedAssets:(NSArray *)arrPreSelectedAssets {
    MGPhotoAsset * temp;
    [_arrSelectedAssets removeAllObjects];
    _arrPreSelectedAssets = [NSArray arrayWithArray:arrPreSelectedAssets];
    if(_arrDataSource.count && _arrPreSelectedAssets.count) {
        for (MGPhotoAsset *asset in _arrPreSelectedAssets) {
            for (int  i = 0; i < _arrDataSource.count; i ++) {
                temp = _arrDataSource[i];
                if([asset isTheSameAsset:temp]) {
                    if(NXPhotoPickerSingleSelected == _selectedModel) {
                        temp.selectedCount = 1;
                    } else if (NXPhotoPickerMultableSelected == _selectedModel) {
                        temp.selectedCount++;
                    }
                    [self.arrSelectedAssets addObject:temp];
                    break;
                }
            }
        }
        [self.photoDelegate PickerCollectionView:self selectedData:self.arrSelectedAssets];
    }
}
- (void)setAsset:(MGPhotoAsset *)asset {
    MGPhotoAsset *temp = 0;
    for (MGPhotoAsset *set in _arrDataSource) {
        if([asset isTheSameAsset:set]) {
            temp = set;
            break;
        }
    }
    if(temp.selectedCount) {
        temp.selectedCount --;
    }
    [self reloadData];

}

//取消选择
- (void)unSelectedAsset:(MGPhotoAsset *)asset {
    NSInteger index = -1;
    if (self.arrSelectedAssets.count) {
            for (int i = 0; i < self.arrSelectedAssets.count; i++) {
                MGPhotoAsset *temp = _arrSelectedAssets[i];
                if([temp isTheSameAsset:asset]) {
                    index = i;
                    break;
                }
            }
        if (index >=0 ) {
            [self.arrSelectedAssets removeObjectAtIndex:index];
        }
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
