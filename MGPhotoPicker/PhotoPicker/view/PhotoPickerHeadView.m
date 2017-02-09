//
//  PhotoPickerHeadView.m
//  NaXin
//
//  Created by 猪猪 on 2016/10/27.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import "PhotoPickerHeadView.h"

@interface PhotoPickerHeadView ()
@property (weak, nonatomic) IBOutlet UIImageView *imgTakePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *imgNaxinPhoto;

@end

@implementation PhotoPickerHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTap:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTap:)];
    tap0.numberOfTapsRequired = 1;
    tap0.numberOfTouchesRequired = 1;

    [self.imgTakePhoto addGestureRecognizer:tap0];
    [self.imgNaxinPhoto addGestureRecognizer:tap1];
    // Initialization code
}

- (void)imageTap:(UITapGestureRecognizer *)tap {
    if (tap.view == self.imgNaxinPhoto) {
        if (self.selectedBlock) {
            self.selectedBlock(1);
        }
        
    } else if(tap.view == self.imgTakePhoto) {
        if (self.selectedBlock) {
            self.selectedBlock(0);
        }

    }
}
@end
