//
//  NXPhotoPickerBarButton.h
//  NaXin
//
//  Created by 猪猪 on 2016/10/28.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXPhotoPickerBarButton : UIView
- (void)setNum:(NSInteger )num;
+ (NXPhotoPickerBarButton *)barButtonWithTitle:(NSString *)title color:(UIColor *)color target:(id)obj  selector:(SEL) selector;
@end
