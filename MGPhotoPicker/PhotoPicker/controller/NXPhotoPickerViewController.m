//
//  NXPhotoPickerViewController.m
//  NaXin
//
//  Created by 猪猪 on 16/4/6.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import "NXPhotoPickerViewController.h"
#import "NXPKGroupTableViewCell.h"
#import "NXPhotoPickerBrowserView.h"
#import "UIImage+PhotoFIxOrientation.h"
#import <AVFoundation/AVFoundation.h>
#import "NXPhotoPickerCollectionViewCell.h"
#import "PhotoPickerHeadView.h"
#import "NXPhotoPickerBarButton.h"
#import "MGPopTipView.h"
#import "NXPhotoPickerBrowserViewController.h"
#import "MGPhotoAsset.h"
#import "NXPhotoPickerDataSource.h"
#import <objc/runtime.h>
#import "UIColor+Photo.h"
#import "PhotoManager.h"



typedef NS_ENUM(NSUInteger, titleState) {
    titleStateUp,
    titleStateDown
};

#define SPACE_BETWEEN_ITEM                  3.0f
#define NUMBER_OF_COLUMN                    3
#define CELL_WIDTH                  (float)(((screenwidth) - (NUMBER_OF_COLUMN * (SPACE_BETWEEN_ITEM-1)))/NUMBER_OF_COLUMN)
#define screenHeight ([UIScreen mainScreen].bounds.size.height)
#define screenwidth ([UIScreen mainScreen].bounds.size.width)

#define cellReuseID                         @"collectionViewReuseID"
#define collectionViewFooterReuseID         @"collectionViewFooterReuseID"

typedef NS_ENUM(NSUInteger, DismissType) {
    DismissTypeNormal,
    DismissTypeDelay,
    DismissTypeNone
};


@interface NXPhotoPickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate,NXPhotoPickerBrowserViewControllerDelegate,UINavigationControllerDelegate>
//UI
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UITableView *groupTableView;
@property (weak, nonatomic) IBOutlet UIView *groupTableGroundView;
@property (weak, nonatomic) IBOutlet UIButton *btTypeCloudTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbTypeCloudCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupTableBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collctionViewTop;
@property (weak, nonatomic) IBOutlet UIView *styleCloudBackGroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *styleBackGroundViewHight;
@property (nonatomic, assign) DismissType dismissType;


//导航栏
@property (nonatomic, strong) UIImage *navigationColorImage;
;
@property (nonatomic, strong) UIButton *titleButton; //选择相册的按钮
@property (nonatomic, strong) NXPhotoPickerBarButton *rightBarButtonView;



@property (nonatomic, strong) UIImageView *imgTakePhoto;
@property (nonatomic, strong) UIImageView *imageNaxinPhto;

//数据类
@property (strong, nonatomic) NXPhotoPickerDataSource *dataSource;

@property (nonatomic, strong) NSMutableArray *arrayResult; //结果集
@property (nonatomic, strong) NSMutableArray *arrayCurrentShowGroupData; //当前collcetionView 正在使用的对应Group的数据
@property (nonatomic, strong) NSMutableArray *arrTakePhotoImageURL;
@end

@implementation NXPhotoPickerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self uiSetUp];
    [self dataInit];
    [self updateRightBarButtonNum:self.arrayResult.count + self.alreadySelectedNum];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popVc) name:@"camemaDismiss" object:nil];

        // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIColor *navigationColor = [UIColor blackColor];
    if (self.dismissType == DismissTypeNormal || self.dismissType == DismissTypeDelay) {
        if (self.style == NXPhotoStyleCloud) {
            navigationColor = self.view.backgroundColor = self.collectionView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
            self.collctionViewTop.constant = 0;
            
        }
        self.navigationColorImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        
        [self.navigationController.navigationBar setBackgroundImage:[self drawImageFromColor:navigationColor size:CGSizeMake(screenwidth, 66)] forBarMetrics:UIBarMetricsDefault];
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];


}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//状态不需要显示

