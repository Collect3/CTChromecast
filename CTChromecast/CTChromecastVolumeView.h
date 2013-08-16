//
//  CTChromecastVolumeView.h
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTChromecastButton.h"
#include <MediaPlayer/MediaPlayer.h>

extern NSString *CTChromecastVolumeViewChangedNotification;

@interface CTChromecastVolumeView : UIView

// The simulator wont show a volume slider
// So just emulate one here.
#if TARGET_IPHONE_SIMULATOR
@property (nonatomic, strong) UISlider *volumeView;
#else
@property (nonatomic, strong) MPVolumeView *volumeView;;
#endif 
@property (nonatomic, strong) UISlider *chromecastVolumeView;
@property (nonatomic, strong) CTChromecastButton *chromecastButton;
@property (nonatomic, assign) BOOL isChromecastAvailable;
+ (Float32)currentSystemVolume;
@end
