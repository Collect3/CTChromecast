//
//  CTChromecastVolumeView.m
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import "CTChromecastVolumeView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CTChromecastManager.h"

NSString *CTChromecastVolumeViewChangedNotification = @"VolumeChangedNotification";

void ctMediaVolumeSliderAudioVolumeChangeListenerCallback(void *inClientData, AudioSessionPropertyID    inID,
                                                          UInt32 inDataSize, const void *inData ){
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //NSLog(@"ctMediaVolumeSliderAudioVolumeChangeListenerCallback %f", [CTChromecastVolumeView currentSystemVolume]);
        [[NSNotificationCenter defaultCenter] postNotificationName: CTChromecastVolumeViewChangedNotification object: [NSNumber numberWithFloat:  [CTChromecastVolumeView currentSystemVolume]]];
    });
}


@interface CTChromecastSlider : UISlider
@property (nonatomic, retain) UIImage *max;
@property (nonatomic, retain) UIImage *min;
@property (nonatomic, retain) UIImage *thumb;
@end

@implementation CTChromecastSlider

- (void) setImagesForState:(UIControlState) state {
    [self setThumbImage: self.thumb        forState: state];
    [self setMaximumTrackImage:self.max    forState:state];
    [self setMinimumTrackImage:self.min    forState:state];
}

- (void) resetImages {
    //set for ALL control states
    [self setImagesForState:UIControlStateNormal];
    [self setImagesForState:UIControlStateDisabled];
    [self setImagesForState:UIControlStateHighlighted];
    [self setImagesForState:UIControlStateSelected];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        UIImage *maxImage = [UIImage imageNamed:@"chromecast-volume-slider-min.png"];
		self.min = [[UIImage imageNamed:@"chromecast-volume-slider-max.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		self.max = [maxImage stretchableImageWithLeftCapWidth:maxImage.size.width-5 topCapHeight:0];
        self.thumb = [UIImage imageNamed:@"chromecast-volume-slider-grip.png"];
        [self resetImages];
    }
}

@end

@implementation CTChromecastVolumeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.chromecastVolumeView = [[CTChromecastSlider alloc] initWithFrame: CGRectZero];
        [self.chromecastVolumeView addTarget:self action:@selector(chromecastVolumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
        self.chromecastVolumeView.value = 0.5f;
        [self addSubview: self.chromecastVolumeView];
                
#if TARGET_IPHONE_SIMULATOR
        self.volumeView = [[CTChromecastSlider alloc] initWithFrame: CGRectZero];
        [self.volumeView addTarget:self action:@selector(simulatorVolumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview: self.volumeView];
#else
        self.volumeView = [[MPVolumeView alloc] initWithFrame: CGRectZero];
        [self addSubview: self.volumeView];
#endif
        self.chromecastButton = [[CTChromecastButton alloc] initWithFrame: CGRectZero];
        [self addSubview: self.chromecastButton];
        
        [self setupListeners];
        [self devicesChanged];
    }
    return self;
}

- (void)dealloc {
    [self removeListeners];
}

#if TARGET_IPHONE_SIMULATOR
- (void)simulatorVolumeSliderChanged:(UISlider*)slider {
    [[NSNotificationCenter defaultCenter] postNotificationName: CTChromecastVolumeViewChangedNotification object: [NSNumber numberWithFloat: slider.value]];
}
#endif

- (void)chromecastVolumeSliderChanged:(UISlider*)slider {
    [[NSNotificationCenter defaultCenter] postNotificationName: CTChromecastVolumeViewChangedNotification object: [NSNumber numberWithFloat: slider.value]];
}

- (void)chromecastVolumeDidChangeNotification:(NSNotification*)note {
    self.chromecastVolumeView.value = [note.object floatValue];
}

+ (Float32)currentSystemVolume {
#if TARGET_IPHONE_SIMULATOR
    return 0.5f;
#else    
    Float32 volume;
    UInt32 dataSize = sizeof(Float32);
    
    AudioSessionGetProperty (
                             kAudioSessionProperty_CurrentHardwareOutputVolume,
                             &dataSize,
                             &volume
                             );
    return volume;
#endif
}

- (void)deviceConnected {
    [self updateUI];
}

- (void)deviceDisconnected {
    [self updateUI];    
}

- (void)setupListeners {
    // Chromecast device notifications
    [[NSNotificationCenter  defaultCenter] addObserver:self
                                              selector:@selector(deviceConnected)
                                                  name:CTChromecastManagerDidConnectToDeviceNotification
                                                object:nil];
    
    [[NSNotificationCenter  defaultCenter] addObserver:self
                                              selector:@selector(deviceDisconnected)
                                                  name:CTChromecastManagerDidDisconnectFromDeviceNotification
                                                object:nil];

    [[NSNotificationCenter  defaultCenter] addObserver:self
                                              selector:@selector(devicesChanged)
                                                  name:CTChromecastManagerDeviceListUpdatedNotification
                                                object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chromecastVolumeDidChangeNotification:)
                                                 name:@"CTChromecastPlayerVolumeDidChangeNotification"
                                               object:nil];
    AudioSessionSetActive (true);    
    AudioSessionAddPropertyListener (kAudioSessionProperty_CurrentHardwareOutputVolume ,
                                     ctMediaVolumeSliderAudioVolumeChangeListenerCallback, NULL);
}

- (void)removeListeners {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, ctMediaVolumeSliderAudioVolumeChangeListenerCallback, NULL);
}

- (void)devicesChanged {
    [self setIsChromecastAvailable: [[CTChromecastManager sharedInstance].devices count] > 0 animated: YES];
}

- (void)setIsChromecastAvailable:(BOOL)isChromecastAvailable animated:(BOOL)animated {
    _isChromecastAvailable = isChromecastAvailable;
    [UIView animateWithDuration:(animated) ? 0.35 : 0.0f
                     animations:^(void) {
                         [self updateUI];
                         [self layoutSubviews];
                     }];
}

- (void)updateUI {
    if ([[CTChromecastManager sharedInstance].devices count]) {
        self.chromecastButton.alpha = 1.0f;
    } else {
        self.chromecastButton.alpha = 0.0f;
    }
    
    if ([CTChromecastManager sharedInstance].activeDevice) {
        self.volumeView.hidden = YES;
        self.chromecastVolumeView.hidden = NO;
        self.chromecastButton.selected = YES;
    } else {
        self.volumeView.hidden = NO;
        self.chromecastVolumeView.hidden = YES;
        self.chromecastButton.selected = NO;
    }
}

- (CGSize)sizeThatFits:(CGSize)s {
    return CGSizeMake(s.width, 22);
}

- (void)layoutSubviews {
    UIEdgeInsets buttonPading = UIEdgeInsetsMake(0, 5, 0, 5);
    [self.chromecastButton sizeToFit];
    CGRect chromecastFrame = self.chromecastButton.frame;
    
    CGRect volumeFrame = self.bounds;
    volumeFrame.size.width -= (chromecastFrame.size.width + buttonPading.left + buttonPading.right);
    
    chromecastFrame.origin.x = volumeFrame.size.width + buttonPading.left;
    chromecastFrame.origin.y = volumeFrame.origin.y - roundf((chromecastFrame.size.height - volumeFrame.size.height) / 2.0);
    
    self.volumeView.frame = volumeFrame;
    self.chromecastButton.frame = chromecastFrame;
    self.chromecastVolumeView.frame = volumeFrame;
    
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