- (BOOL)prefersStatusBarHidden {
    if (self.style == NXPhotoStyleCloud) {
        return NO;
    }
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.dismissType == DismissTypeNormal || self.dismissType == DismissTypeDelay) {
        [self navigationDismiss];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Delegate and DataSource

#pragma mark <UICollectionViewDelegate,UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayCurrentShowGroupData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NXPhotoPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseID forIndexPath:indexPath];
    __block MGPhotoAsset *asset = self.arrayCurrentShowGroupData[indexPath.row];
    [asset thumbImageWithBlock:^(UIImage *image) {
        cell.ImageView.image = image;
    }];
    cell.ImageView.maskViewFlag = YES;
    cell.ImageView.animationRightTick = YES;
    cell.ImageView.count = asset.selectedIndex;
    __weak typeof(self) weakSelf = self;
    cell.ImageView.buttonBlock = ^ {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf photoAssetSelected:asset index:indexPath.row];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NXPhotoPickerBrowserViewController *vc = [[NXPhotoPickerBrowserViewController alloc] initWithNibName:@"NXPhotoPickerBrowserViewController" bundle:nil];
    vc.delegate = self;
    vc.rowIndex = indexPath.row;
//    [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PhotoPickerHeadView *view = [UICollectionReusableView new];
    if (indexPath.section == 0 && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view = (PhotoPickerHeadView * )[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionViewFooterReuseID forIndexPath:indexPath];
        view.frame = CGRectMake(0, 0, screenwidth, CELL_WIDTH);
        __weak typeof(self) weakSelf = self;
        view.selectedBlock = ^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf collectionViewTapAction:index];
        };
        if (self.arrayCurrentShowGroupData.count) {
            view.hidden = NO;
        } else {
            view.hidden = YES;

        }
    }
    return view;
}




#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    tableView.separatorColor = [UIColor colorWithHexString:@"#bbbbbb"];
    tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.groups.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NXPKGroupTableViewCell *cell = [NXPKGroupTableViewCell instanceCell];
    cell.group = self.dataSource.groups[indexPath.row];
    return cell;
}
#pragma mark -<UITableViewDelegate>

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row < self.dataSource.groups.count) {
        
        MGPhotoGroup *group = self.dataSource.groups[indexPath.row];
        //相同的组不进行数据刷新
        self.dataSource.currentGroup = group;
        [self refreshTitieViewWithText:self.dataSource.currentGroup.groupName andState:titleStateDown];

        __weak typeof(self) weakSelf = self;
        [self refreshAssetData:self.dataSource.currentGroup withBlock:^(BOOL flag) {
            __strong typeof(weakSelf) strongSelf = weakSelf;

            if (! flag) {
                MGPopTipView *popView = [[MGPopTipView alloc] initWithText:@"相册没有照片"];
                [popView showInView:strongSelf.view showType:1];
                strongSelf.groupTableGroundView.hidden = NO;

            } else {
                strongSelf.groupTableGroundView.hidden = YES;
            }
        }];
    }
}


#pragma mark  <NXPhotoPickerBrowserViewControllerDelegate>

- (NSInteger)NXPhotoPickerBrowserView:(NXPhotoPickerBrowserViewController *)browserVC numberOfItemsInSection:(NSInteger)section {
   return  self.arrayCurrentShowGroupData.count;
}

- (MGPhotoAsset *)NXPhotoPickerBrowserView:(NXPhotoPickerBrowserViewController *)browserVC ImageForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.arrayCurrentShowGroupData.count) {
        return self.arrayCurrentShowGroupData[indexPath.row];
    }
    return nil;
}
- (void)NXPhotoPickerBrowserView:(NXPhotoPickerBrowserViewController *)browserVC didSecetedIndex:(NSIndexPath *)indexPath {
    MGPhotoAsset *asset = self.arrayCurrentShowGroupData[indexPath.row];
    [self photoAssetSelected:asset index:indexPath.row];
}
- (void)NXPhotoPickerBrowserViewDidFinishBrowser:(NXPhotoPickerBrowserViewController *)browserVC {
    [self done];
}
- (NSInteger)numberOfResult:(NXPhotoPickerBrowserViewController *)browserVC {
    return self.arrayResult.count + self.alreadySelectedNum;
}

