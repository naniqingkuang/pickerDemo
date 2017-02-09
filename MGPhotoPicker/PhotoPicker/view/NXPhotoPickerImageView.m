//
//  PickerImageView.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "NXPhotoPickerImageView.h"
#import "UIColor+Photo.h"

#define clickItemWidth  18

@interface NXPhotoPickerImageView ()

@property (nonatomic , weak) UIView *maskView;
@property (nonatomic , strong) UILabel *lbTick;
@property (nonatomic , weak) UIImageView *videoView;
@property (nonatomic, strong) UIButton *clickedButton;
@property (nonatomic, strong) UIButton *clickedGroundButton;

@end

@implementation NXPhotoPickerImageView

//- (id)initWithFrame:(CGRect)frame cellIndexPath:(NSIndexPath *)indexPath
//{
//    if (self = [super initWithFrame:frame]) {
//        self.contentMode = UIViewContentModeScaleAspectFill;
//        self.clipsToBounds = YES;
//        _indexPath = indexPath;
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        [self.clickedButton addTarget:self action:@selector(buttonClickedActoin) forControlEvents:UIControlEventTouchUpInside];
        [self.clickedGroundButton addTarget:self action:@selector(buttonClickedActoin) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

- (UIView *)maskView{
    if (!_maskView) {
        UIView *maskView = [[UIView alloc] init];
        maskView.frame = self.bounds;
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.alpha = 0;
        maskView.hidden = YES;
//        maskView.userInteractionEnabled = YES;
        [self addSubview:maskView];
        self.maskView = maskView;
    }
    return _maskView;
}

- (UIImageView *)videoView{
    if (!_videoView) {
        UIImageView *videoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.bounds.size.height - 40, 30, 30)];
        videoView.image = [UIImage imageNamed:@"video"];
        videoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:videoView];
        self.videoView = videoView;
    }
    return _videoView;
}
- (UILabel *)lbTick {
    if(!_lbTick) {
        _lbTick = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width -clickItemWidth -3, 3, clickItemWidth, clickItemWidth)];
        [_lbTick setTextColor:[UIColor whiteColor]];
        _lbTick.backgroundColor = [UIColor colorWithRed:0.27 green:0.64 blue:0.19 alpha:1];
        [_lbTick setTextAlignment:NSTextAlignmentCenter];
        _lbTick.layer.cornerRadius = 10;
        _lbTick.layer.masksToBounds = YES;
        [self addSubview:_lbTick];
    }
    return _lbTick;
}
- (UIButton *)clickedButton {
    if(!_clickedButton) {
        _clickedButton = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width -clickItemWidth-3, 3, clickItemWidth, clickItemWidth)];
        _clickedButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_clickedButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_clickedButton];
    }
    return _clickedButton;
}

- (UIButton *)clickedGroundButton {
    if (!_clickedGroundButton) {
        _clickedGroundButton = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width -clickItemWidth - 15, 0, clickItemWidth+15, clickItemWidth+15)];
        [self addSubview:_clickedGroundButton];
        
    }
    return _clickedGroundButton;
}
- (void)buttonClickedActoin {
    if(_buttonBlock) {
        self.buttonBlock();
    }
}
- (void)setIsVideoType:(BOOL)isVideoType{
    _isVideoType = isVideoType;
    
    self.videoView.hidden = !(isVideoType);
}

- (void)setMaskViewFlag:(BOOL)maskViewFlag{
    _maskViewFlag = maskViewFlag;
    self.maskView.hidden = !maskViewFlag;
   // self.lbTick.hidden =!maskViewFlag;
}

- (void)setMaskViewColor:(UIColor *)maskViewColor{
    _maskViewColor = maskViewColor;
    
    self.maskView.backgroundColor = maskViewColor;
}

- (void)setMaskViewAlpha:(CGFloat)maskViewAlpha{
    _maskViewAlpha = maskViewAlpha;

    self.maskView.alpha = maskViewAlpha;
}

- (void)setAnimationRightTick:(BOOL)animationRightTick{
    _animationRightTick = animationRightTick;
}
- (void)setCount:(NSInteger )count {
    _count = count;
    if(_count > 0) {
        _clickedButton.layer.cornerRadius = clickItemWidth/2;
        _clickedButton.layer.masksToBounds = YES;
        _clickedButton.backgroundColor = [UIColor colorWithHexString:@"#86c60f"];
        [_clickedButton setTitle:[NSString stringWithFormat:@"%ld",count] forState:UIControlStateNormal];
        [_clickedButton setBackgroundImage:nil forState:UIControlStateNormal];
    } else {
        _clickedButton.layer.cornerRadius = 0;
        _clickedButton.layer.masksToBounds = NO;
        _clickedButton.backgroundColor = [UIColor colorWithHexString:@"#86c60f"];
        _clickedButton.backgroundColor = [UIColor clearColor];

        [_clickedButton setBackgroundImage:[UIImage imageNamed:@"photoPickUnselect"] forState:UIControlStateNormal];
        [_clickedButton setTitle:@"" forState:UIControlStateNormal];

    }
}


@end
