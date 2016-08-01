//
//  SettingsViewCotrollerViewController.h
//  Mandelbrot
//
//  Created by Oleg Golosovskiy on 30/07/16.
//  Copyright © 2016 Oleg Golosovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mandelbrot.h"


@protocol SettingsViewControllerDelegate
@optional
- (void) setPalette : (enum palletteScheme) number;
@end

@interface SettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
}
@property (nonatomic, assign) id  <SettingsViewControllerDelegate> delegate;
@end