- (void)browserGoForward:(NXPhotoPickerBrowserViewController *)vc {
    [self done];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataSource writeToLibImage:image withBlock:^(NSURL *assetURL) {
            if(_arrTakePhotoImageURL.count > 0) {
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:2];
                for (NSURL *url in _arrTakePhotoImageURL) {
                    if (![url isEqual:assetURL]) {
                        [arr addObject:assetURL];
                    }
                }
                [_arrTakePhotoImageURL addObjectsFromArray:arr];
            } else {
                [_arrTakePhotoImageURL addObject:assetURL];
            }
            [self refreshAssetData:self.dataSource.currentGroup withBlock:nil];
            
            __weak typeof(self) weakSelf = self;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;

                [strongSelf refreshAssetData:strongSelf.dataSource.currentGroup withBlock:^(BOOL flag) {
                    [strongSelf updateRightBarButtonNum:strongSelf.arrayResult.count + self.alreadySelectedNum];
                }];
            });
        }];

    });
    __weak typeof(self) weakSelf = self;

    [picker dismissViewControllerAnimated:YES completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;

        strongSelf.dismissType = DismissTypeNormal ;
    }];
    //马上取数据得不到数据
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    __weak typeof(self) weakSelf = self;

    [picker dismissViewControllerAnimated:YES completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;

        strongSelf.dismissType = DismissTypeNormal ;
    }];

}


#pragma mark target action

- (void)buttonFinishTouchUpInside:(id)sender {
    if (self.arrayResult.count + self.alreadySelectedNum <= 0) {
        return;
    }
    [self done];
}

- (void)collectionViewTapAction:(NSInteger) index {
    if (index == 0) {
        if(![PhotoManager ifCanAccessTakePhoto]) {
            [self attentionMessage: [NSString stringWithFormat:@"需要访问您的相机。请启用相机-设置/隐私/相机/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]] viewController:self];
            return;
        }
        self.dismissType = DismissTypeNone;
        UIImagePickerController *pickerVC = [[UIImagePickerController alloc]init];
        pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerVC.delegate = self;
//        pickerVC.prefersStatusBarHidden = YES;
        __weak typeof(self) weakSelf = self;

        Method functionHideStatusBar = class_getInstanceMethod([UIImagePickerController class], @selector(prefersStatusBarHidden));
        Method functionHideStatusBar_exchage = class_getInstanceMethod([self class], @selector(prefersStatusBarHidden_exchange));
        if (functionHideStatusBar) {
            method_exchangeImplementations(functionHideStatusBar, functionHideStatusBar_exchage);
        }
       
        
        [self presentViewController:pickerVC animated:YES completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;

            if (functionHideStatusBar) {
                method_exchangeImplementations(functionHideStatusBar_exchage, functionHideStatusBar);
            }
        }];
        
    } else if (index == 1) {
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"naxincamera://"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"itms-apps://itunes.apple.com/app/id1167871832"]];
        };
         
    }
}

- (BOOL)prefersStatusBarHidden_exchange {
    return YES;
}



