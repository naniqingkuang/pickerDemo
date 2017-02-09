//
//  NXPKGroupTableViewCell.m
//  NaXin
//
//  Created by 猪猪 on 2016/11/1.
//  Copyright © 2016年 hzsd. All rights reserved.
//

#import "NXPKGroupTableViewCell.h"
#import "MGPhotoGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIColor+Photo.h"

@interface NXPKGroupTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupPicCountLabel;
@end
@implementation NXPKGroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = self.backgroundColor = [UIColor colorWithHexString:@"#d4cfcf"];
    // Initialization code
}


- (void)setGroup:(MGPhotoGroup *)group{
    _group = group;
    
    self.groupNameLabel.text = group.groupName;
    self.groupImageView.image = group.thumbImage;
    self.groupPicCountLabel.text = [NSString stringWithFormat:@"(%ld)",(long)group.assetsCount];
    self.groupNameLabel.textColor = self.groupPicCountLabel.textColor = [UIColor colorWithHexString:@"#2b2b2b"];
}


+ (instancetype) instanceCell{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
}

@end
