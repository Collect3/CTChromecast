//
//  CTChromecastMovieControlsView.h
//  Chromecast
//
//  Created by David Fumberger on 13/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTChromecastMoviePlayerController.h"

@interface CTChromecastMovieControlsView : UIView <CTChromecastMovieControlsViewProtocol>
@property (nonatomic, assign) id delegate;
@end

@protocol CTChromecastMovieControlsViewDelegate <NSObject>

- (void)movieControlsView:(UIView*)view didSeek:(NSTimeInterval)seekTime;
- (void)movieControlsViewDone:(UIView*)view;
- (void)movieControlsViewActionPlay:(UIView*)view;
- (void)movieControlsViewActionPause:(UIView*)view;
- (void)movieControlsViewActionNext:(UIView*)view;
- (void)movieControlsViewActionPrevious:(UIView*)view;
- (void)movieControlsViewActionFastForward:(UIView*)view;
- (void)movieControlsViewActionRewind:(UIView*)view;
- (void)movieControlsViewActionNormalPlayrate:(UIView*)view;
- (void)movieControlsViewActionAspectFill:(UIView*)view;
- (void)movieControlsViewActionAspectFit:(UIView*)view;
@end