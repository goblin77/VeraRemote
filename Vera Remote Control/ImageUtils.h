//
//  ImageUtils.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageUtils : NSObject

+(UIImage *) imageFromLayer:(CALayer *) layer;
+(UIImage *) rescaleImage:(UIImage *) image toSize:(CGSize) newSize;
+(UIImage *) rescaleImageToScreenBounds:(UIImage *) originalImage;
+(UIImage *) imageFromBuffer:(CMSampleBufferRef) sampleBuffer;
+(UIImage *) imageByCroppingRect:(CGRect) cropRect fromImage:(UIImage *) image;
+(UIImage *) normalizeImageOrientation:(UIImage *) image;
+(double)    scaleForImage:(UIImage *) image inRectSize:(CGSize) size;
@end
