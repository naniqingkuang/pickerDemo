//
//  NXPopTipView.h
//  NaXin
//
//  Created by hzsd on 15/9/11.
//  Copyright (c) 2015年 hzsd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, tipLabelShowType)
{
    tipLabelShowTypeTop,
    tipLabelShowTypeCenter,
    tipLabelShowTypeBottom
};
@interface MGPopTipView : UILabel

@property (nonatomic, assign) CFTimeInterval forwardAnimationDuration;
@property (nonatomic, assign) CFTimeInterval backwardAnimationDuration;
@property (nonatomic, assign) UIEdgeInsets   textInsets;
@property (nonatomic, assign) CGFloat        maxWidth;

+ (id)toastWithText:(NSString *)text;

- (id)initWithText:(NSString *)text;
- (void)showInView:(UIView *)view timeInterVal:(CGFloat)time;    //Default is DSToastShowTypeBottom
- (void)showInView:(UIView *)view showType:(tipLabelShowType)type;

- (void)show;

@end
