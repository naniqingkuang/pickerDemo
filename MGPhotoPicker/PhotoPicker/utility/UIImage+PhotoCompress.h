//
//  UIImage+PhotoCompress.h
//  pickerDemo
//
//  Created by 猪猪 on 2017/2/7.
//  Copyright © 2017年 猪猪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PhotoCompress)
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;

+ (void) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size compressPhotoBlock:(void(^)(UIImage *))compressPhotoBlock;

+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

- (UIImage *)rescaleImageToSize:(CGSize)size;


+ (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;

-(id)diskImageDataBySearchingAllPathsForKey:(id)key;

+(CGSize)downloadImageSizeWithURL:(id)imageURL;

+(CGSize)downloadPNGImageSizeWithRequest:(NSMutableURLRequest*)request;

+(CGSize)downloadGIFImageSizeWithRequest:(NSMutableURLRequest*)request;

+(CGSize)downloadJPGImageSizeWithRequest:(NSMutableURLRequest*)request;

+ (UIImage *)imageNamed:(NSString *)name withScale:(CGFloat)scale;

@end