- (void)titleViewClicked:(UIButton *)sender {
    //相同的组不进行数据刷新
    if (self.style == NXPhotoStyleCloud) {
        if ([self.dataSource.currentGroup.groupName isEqualToString:self.btTypeCloudTitle.titleLabel.text]&& self.groupTableGroundView.hidden == NO) {
            self.groupTableGroundView.hidden = YES;
            [self refreshTitieViewWithText:self.dataSource.currentGroup.groupName andState:titleStateDown];

            return;
        }

    } else {
        if ([self.dataSource.currentGroup.groupName isEqualToString:self.titleButton.titleLabel.text] && self.groupTableGroundView.hidden == NO) {
            self.groupTableGroundView.hidden = YES;
            [self refreshTitieViewWithText:self.dataSource.currentGroup.groupName andState:titleStateDown];

            return;

        }
    }
    [self refreshTitieViewWithText:self.dataSource.currentGroup.groupName andState:titleStateUp];

    [self.groupTableView reloadData];
    self.groupTableGroundView.hidden = NO;
}
- (IBAction)btTypeCloudTitleClied:(id)sender {
    [self titleViewClicked:sender];
}

#pragma private methods
//数据初始化
- (void)dataInit {
    
    //初始化相册
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(![PhotoManager ifCanAccessPhotoLib]) {
            [self attentionMessage:  [NSString stringWithFormat:@"需要访问您的照片。请允许使用照片-设置/隐私/照片/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]] viewController:self];
        }
        
        self.dataSource = [[NXPhotoPickerDataSource alloc]init];
        
        __weak typeof(self) weakSelf = self;

        [self.dataSource getAllGroup:NXPickerViewShowStatusCameraRoll withFinishBlock:^(NSArray<MGPhotoGroup *> *groupArr) {
            __strong typeof(weakSelf) strongSelf = weakSelf;

            [strongSelf refreshAssetData:self.dataSource.currentGroup withBlock:nil];
            [strongSelf refreshTitieViewWithText:strongSelf.dataSource.currentGroup.groupName andState:titleStateDown];
        }];

    });
    
    self.dismissType = DismissTypeNormal;
}

- (void )refreshAssetData:(MGPhotoGroup *)group withBlock:(void(^)(BOOL)) comBlock{
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource getAsssets:group withFinishBlock:^(NSArray<MGPhotoAsset *> *data) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        
        if (self.showOrder == NXPhotoPickerShowOrderDesc) {
            data = [[data reverseObjectEnumerator] allObjects];
        }
        //有些是传进来的已选好的图片
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.arrPreSelected];
        for (NSURL *url in arr) {
            for (MGPhotoAsset *assetDest in data) {
                if ([MGPhotoAsset isTheSameUrl:assetDest.assetURL andUrl2:url]) {
                    assetDest.isSeleceted = YES;
                    assetDest.selectedIndex = self.arrayResult.count + self.alreadySelectedNum+ 1;
                    [self.arrayResult addObject:assetDest];
                    [self.arrPreSelected removeObject:url];
                }
            }
        }
        
        //拍照
        arr = [NSArray arrayWithArray:self.arrTakePhotoImageURL];
        for (NSURL *url in arr) {
            for (MGPhotoAsset *assetDest in data) {
                if ([MGPhotoAsset isTheSameUrl:assetDest.assetURL andUrl2:url]) {
                    assetDest.isSeleceted = YES;
                    assetDest.selectedIndex = self.arrayResult.count+self.alreadySelectedNum + 1;
                    [self.arrayResult addObject:assetDest];
                    [self.arrTakePhotoImageURL removeObject:url];
                }
            }
        }

        
        //换相册的时候需要考虑已经选择的图片
        for (MGPhotoAsset *asset in self.arrayResult) {
            for (MGPhotoAsset *assetDest in data) {
                if ([assetDest isTheSameAsset:asset]) {
                    assetDest.isSeleceted = asset.isSeleceted;
                    assetDest.selectedIndex = asset.selectedIndex;
                }
            }
        }
        
        
        //复制数据
        [strongSelf.arrayCurrentShowGroupData removeAllObjects];
        [strongSelf.arrayCurrentShowGroupData addObjectsFromArray:data];
        if (!data.count) {
            if (comBlock) {
                comBlock(false);
            }
            [self.collectionView reloadData];
        } else {
            //刷新UI
            [self.collectionView reloadData];
            if (comBlock) {
                comBlock(true);
            }
        }
    }];
}

