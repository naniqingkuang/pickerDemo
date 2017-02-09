//
//  NXPhotoPickerBrowserView.m
//  NaXin
//
//  Created by 猪猪 on 16/4/6.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import "NXPhotoPickerBrowserView.h"
#import "MGPhotoAsset.h"
#import "UIImage+PhotoCompress.h"

@interface NXPhotoPickerBrowserView()<UIScrollViewDelegate, UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) NSInteger m_index;
@end
@implementation NXPhotoPickerBrowserView
- (void)awakeFromNib {
    if(self) {
        self.scrollEnabled = NO;
    }
}

- (void)imageInit {
    self.flowLayout.itemSize = self.frame.size;
    [self setContentSize:CGSizeMake(_arrData.count * self.frame.size.width, self.frame.size.height)];
    
}

#pragma mark delegate and datasouce 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if(!cell) {
        cell = [[UICollectionViewCell alloc]initWithFrame:self.bounds];
    }
    UIScrollView *tagView = [cell viewWithTag:111];
    if(tagView) {
        [tagView removeFromSuperview];
    }
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:cell.bounds];
    scrollView.maximumZoomScale = 4;
    scrollView.minimumZoomScale = 1;
    [scrollView setZoomScale:1];
    scrollView.tag = 111;
    scrollView.scrollEnabled = YES;
    scrollView.delegate = self;
    tagView = scrollView;
    [cell addSubview:tagView];
    
    UIImageView *imageView = [tagView viewWithTag:112];
    if(imageView) {
        [imageView removeFromSuperview];
    }

    imageView = [[UIImageView alloc]initWithFrame:tagView.bounds];
    imageView.tag = 112;
    [tagView addSubview:imageView];
    
    
    //菊花转
    UIActivityIndicatorView *activiti = [[UIActivityIndicatorView alloc]init];
    activiti.frame = CGRectMake(0, 0, 60, 60);
    activiti.center = imageView.center;
    [imageView addSubview:activiti];
    [activiti startAnimating];

    
    
    //轻拍手势
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    
    imageView.contentMode =  UIViewContentModeScaleAspectFill;
    
    [imageView addGestureRecognizer:tapGR];
    
    imageView.multipleTouchEnabled = YES;
    imageView.userInteractionEnabled = YES;

    //耗时处理
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(indexPath.row < _arrData.count) {
            MGPhotoAsset *asset = _arrData[indexPath.row];
            [asset originImageWithBlock:^(UIImage *image) {
                
                __block UIImage *imageTemp =image;
                float heightScale =  imageTemp.size.height/CGRectGetHeight(imageView.frame);
                float widthScale = imageTemp.size.width/CGRectGetWidth(imageView.frame);
                float aspectScale = imageTemp.size.height / imageTemp.size.width;
                if(aspectScale > 2.0) {
                    imageTemp = [UIImage scaleToSize:imageTemp size:CGSizeMake(imageView.frame.size.width, (imageTemp.size.height * (imageView.frame.size.width/imageTemp.size.width)))];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(aspectScale > 2.0) {
                        imageView.frame = CGRectMake(0, 0, imageTemp.size.width, imageTemp.size.height);
                        scrollView.contentSize = CGSizeMake(imageTemp.size.width, imageTemp.size.height);
                    }
                    
                    imageView.image = imageTemp;
                    imageTemp = nil;
                    [activiti stopAnimating];
                    scrollView.maximumZoomScale = heightScale > widthScale ? heightScale : widthScale;
                });
                

            }];
           
        }

    });
    return cell;
}


#pragma mark 轻拍效果
- (void)tapAction:(UITapGestureRecognizer *)sender {
    if (self.tapActionBlock) {
        self.tapActionBlock();
    }
}


//设置第几个
- (void)setIndex:(NSInteger)index {
    self.m_index = index;
    if(index < _arrData.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

//delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

//放大的控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIImageView *imageView = [scrollView viewWithTag:112];
    return imageView;
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    CGPoint offset=[scrollView contentOffset];
//    if ((offset.x + self.frame.size.width) - (scrollView.frame.origin.x + scrollView.frame.size.width) > 100) { //向右滑动
//        //如果不设置回去，会出现问题的
//        if(scrollView.zoomScale > 1) {
//            [scrollView setZoomScale:1.0];
//        }
//    }else if(scrollView.frame.origin.x - offset.x> 100 ){ //向
//        if(scrollView.zoomScale > 1) {
//            [scrollView setZoomScale:1.0];
//        }
//    }
//}

- (void)setArrData:(NSArray *)arrData {
    if(arrData.count == 0) {
        [self tapAction:nil];
    }
    _arrData = arrData;
    [self imageInit];
    [self.collectionView reloadData];
}
- (UICollectionViewFlowLayout *)flowLayout {
    if(!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumInteritemSpacing = 0;
    }
    return _flowLayout;
}
- (UICollectionView *)collectionView {
    if (! _collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [self addSubview:_collectionView];
    }
    return _collectionView;
}
@end
