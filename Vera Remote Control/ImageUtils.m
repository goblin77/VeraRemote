//
//  ImageUtils.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "ImageUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageUtils

+(UIImage *) imageFromLayer:(CALayer *) layer
{
    UIGraphicsBeginImageContext(layer.bounds.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * res = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return res;
    
}

+(UIImage *) rescaleImage:(UIImage *) image toSize:(CGSize) newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* res = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return res;
}

+(UIImage *) rescaleImageToScreenBounds:(UIImage *) originalImage
{
    BOOL isPortrait = originalImage.size.height > originalImage.size.width;
    CGFloat newWidth = 0;
    CGFloat newHeight= 0;
    CGFloat aspectRatio = originalImage.size.width / originalImage.size.height;
    
    if(isPortrait)
    {
        
        newWidth = [UIScreen mainScreen].bounds.size.width;
        newHeight = newWidth / aspectRatio;
    }
    else
    {
        newHeight = [UIScreen mainScreen].bounds.size.height;
        newWidth  = newHeight * aspectRatio;
    }

    
    return [ImageUtils rescaleImage:originalImage toSize:CGSizeMake(newWidth, newHeight)];
}


+ (UIImage *) imageFromBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    UIImage * res = [UIImage imageWithCGImage:newImage];
    CGImageRelease(newImage);
    
    return res;

}

+(UIImage *) imageByCroppingRect:(CGRect) cropRect fromImage:(UIImage *) image
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}


+(UIImage *) normalizeImageOrientation:(UIImage *) image
{
    if (image.imageOrientation == UIImageOrientationUp)
    {
        return image;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(double)    scaleForImage:(UIImage *) image inRectSize:(CGSize) size
{
    CGSize imgSize = image.size;
    CGFloat controlWidth, controlHeight;
    
    double aspectRatio = imgSize.width / imgSize.height;
    //portrait
    if(imgSize.height > imgSize.width)
    {
        controlWidth = size.width;
        controlHeight= size.width / aspectRatio;
        
        if(controlHeight < size.height)
        {
            return size.height / imgSize.height;
        }
        else
        {
            return size.width / imgSize.width;
        }
    }
    else
    {
        controlHeight = size.height;
        controlWidth  = size.height * aspectRatio;
        
        if(controlWidth < size.width)
        {
            return size.width / imgSize.width;
        }
        else
        {
            return size.height / imgSize.height;
        }
    }
}


@end
