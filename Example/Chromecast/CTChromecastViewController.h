//
//  CTChromecastViewController.h
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTChromecastMoviePlayerController.h"

@interface CTChromecastViewController : UIViewController
@property (nonatomic, retain) CTChromecastMoviePlayerController *player;
@end