// UI 初始化
- (void)uiSetUp {
    [self assetsCollectionViewInit];
    [self groupTableViewInit];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [self navigationbarInit];
    [self styleCloudInit];

    
    
    
}
//选取的collecttion
- (void)assetsCollectionViewInit {
    CGFloat itemWith = CELL_WIDTH;
    self.flowLayout.itemSize = CGSizeMake(itemWith, itemWith);
    self.flowLayout.minimumInteritemSpacing = SPACE_BETWEEN_ITEM;
    self.flowLayout.minimumLineSpacing = SPACE_BETWEEN_ITEM;
    if (NXPhotoStyleNaXinPhoto == self.style) {
        self.flowLayout.headerReferenceSize = CGSizeMake(screenwidth, itemWith+3);
    }
    if (self.style == NXPhotoStyleNaXinPhoto){
        self.flowLayout.headerReferenceSize = CGSizeMake(screenwidth, itemWith+3);
    }
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
    [self.collectionView registerClass:[NXPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:cellReuseID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoPickerHeadView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionViewFooterReuseID];
}


- (void)groupTableViewInit {
    self.groupTableGroundView.hidden = YES;
    self.groupTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.groupTableView.backgroundColor  = self.groupTableGroundView.backgroundColor = [UIColor colorWithHexString:@"#d4cecc"];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(groupTableGroudTap)];
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    tapGR.delegate = self;
    [self.groupTableGroundView addGestureRecognizer:tapGR];
}

#pragma mark 图片组选取轻拍操作
- (void)groupTableGroudTap{
    self.groupTableGroundView.hidden = YES;
}

- (void)navigationbarInit {
 
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightBarButtonView];
    UIImage *image = [UIImage imageNamed:@"photoPickerBack"];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 0, (44 - image.size.width))];
    [button addTarget:self action:@selector(popVc) forControlEvents:UIControlEventTouchUpInside];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [view addSubview:button];
    [button setImage:image forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
// style:UIBarButtonItemStylePlain target:self action:@selector(popVc)];

}

+ (NXPhotoPickerViewController *)getNXPhotoPickerVC {
    NXPhotoPickerViewController *vc = [[NXPhotoPickerViewController alloc]initWithNibName:@"NXPhotoPickerViewController" bundle:nil];
    return vc;
}

// 完成操作
- (void)done {
    if (self.arrayResult.count + self.alreadySelectedNum < self.minSelectedNum)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提醒" message:[NSString stringWithFormat:@"亲，请选择最少%ld张图片",self.minSelectedNum] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        self.dismissType = DismissTypeDelay;
        [self.aseetDelegate PickerView:self doneWithResult:self.arrayResult];
        if (self.style == NXPhotoStyleCloud) {
            
        } else {
        }
     //   [self performSelectorOnMainThread:@selector(popVc) withObject:nil waitUntilDone:YES];
    }
}

- (void)popVc
{
    if ([self.aseetDelegate respondsToSelector:@selector(PickerViewBack:)]) {
        [self.aseetDelegate PickerViewBack:self];
    } else {
        [self.navigationController popViewControllerAnimated:NO];

    }
}



#pragma mark 右导航栏
//相机拍照
- (void)rightBarButtonTouchUpInside {
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {//如果当前是tableView
        //做自己想做的事
        return NO;
    }
    return YES;
}




-(void)attentionMessage:(NSString *)message viewController:(UIViewController *)vc
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
        UIAlertController * alertVC =
        [UIAlertController
         alertControllerWithTitle:@"提示"
         message:message
         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action =
        [UIAlertAction
         actionWithTitle:@"确定"
         style:UIAlertActionStyleCancel
         handler:nil];
        [alertVC addAction:action];
        [vc presentViewController:alertVC animated:YES completion:nil];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
}


