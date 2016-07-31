//
//  CustomView.h
//  Mandelbrot
//
//  Created by Oleg Golosovskiy on 18/07/16.
//  Copyright © 2016 Oleg Golosovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomView : UIView {

@public
// @property CGPoint shift; // to do почему нельзя сделать property visible?
    // какой тогда смысл в property? это тупо декларация интерфейса?
//    - (void) setScale:(int)a_scale; to do why not
// CGBitmapContext
    
    CGContextRef cacheContext;
    
    // global for image
    CGFloat _scale;
    CGPoint _shift;

    // only prieview (relatively original)
    CGFloat _preview_scale;
    CGPoint _prview_shift;

    
}

- (BOOL) initCacheContext:(CGSize)size;
- (void) drawImageToCache;
- (void) drawPreviewToCache;
- (BOOL) cacheContextResize:(CGSize)size;

@end
