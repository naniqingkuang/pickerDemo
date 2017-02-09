//
//  NXPhotoPickerBarButton.m
//  NaXin
//
//  Created by 猪猪 on 2016/10/28.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import "NXPhotoPickerBarButton.h"
#import "UIColor+Photo.h"

#define lb_with   20
#define textFont  [UIFont systemFontOfSize:15]

@interface NXPhotoPickerBarButton()
@property (nonatomic, strong) UILabel *lbNum;
@property (nonatomic, strong) UIButton *btTitle;
@property (nonatomic, strong) NSString *title;
@end

@implementation NXPhotoPickerBarButton
- (instancetype)init
{

    return [self initWithFrame:CGRectZero];

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.lbNum];
        [self addSubview:self.btTitle];
    }
    return self;
}
- (void)layoutSubviews {
    float btWidth = [self.title boundingRectWithSize:CGSizeMake(60, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil].size.width;
    
    self.btTitle.frame = CGRectMake(self.frame.size.width - btWidth+10, 0, btWidth, self.frame.size.height);
    self.lbNum.frame = CGRectMake(self.frame.size.width - btWidth -lb_with-5+10, (self.frame.size.height - lb_with)/2, lb_with, lb_with);
    
}
- (UILabel *)lbNum {
    if (! _lbNum) {
        _lbNum = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, lb_with, lb_with)];
        _lbNum.layer.cornerRadius = _lbNum.frame.size.width/2;
        _lbNum.layer.masksToBounds = YES;
        _lbNum.font = textFont;
        _lbNum.textColor = [UIColor whiteColor];
        _lbNum.textAlignment = NSTextAlignmentCenter;

    }
    return _lbNum;
}

- (UIButton *)btTitle {
    if (!_btTitle) {
        _btTitle = [[UIButton alloc]initWithFrame:CGRectMake(lb_with, 0, self.frame.size.width - lb_with, self.frame.size.height)];
        [_btTitle.titleLabel setTextAlignment:NSTextAlignmentRight];
        _btTitle.titleLabel.font = textFont;
    }
    return _btTitle;
}
+ (NXPhotoPickerBarButton *)barButtonWithTitle:(NSString *)title color:(UIColor *)color target:(id)obj  selector:(SEL) selector {
    NXPhotoPickerBarButton *view = [[NXPhotoPickerBarButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    view.lbNum.backgroundColor = color;
    [view.btTitle addTarget:obj action:selector forControlEvents:UIControlEventTouchUpInside];
    view.title = title;
    [view.btTitle setTitleColor:color forState:UIControlStateNormal];
    [view.btTitle setTitle:title forState:UIControlStateNormal];
    return view;
}

- (void)setNum:(NSInteger )num {
    if (num > 0) {
        self.lbNum.hidden = NO;
        [self.btTitle setTitleColor:[UIColor colorWithHexString:@"#86c60f"] forState:UIControlStateNormal];
    } else {
        self.lbNum.hidden = YES;
        [self.btTitle setTitleColor:[UIColor colorWithHexString:@"#505050"] forState:UIControlStateNormal];
    }
    self.lbNum.text = [NSString stringWithFormat:@"%ld",num];

}


@end