- (MGPhotoAsset *)removeFromResultAsset:(MGPhotoAsset *)asset {
    asset.selectedIndex = 0;
    asset.isSeleceted = NO;
    BOOL isNeedSub = NO;
    MGPhotoAsset *assetThatNeedRemove = nil;
    for (int i = 0; i < self.arrayResult.count; i ++) {
        MGPhotoAsset *assetTemp = self.arrayResult[i];
        if ([MGPhotoAsset isTheSameUrl:assetTemp.assetURL andUrl2:asset.assetURL] ) {
            assetThatNeedRemove = assetTemp;
            isNeedSub = YES;
        }
        if (isNeedSub) {
            assetTemp.selectedIndex --;
        }
    }
    if (assetThatNeedRemove) {
        [self.arrayResult removeObject:assetThatNeedRemove];
    }
    return asset;
}

- (MGPhotoAsset *)addToResultArrayAsssetS:(MGPhotoAsset *)asset {
    asset.selectedIndex = self.arrayResult.count + self.alreadySelectedNum + 1;
    asset.isSeleceted = YES;
    [self.arrayResult addObject:asset];
    return asset;
}

- (void)refreshDataSourceWithSelectResult {
    
}

- (void)refreshTitieViewWithText:(NSString *)title andState:(titleState) state {
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.4 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *imgPath = nil;
        //down_home
        if (self.style == NXPhotoStyleCloud) {
            if (state == titleStateUp) {
                imgPath = @"up_home";
            } else {
                imgPath = @"down_home";
            }

        } else {
            if (state == titleStateUp) {
                imgPath = @"photoPickUp";
            } else {
                imgPath = @"photoPickDown";
            }
 
        }
        
        if (strongSelf.style == NXPhotoStyleCloud) {
            [strongSelf.btTypeCloudTitle setImage:[UIImage imageNamed:imgPath] forState:UIControlStateNormal];
            
            [strongSelf.btTypeCloudTitle setTitle:title forState:UIControlStateNormal];
        } else {
            [strongSelf.titleButton setImage:[UIImage imageNamed:imgPath] forState:UIControlStateNormal];
            
            
            [strongSelf.titleButton setTitle:title forState:UIControlStateNormal];
        }
    }];
    
}

- (void)updateRightBarButtonNum:(NSInteger) num{
    
    if (self.style == NXPhotoStyleCloud) {
        if (num <= 0) {
            self.lbTypeCloudCount.text = @"";
            self.lbTypeCloudCount.hidden = YES;
        } else {
            self.lbTypeCloudCount.hidden = NO;
            self.lbTypeCloudCount.text = [NSString stringWithFormat:@"%ld",num];
        }
    } else {
        [self.rightBarButtonView setNum:num];
    }
}


- (void)photoAssetSelected:(MGPhotoAsset *)asset index:(NSInteger) index {
    if (self.arrayResult.count + self.alreadySelectedNum > self.maxSelectedNum) {
        [self attentionMessage:[NSString stringWithFormat:@"你最多只能选择%ld张图片",self.maxSelectedNum]  viewController:self];
        return;
    } else if (self.arrayResult.count + self.alreadySelectedNum == self.maxSelectedNum) {
        if (!asset.isSeleceted) {
            [self attentionMessage:[NSString stringWithFormat:@"你最多只能选择%ld张图片",self.maxSelectedNum]  viewController:self];
            return;
        }
    }
    if (asset.isSeleceted) {
        [self.arrayCurrentShowGroupData replaceObjectAtIndex:index withObject:[self removeFromResultAsset:asset]] ;
    } else {
        [self.arrayCurrentShowGroupData replaceObjectAtIndex:index withObject:[self addToResultArrayAsssetS:asset]];
    }
    [self updateRightBarButtonNum:self.arrayResult.count+self.alreadySelectedNum];
    [self.collectionView reloadData];
}

//刷新数据
- (void)refreshUI {
    [self refreshAssetData:self.dataSource.currentGroup withBlock:nil];
}

