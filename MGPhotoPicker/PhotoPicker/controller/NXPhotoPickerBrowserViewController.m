//
//  NXPhotoPickerBrowserViewController.m
//  NaXin
//
//  Created by 猪猪 on 2016/10/28.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import "NXPhotoPickerBrowserViewController.h"
#import "UIColor+Photo.h"
#import "PhotoLib.h"

@interface NXPhotoPickerBrowserViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UILabel *lbNum;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIButton *selectButton;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIImage *navigationColorImage;
@property (nonatomic, assign) BOOL theFirstComing;
@property (weak, nonatomic) IBOutlet UIButton *btGoForward;
@end

@implementation NXPhotoPickerBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationInit];
    [self setupUI];
    self.theFirstComing = YES;
    MGPhotoAsset *asset = [self.delegate NXPhotoPickerBrowserView:self ImageForIndexPath:_indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateLbNumState:asset.isSeleceted];
        
    });

    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationColorImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[self drawImageFromColor:[UIColor colorWithHexString:@"#202020"] size:CGSizeMake(screenwidth, 66)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[self drawImageFromColor: [UIColor colorWithHexString:@"#202020"] size:CGSizeMake(screenwidth, 0.2)]];
        
    [self.collectionView reloadData];


}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)scrollToIndexPath {
    [self.collectionView setContentOffset:CGPointMake(self.rowIndex * self.collectionView.frame.size.width, 0)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.theFirstComing) {
        [self scrollToIndexPath];
        self.theFirstComing = NO;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(NXPhotoPickerBrowserView:numberOfItemsInSection:)]) {
        return [self.delegate NXPhotoPickerBrowserView:self numberOfItemsInSection:section];
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if(!cell) {
        cell = [[UICollectionViewCell alloc]initWithFrame:self.view.bounds];
    }
    cell.tag = 10000 + indexPath.row;
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
    
    imageView.contentMode =  UIViewContentModeScaleAspectFit;
    
    [imageView addGestureRecognizer:tapGR];
    
    imageView.multipleTouchEnabled = YES;
    imageView.userInteractionEnabled = YES;
    
    if ([self.delegate respondsToSelector:@selector(NXPhotoPickerBrowserView:ImageForIndexPath:)]) {
        MGPhotoAsset *asset = [self.delegate NXPhotoPickerBrowserView:self ImageForIndexPath:indexPath];
        //耗时处理
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [asset originImageWithBlock:^(UIImage *image) {
                //图片缩放
                __block  UIImage *imageTemp = image;
                float heightScale =  imageTemp.size.height/CGRectGetHeight(imageView.frame);
                float widthScale = imageTemp.size.width/CGRectGetWidth(imageView.frame);
                float aspectScale = imageTemp.size.height / imageTemp.size.width;
                /*
                 if(aspectScale > 2.0) {
                 imageTemp = [UIImage scaleToSize:imageTemp size:CGSizeMake(imageView.frame.size.width, (imageTemp.size.height * (imageView.frame.size.width/imageTemp.size.width)))];
                 }
                 */
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    /*
                     if(aspectScale > 2.0) {
                     imageView.frame = CGRectMake(0, 0, imageTemp.size.width, imageTemp.size.height);
                     scrollView.contentSize = CGSizeMake(imageTemp.size.width, imageTemp.size.height);
                     }
                     */
                    imageView.image = imageTemp;
                    imageTemp = nil;
                    [activiti stopAnimating];
                    
                    scrollView.maximumZoomScale = heightScale > widthScale ? heightScale : widthScale;
                    
                });

            }];
    
            
           
        });
    }
    return cell;

}

//放大的控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIImageView *imageView = [scrollView viewWithTag:112];
    return imageView;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger count = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
    MGPhotoAsset *asset = [self.delegate NXPhotoPickerBrowserView:self ImageForIndexPath:indexPath];
    if (asset) {
        [self updateLbNumState:asset.isSeleceted];
        self.indexPath = indexPath;
    }
}



#pragma mark targets and action 

- (void)tapAction:(id)sender {
   // [self.navigationController.navigationBar setBackgroundImage:self.navigationColorImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:self.navigationColorImage forBarMetrics:UIBarMetricsDefault];

    [self.navigationController popViewControllerAnimated:NO];
}

- (void)selectenButtonClicked:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(NXPhotoPickerBrowserView:ImageForIndexPath:)]) {
        MGPhotoAsset *asset = [self.delegate NXPhotoPickerBrowserView:self ImageForIndexPath:self.indexPath];
        if ([self.delegate respondsToSelector:@selector(NXPhotoPickerBrowserView:didSecetedIndex:)]) {
            [self.delegate NXPhotoPickerBrowserView:self didSecetedIndex:self.indexPath];
            [self updateLbNumState:asset.isSeleceted];
        }
    }
}


- (IBAction)goForward:(id)sender {
    [self.navigationController.navigationBar setBackgroundImage:self.navigationColorImage forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController popViewControllerAnimated:NO];
    if ([self.delegate respondsToSelector:@selector(browserGoForward:)]) {
        [self.delegate browserGoForward:self];
    }
}



#pragma mark getter and setter 

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 9, 30, 30)];
        [_selectButton addTarget:self action:@selector(selectenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (NSIndexPath *)indexPath {
    if (! _indexPath) {
        _indexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
    }
    return _indexPath;
}

- (void)setRowIndex:(NSInteger)rowIndex {
    self.indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    _rowIndex = rowIndex;
}


#pragma mark private methods 

- (void)navigationInit {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photoPickerBack"] style:UIBarButtonItemStylePlain target:self action:@selector(tapAction:)];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    [view addSubview:self.selectButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:view];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectenButtonClicked:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem.tintColor = self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
   
    
}

- (void)updateLbNumState:(BOOL) flag {
    if (flag) {
        [self.selectButton setImage:[UIImage imageNamed:@"iv_selected"] forState:UIControlStateNormal];
    } else {
        [self.selectButton setImage:[UIImage imageNamed:@"photoPickUnselect"] forState:UIControlStateNormal];
    }
    
    if ([_delegate respondsToSelector:@selector(numberOfResult:)]) {
        if ([_delegate numberOfResult:self] > 0) {
            [self.btGoForward setTitleColor:[UIColor colorWithHexString:@"#86c60f"] forState:UIControlStateNormal];
            self.btGoForward.enabled = YES;
        } else {
            [self.btGoForward setTitleColor:[UIColor colorWithHexString:@"#505050"] forState:UIControlStateNormal];
            self.btGoForward.enabled = NO;

        }
        
        
        if (![_delegate numberOfResult:self]) {
            self.lbNum.hidden = YES;
        } else {
            self.lbNum.hidden = NO;
        }
        self.lbNum.text = [NSString stringWithFormat:@"%ld",[_delegate numberOfResult:self]];
    }
}


- (void)setupUI {
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.lbNum.layer.masksToBounds = YES;
    self.lbNum.layer.cornerRadius = self.lbNum.frame.size.width/2;
    self.lbNum.backgroundColor = [UIColor colorWithHexString:@"#86c60f"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#202020"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    
}


- (UIImage *)drawImageFromColor:(UIColor *)color size:(CGSize) size {
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
