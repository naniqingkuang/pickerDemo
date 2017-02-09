//
//  NSString+Photo.m
//  pickerDemo
//
//  Created by 猪猪 on 2017/2/7.
//  Copyright © 2017年 猪猪. All rights reserved.
//

#import "NSString+Photo.h"

@implementation NSString (Photo)
- (NSString *)stringByTrim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

@end
