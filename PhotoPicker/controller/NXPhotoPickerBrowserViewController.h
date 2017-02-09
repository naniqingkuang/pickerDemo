//
//  NXPhotoPickerBrowserViewController.h
//  NaXin
//
//  Created by 猪猪 on 2016/10/28.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGPhotoAsset.h"
#import "NXPhotoPickerViewController.h"

@class NXPhotoPickerBrowserViewController;

@protocol NXPhotoPickerBrowserViewControllerDelegate <NSObject>
- (NSInteger)NXPhotoPickerBrowserView:(NXPhotoPickerBrowserViewController *)browserVC numberOfItemsInSection:(NSInteger)section;

- (MGPhotoAsset *)NXPhotoPickerBrowserView:(NXPhotoPickerBrowserViewController *)browserVC ImageForIndexPath:(NSIndexPath *)indexPath;
- (void)NXPhotoPickerBrowserView:(NXPhotoPickerBrowserViewController *)browserVC didSecetedIndex:(NSIndexPath *)indexPath;
- (void)NXPhotoPickerBrowserViewDidFinishBrowser:(NXPhotoPickerBrowserViewController *)browserVC;
- (NSInteger)numberOfResult:(NXPhotoPickerBrowserViewController *)browserVC;
- (void)browserGoForward:(NXPhotoPickerBrowserViewController *)vc;
@end

@interface NXPhotoPickerBrowserViewController : UIViewController

@property (nonatomic, weak) id <NXPhotoPickerBrowserViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) NXPhotoStyle style;

@end
