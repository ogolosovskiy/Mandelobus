//
//  CustomView.m
//  Mandelbrot
//
//  Created by Oleg Golosovskiy on 18/07/16.
//  Copyright © 2016 Oleg Golosovskiy. All rights reserved.
//

#import "CustomView.h"
@import CoreGraphics;
#import <UIKit/UIKit.h>

#import "mandelbrot.h"

const float _initial_size = 4;

@implementation CustomView
{
    bool _need_preview_transform;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
            if ( YES!=[self initCacheContext : frame.size] )
            {
                NSLog(@"Can't create bitmap cache context");
            }
            else
            {
                NSLog(@"initWithFrame success");
            }
    }
    return self;
}

- (void) dealloc {

}


- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
  
    CGRect centerdRect = rect;

    if(_need_preview_transform)
    {
        // transform for preview (for original tempShift = 0 tempScale = 1)
        CGContextTranslateCTM(context, _prview_shift.x, _prview_shift.y);
        CGContextScaleCTM(context, _preview_scale, _preview_scale);
        
        // to center preview image // to do is there api?
        centerdRect.origin.x = (self.bounds.size.width  * (1.0-_preview_scale))/2.0;
        centerdRect.origin.x *= (1.0/_preview_scale);
        centerdRect.origin.y = (self.bounds.size.height  * (1.0-_preview_scale))/2.0;
        centerdRect.origin.y *= (1.0/_preview_scale);
      
    }
    else
    {
       CGContextTranslateCTM(context, 0, 0);
       CGContextScaleCTM(context, 1, 1);
    }
    
    NSLog(@" *** Draw ***");
    NSLog(@"s.bounds %.0f %.0f %.0f %.0f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    NSLog(@"dr.rect %.0f %.0f %.0f %.0f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    NSLog(@"s.shift  %.0f %.0f ", centerdRect.origin.x, centerdRect.origin.y);
 
    
    CGContextDrawImage(context, centerdRect, cacheImage);
    
    CGImageRelease(cacheImage);
}


- (BOOL) initCacheContext:(CGSize)size {
    
    int bitmapByteCount;
    int	bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap
    // is represented by 4 bytes; 8 bits each of red, green, blue, and alpha.
    bitmapBytesPerRow = (size.width * 4);
    bitmapByteCount = (bitmapBytesPerRow * size.height);
    
    cacheContext = CGBitmapContextCreate (NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
    
    _need_preview_transform = false;
    _scale = 1;
    _shift.x = 50;
    _shift.y = 0;

    _preview_scale = 1;
    _prview_shift.x = 50;
    _prview_shift.y = 0;

    [self drawImageToCache];
    
    return NULL!=cacheContext;
}


- (BOOL) cacheContextResize:(CGSize)size {
    
    int bitmapByteCount;
    int	bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap
    // is represented by 4 bytes; 8 bits each of red, green, blue, and alpha.
    bitmapBytesPerRow = (size.width * 4);
    bitmapByteCount = (bitmapBytesPerRow * size.height);
    
    cacheContext = CGBitmapContextCreate (NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
    
    NSLog(@"cacheContextResize %.0f %.0f", size.width, size.height);

    CGRect newFrame = self.frame;
    newFrame.size = size;
    [self setFrame:newFrame];
    
    return NULL!=cacheContext;
}

- (void) drawPreviewToCache
{
    _need_preview_transform = true;
    [self setNeedsDisplay];
}






- (void) drawImageToCache {
    
    // to do optimize
    CGSize size = CGSizeMake(CGBitmapContextGetWidth(cacheContext), CGBitmapContextGetHeight(cacheContext));

    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, 1);
    
    CGContextClearRect(cacheContext, CGRectMake(0, 0, size.width, size.height));
    CGPoint center = CGPointMake(size.width/2, size.height/2);

    if(false)
    {
    
        UIColor *color = [UIColor redColor];
        CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
        int rectSize = 100 * _scale;
        center.x = center.x + _shift.x - rectSize/2;
        center.y = center.y + _shift.y - rectSize/2;
        CGRect rect = CGRectMake(center.x, center.y, rectSize, rectSize);
        CGContextAddRect(cacheContext, rect);
        CGContextDrawPath(cacheContext, kCGPathFillStroke);

    }
    else
    {
    
        float proportion = size.height/size.width;
        
        // координаты на комплексной плоскости
        // rect size
        float cr_size = _initial_size / _scale;
        float ci_size = cr_size * proportion;
        // step
        float cr_step = cr_size / size.width;
        float ci_step = ci_size / size.height; // to do == cr_step
        // перевод из координат в контексте в комплексную плоскость
        float cr_to_image_scale = (float)(size.width)/cr_size;
        float ci_to_image_scale = (float)(size.height)/ci_size; // to do == cr_to_image_scale
        // center on complex
        float cr_center = - _shift.x / cr_to_image_scale;
        float ci_center = - _shift.y / ci_to_image_scale;

        
        float cr, ci = 0;
        for(cr=cr_center-cr_size/2; cr<cr_center+cr_size/2; cr += cr_step)
        {
            for(ci=ci_center-ci_size/2; ci<ci_center+ci_size/2; ci += ci_step)
            {
                UIColor *color =  calculateColor(cr, ci);
                CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    
                float left  = 0;
                // лево в комплексных координатах
                left = cr;
                // нужно отцентровать картинку
                left -= cr_center-cr_size/2;
                // в координатах контекста
                left *= cr_to_image_scale;
                
                float up    = (ci - (ci_center-ci_size/2)) * ci_to_image_scale;
                
                CGContextAddRect(cacheContext, CGRectMake(left, up, 1, 1));


/*                UIColor *color =  [UIColor yellowColor];
                CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
                float rect_size = 1;
                // лево в комплексных координатах
                // в координатах контекста
                // нужно центр в комп плоскости совместить с цетром экрана
                float left  = (cr_center-rect_size/2) * cr_to_image_scale + size.width/2;
                float up    = (ci_center-rect_size/2) * ci_to_image_scale + size.height/2;
                CGContextAddRect(cacheContext, CGRectMake(
                                                          left,
                                                          up,
                                                          rect_size * cr_to_image_scale,
                                                          rect_size * ci_to_image_scale));
 */

                CGContextDrawPath(cacheContext, kCGPathFillStroke);
            }
        }


/*        UIColor *color = [UIColor redColor];
        // context center
        CGPoint center = CGPointMake(size.width/2, size.height/2);
        // real c + shift
        cr = cr + (_shift.x / cr_to_image_scale);
        ci = ci + (_shift.y / ci_to_image_scale);
        float c_size = 1;
        
        CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
        CGContextAddRect(cacheContext, CGRectMake((cr - c_size/2)*cr_to_image_scale + center.x,
                                                  (ci - c_size/2)*ci_to_image_scale + center.y,
                                                  c_size*cr_to_image_scale,
                                                  c_size*ci_to_image_scale));
        CGContextDrawPath(cacheContext, kCGPathFillStroke);
 */
 
    }
    
    _need_preview_transform = false;
    [self setNeedsDisplay]; 
}


@end