//清除数据
- (void)clearData {
    [self.arrayResult removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshAssetData:strongSelf.dataSource.currentGroup withBlock:^(BOOL flag) {
            [strongSelf updateRightBarButtonNum:strongSelf.arrayResult.count + self.alreadySelectedNum];
        }];
    });


}



#pragma mark getter and setter
- (NSMutableArray *)arrayResult {
    if (!_arrayResult) {
        _arrayResult = [NSMutableArray arrayWithCapacity:20];
    }
    return _arrayResult;
}

- (NSMutableArray *)arrTakePhotoImageURL {
    if (!_arrTakePhotoImageURL) {
        _arrTakePhotoImageURL = [NSMutableArray arrayWithCapacity:20];
    }
    return _arrTakePhotoImageURL;
}


- (NSMutableArray *)arrayCurrentShowGroupData {
    if (!_arrayCurrentShowGroupData) {
        _arrayCurrentShowGroupData = [NSMutableArray arrayWithCapacity:20];
    }
    return _arrayCurrentShowGroupData;
}

- (NSMutableArray *)selectAsstes {
    return [NSMutableArray arrayWithArray:self.arrayResult];
}

- (void)setArrPreSelected:(NSMutableArray *)arrPreSelected {
    _arrPreSelected = [NSMutableArray arrayWithCapacity:arrPreSelected];
}

- (UIButton *)titleButton {
    if (!_titleButton) {
        _titleButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        [_titleButton addTarget:self action:@selector(titleViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        [_titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleButton.frame.size.width - 20, 0, 0)];
        
        self.navigationItem.titleView = _titleButton;
    }
    return _titleButton;
}

- (NXPhotoPickerBarButton *)rightBarButtonView {
    if (! _rightBarButtonView) {
        
        _rightBarButtonView = [NXPhotoPickerBarButton barButtonWithTitle:@"继续" color:[UIColor colorWithHexString:@"#86c60f"] target:self selector:@selector(buttonFinishTouchUpInside:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonFinishTouchUpInside:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        [self updateRightBarButtonNum:0];
        [_rightBarButtonView addGestureRecognizer:tap];
        _rightBarButtonView.userInteractionEnabled = YES;
    }
    return _rightBarButtonView;
}

- (UIImage *)drawImageFromColor:(UIColor *)color size:(CGSize) size {
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)viewWillLayoutSubviews {
    [self.btTypeCloudTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    
    [self.btTypeCloudTitle setImageEdgeInsets:UIEdgeInsetsMake(0, self.btTypeCloudTitle.frame.size.width - 20, 0, 0)];
}

- (void)styleCloudInit {
   
    self.styleCloudBackGroundView.backgroundColor = [UIColor colorWithHexString:@"#E6E6E6"];

    if (_style == NXPhotoStyleCloud) {
        [self.btTypeCloudTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        
        [self.btTypeCloudTitle setImageEdgeInsets:UIEdgeInsetsMake(0, self.btTypeCloudTitle.frame.size.width - 20, 0, 0)];
        self.lbTypeCloudCount.textColor = [UIColor whiteColor];
        self.lbTypeCloudCount.backgroundColor = [UIColor colorWithHexString:@"#86c60f"];
        self.lbTypeCloudCount.layer.masksToBounds = YES;
        self.lbTypeCloudCount.layer.cornerRadius = self.lbTypeCloudCount.frame.size.height/2;
        
        self.styleCloudBackGroundView.hidden = NO;
        self.styleBackGroundViewHight.constant = 50;
        self.groupTableBottom.constant  = 50;

    } else {
        self.styleBackGroundViewHight.constant = 0;
        self.groupTableBottom.constant  = 0;

        self.styleCloudBackGroundView.hidden = YES;
    }
}

- (void)navigationDismiss {
    [self.navigationController.navigationBar setBackgroundImage:self.navigationColorImage forBarMetrics:UIBarMetricsDefault];
}
@end
