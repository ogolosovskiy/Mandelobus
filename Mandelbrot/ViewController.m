//
//  ViewController.m
//  Mandelbrot
//
//  Created by Oleg Golosovskiy on 16/07/16.
//  Copyright © 2016 Oleg Golosovskiy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    CGPoint _originalShift;
    CGFloat _originalScale;
    bool    _block_pan;
    UIDeviceOrientation _orientation;
    UIButton *buttonSet;
}

@property (strong, nonatomic) CustomView* imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
  /*  UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationDetected:)];
    [self.view addGestureRecognizer:rotationRecognizer];
   */
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapRecognizer];
    
    panRecognizer.delegate = self;
    pinchRecognizer.delegate = self;
    _block_pan = false;
    //rotationRecognizer.delegate = self;
    // We don't need a delegate for the tapRecognizer
    
    
    _imageView = [[CustomView alloc] initWithFrame:self.view.bounds];
    _imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    _imageView.transform = CGAffineTransformIdentity;
    
    
    _imageView.backgroundColor=[UIColor blueColor];
    [self.view addSubview : _imageView];
    
    
    // Request to turn on accelerometer and begin receiving accelerometer events
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    _orientation = [[UIDevice currentDevice] orientation];
    
    
    // Button
    buttonSet = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSet setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    buttonSet.frame = CGRectMake(self.view.bounds.size.width-65, self.view.bounds.size.height-65, 50, 50);
    [buttonSet addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonSet];
    
    [_imageView drawImageToCache];
    
    NSLog(@"viewDidLoad");
}


- (void)settings {
    NSLog(@"settingsClicked");
    [self performSegueWithIdentifier:@"doSettings" sender:self];
}


-(void) viewDidDisappear {
    // Request to stop receiving accelerometer events and turn off accelerometer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)notification {
    
    UIDeviceOrientation new_or = [[UIDevice currentDevice] orientation];
    
    if(new_or!=_orientation && _orientation!=UIDeviceOrientationUnknown)
    {
        CGRect new_rect = self.view.bounds;
        [_imageView cacheContextResize :  new_rect.size];
        
        [buttonSet setFrame:CGRectMake(self.view.bounds.size.width-65, self.view.bounds.size.height-65, 50, 50)];

        [_imageView drawImageToCache];
    }
    
    _orientation = new_or;
}

/*
-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear : animated];
    CGRect rect = self->imageView.bounds;
    if ( YES!=[self->imageView initCacheContext : rect.size] )
    {
        NSLog(@"Can't create bitmap cache context");
    }
    else
    {
        [self.view setNeedsDisplay];
        NSLog(@"viewDidAppear");
    }
} */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture Recognizers

- (void)panDetected:(UIPanGestureRecognizer *)panRecognizer
{
    if(_block_pan)
    {
        [panRecognizer setTranslation: CGPointZero inView: self.view];
//         [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        return;
    }
    
    CGPoint translation = [panRecognizer translationInView:self.view];
    
/*    CGPoint imageViewPosition = _imageView.center;
    imageViewPosition.x += translation.x;
    imageViewPosition.y += translation.y;
    _imageView.center = imageViewPosition;
 */
    _imageView->_shift.x += translation.x;
    _imageView->_shift.y += translation.y;
   
    _imageView->_prview_shift.x += translation.x;
    _imageView->_prview_shift.y += translation.y;

    NSLog(@"panDetected %f %f %d", _imageView->_shift.x, _imageView->_shift.y, (int)panRecognizer.state);
    
    [panRecognizer setTranslation:CGPointZero inView:self.view];

    if(UIGestureRecognizerStateEnded==panRecognizer.state)
    {
        _imageView->_prview_shift.x = 0;
        _imageView->_prview_shift.y = 0;
        [_imageView drawImageToCache];
    }
    else
        [_imageView drawPreviewToCache];

}

- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer
{
    CGFloat scale = pinchRecognizer.scale;

    if(UIGestureRecognizerStateBegan==pinchRecognizer.state)
    {
        _originalScale = _imageView->_scale;
        _block_pan = true;
    }
    
    _imageView->_scale = scale * _originalScale;
    _imageView->_preview_scale = scale;

    
    NSLog(@"pinchDetected %f %f %d", scale, pinchRecognizer.velocity, (int)pinchRecognizer.state);
    NSLog(@"pinchDetected prev_scale %f scale %f", _imageView->_preview_scale, _imageView->_scale);
//    _imageView.transform = CGAffineTransformScale(_imageView.transform, scale, scale);
    //pinchRecognizer.scale = 1.0;
    
    
    if(UIGestureRecognizerStateEnded==pinchRecognizer.state)
    {
        _imageView->_shift.x *= _imageView->_preview_scale;
        _imageView->_shift.y *= _imageView->_preview_scale;
        _imageView->_preview_scale = 1;
        _block_pan = false;
        [_imageView drawImageToCache];
    }
    else
        [_imageView drawPreviewToCache];
}

/*
- (void)rotationDetected:(UIRotationGestureRecognizer *)rotationRecognizer
{
    CGFloat angle = rotationRecognizer.rotation;
    _imageView.transform = CGAffineTransformRotate(_imageView.transform, angle);
    rotationRecognizer.rotation = 0.0;
    
    [_imageView cacheContextResize : self.view.bounds.size ];
    
    [_imageView drawImageToCache ];
}
 */


- (void)tapDetected:(UITapGestureRecognizer *)tapRecognizer
{
    [UIView animateWithDuration:0.25 animations:^{
        _imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        _imageView.transform = CGAffineTransformIdentity;
    }];
    
    [_imageView drawImageToCache];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    
    NSString *segue_id = [segue identifier];
    NSLog(@"ViewController prepareForSegue %@", segue_id );
    
    if ([[segue identifier] isEqualToString:@"doSettings"])
    {
        SettingsViewController* secondView =  [segue destinationViewController];
        secondView.delegate = self;
    }
    else
    {
        [super prepareForSegue:segue sender:sender];
    }
}


- (void) setPalette : (enum palletteScheme) number {
    curScheme = number;
    NSLog(@"setPalette %d", number);
    [_imageView drawImageToCache];
}


@end


