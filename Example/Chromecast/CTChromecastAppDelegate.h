//
//  CTChromecastAppDelegate.h
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTChromecastViewController;

@interface CTChromecastAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CTChromecastViewController *viewController;

@end
