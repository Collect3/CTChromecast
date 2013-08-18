//
//  CTChromecastMovieControlsView.m
//  Chromecast
//
//  Created by David Fumberger on 13/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import "CTChromecastMovieControlsView.h"
#import "CTChromecastVolumeView.h"
/*
 
 Seek Bar
 
 
*/


@interface CTChromecastSeekSlider : UISlider
@property (nonatomic, retain) UIImage *max;
@property (nonatomic, retain) UIImage *min;
@property (nonatomic, retain) UIImage *thumb;
@end

@implementation CTChromecastSeekSlider

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		_min     = [[UIImage imageNamed:@"movie-controls-seek-full.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        UIImage *maxImage = [UIImage imageNamed:@"movie-controls-seek-empty.png"];
		_max     = [maxImage stretchableImageWithLeftCapWidth:maxImage.size.width-5 topCapHeight:0];
        _thumb   = [UIImage imageNamed:@"movie-controls-seek-grip.png"];
        [self applyImages];        
    }
    return self;
}

- (void) setImagesForState:(UIControlState) state {
    [self setThumbImage: self.thumb        forState:state];
    [self setMaximumTrackImage:self.max    forState:state];
    [self setMinimumTrackImage:self.min    forState:state];
}

- (void) applyImages {
    [self setImagesForState:UIControlStateNormal];
    [self setImagesForState:UIControlStateDisabled];
    [self setImagesForState:UIControlStateHighlighted];
    [self setImagesForState:UIControlStateSelected];
}

@end


@interface CTChromecastTransportButton : UIButton
- (id)initWithImageName:(NSString*)imageName;
@end

@implementation CTChromecastTransportButton
- (id)initWithImageName:(NSString*)imageName {
    if (self = [super init]) {
        UIImage *image = [UIImage imageNamed: imageName];
        UIImage *highlighted = [UIImage imageNamed: [NSString stringWithFormat:@"%@-highlighted", imageName]];
        
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:highlighted forState:UIControlStateHighlighted];
        [self setImage:highlighted forState:UIControlStateSelected];
    }
    return self;
}

@end

@interface CTChromecastMovieSeeker : UIControl
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timeRemainingLabel;
@property (nonatomic, strong) CTChromecastSeekSlider *slider;
@property (nonatomic, assign) CFTimeInterval currentTime;
@property (nonatomic, assign) CFTimeInterval totalTime;
@property (nonatomic, assign) BOOL isUserSliding;
@property (nonatomic, assign) float value;
@end

@implementation CTChromecastMovieSeeker
- (id)initWithFrame:(CGRect)f {
    if (self = [super initWithFrame: f]) {
        
        UIColor *labelColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
        
        self.timeLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor = labelColor;
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview: self.timeLabel];
        
        self.timeRemainingLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        self.timeRemainingLabel.backgroundColor = [UIColor clearColor];
        self.timeRemainingLabel.font = [UIFont systemFontOfSize:12];
        self.timeRemainingLabel.textColor = labelColor;
        self.timeRemainingLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.timeRemainingLabel];
        
        self.slider = [[CTChromecastSeekSlider alloc] initWithFrame: CGRectZero];
        [self.slider addTarget:self action:@selector(actionSliderStartMove) forControlEvents:UIControlEventTouchDown];
        [self.slider addTarget:self action:@selector(actionSliderEndMove)   forControlEvents:UIControlEventTouchUpInside];
        [self.slider addTarget:self action:@selector(actionSliderDidChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview: self.slider];
                
        self.currentTime = 0.0f;
        self.totalTime = 0.0f;
        [self updateUI];
    }
    return self;
}

- (NSString*)timeToString:(CFTimeInterval)timeInterval {
	int timeIntervalInt = (int)timeInterval;
	int hours_val    = timeIntervalInt / (60 * 60);
	int left_seconds = (hours_val > 0)    ? (timeIntervalInt % (60 * 60 * hours_val)) : (timeIntervalInt);
	int minutes_val  = (left_seconds > 0) ? (left_seconds / 60) :(0);
	int seconds_val  = timeIntervalInt % 60;
	if (hours_val > 0) {
		return [NSString stringWithFormat:@"%i:%02d:%02d", hours_val, minutes_val, seconds_val];
	} else {
		return [NSString stringWithFormat:@"%02d:%02d", minutes_val, seconds_val];
	}
}

- (void)setCurrentTime:(CFTimeInterval)currentTime {
    _currentTime = currentTime;
    [self updateUI];
}

- (void)setTotalTime:(CFTimeInterval)totalTime {
    _totalTime = totalTime;
    [self updateUI];
}

- (void)updateUI {
    if (self.isUserSliding) {
        float slideTime = self.slider.value * self.totalTime;
        self.timeLabel.text          = [self timeToString: floorf(slideTime)];
        self.timeRemainingLabel.text = [self timeToString: floorf(self.totalTime) - floorf(slideTime)];
    } else {
        self.timeLabel.text          = [self timeToString: floorf(self.currentTime)];
        self.timeRemainingLabel.text = [self timeToString: floorf(self.totalTime) - floorf(self.currentTime)];
        self.slider.value            = (self.currentTime / self.totalTime);        
    }
}

- (float)value {
    return self.slider.value * self.totalTime;
}

- (void)actionSliderStartMove {
    self.isUserSliding = YES;
}

- (void)actionSliderEndMove {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    self.isUserSliding = NO;
}

- (void)actionSliderDidChange {
    [self updateUI];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float x = 0;
    float labelWidth = 40;
    
    self.timeLabel.frame = CGRectMake(0, 0, labelWidth, self.bounds.size.height);
    x += self.timeLabel.frame.size.width + 2;
    
    self.slider.frame = CGRectMake(x, 0, self.bounds.size.width - x - labelWidth, self.bounds.size.height);
    x += self.slider.frame.size.width + 2;
    
    self.timeRemainingLabel.frame = CGRectMake(x, 0, labelWidth, self.bounds.size.height);
    
    [self updateUI];
}

@end


@interface CTChromecastMovieNavigationBar : UINavigationBar
@property (nonatomic, strong) CTChromecastMovieSeeker *seeker;
@property (nonatomic, strong) UIBarButtonItem *aspectFillButton;
@property (nonatomic, strong) UIBarButtonItem *aspectFitButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, assign) BOOL aspectFill;
@end

@implementation CTChromecastMovieNavigationBar
- (id)initWithFrame:(CGRect)f {
    if (self = [super initWithFrame: f]) {
        

        // If iOS6 and below use an image as the background, otherwise use the default iOS7 background.
        if (![self respondsToSelector: @selector(tintColorDidChange)]) {
            self.tintColor = [UIColor blackColor];
            self.translucent = YES;
            [self setBackgroundImage:[UIImage imageNamed:@"movie-controls-transport-bg"] forBarMetrics:UIBarMetricsDefault];
            [self setBackgroundImage:[UIImage imageNamed:@"movie-controls-transport-bg"] forBarMetrics:UIBarMetricsLandscapePhone];
        }

        self.seeker = [[CTChromecastMovieSeeker alloc] initWithFrame: CGRectMake(0, 0, 1024, 40)];
        self.seeker.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        self.aspectFillButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"movie-controls-ratio-fullscreen"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(actionFullscreen)];
        self.aspectFitButton  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"movie-controls-ratio-letterbox"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(actionLetterbox)];
        self.doneButton       = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone)];
        
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:nil];
        navItem.titleView = self.seeker;
        navItem.leftBarButtonItem  = self.doneButton;
        navItem.rightBarButtonItem = self.aspectFillButton;
        [self pushNavigationItem: navItem animated:NO];
        
        self.aspectFill = NO;
    }
    return self;
}

- (void)setAspectFill:(BOOL)aspectFill {
    _aspectFill = aspectFill;
    self.topItem.rightBarButtonItem = (aspectFill) ? self.aspectFitButton : self.aspectFillButton;
}


- (void)actionDone {
    
}

- (void)actionFullscreen {
    
}

- (void)actionLetterbox {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //self.seeker.frame = self.bounds;
}
@end


/*
 
 Transport View
 
*/
@interface CTChromecastMovieTransportView : UIView
@property (nonatomic, strong) CTChromecastTransportButton *seekBackButton;
@property (nonatomic, strong) CTChromecastTransportButton *seekForwardButton;
@property (nonatomic, strong) CTChromecastTransportButton *playButton;
@property (nonatomic, strong) CTChromecastTransportButton *pauseButton;
@property (nonatomic, strong) CTChromecastVolumeView      *volumeSlider;
@property (nonatomic, strong) UIImageView                 *backgroundImageView;
@property (nonatomic, assign) BOOL playing;
@end

@implementation CTChromecastMovieTransportView
- (id)initWithFrame:(CGRect)f {
    if (self = [super initWithFrame: f]) {
        

        if ([self respondsToSelector: @selector(tintColorDidChange)]) {
            // If iOS7 use a toolbar as our backround to get some transparency
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: f];
            self.backgroundColor = [UIColor clearColor];
            self.backgroundImageView = (id)toolbar;
            [self addSubview: toolbar];
        } else {
            // iOS6 and below just use the image.
            self.backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"movie-controls-transport-bg"]];
            [self addSubview: self.backgroundImageView];
        }

        self.seekBackButton    = [[CTChromecastTransportButton alloc] initWithImageName: @"movie-controls-button-rewind"];
        [self addSubview: self.seekBackButton];
        
        self.seekForwardButton = [[CTChromecastTransportButton alloc] initWithImageName: @"movie-controls-button-fast-forward"];
        [self addSubview: self.seekForwardButton];
        
        self.playButton        = [[CTChromecastTransportButton alloc] initWithImageName: @"movie-controls-button-play"];
        [self addSubview: self.playButton];
        
        self.pauseButton       = [[CTChromecastTransportButton alloc] initWithImageName: @"movie-controls-button-pause"];
        [self addSubview: self.pauseButton];
                
        self.volumeSlider = [[CTChromecastVolumeView alloc] initWithFrame: CGRectZero];
        [self addSubview: self.volumeSlider];
    }
    return self;
}

- (void)setAlpha:(CGFloat)alpha {
    // For iOS7 toolbar to fade correctly
    for (UIView *v in self.subviews) {
        v.alpha = alpha;
    }
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [self layoutSubviews];
}

- (NSArray*)activeButtons {
    if (self.playing) {
        self.playButton.hidden = YES;
        self.pauseButton.hidden = !self.playButton.hidden;
        return @[ self.seekBackButton, self.pauseButton, self.seekForwardButton ];
    } else {
        self.playButton.hidden = NO;
        self.pauseButton.hidden = !self.playButton.hidden;
        return @[ self.seekBackButton, self.playButton, self.seekForwardButton ];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Setup buttons
    NSArray *buttons = [self activeButtons];

    // Metrics
    UIEdgeInsets margins = UIEdgeInsetsMake(0, 0, 0, 0);
    static float volumeHeight      = 22;
    static float maxContainerWidth = 300;
    static float maxTransportWidth = 280;
    static float buttonHeight      = 44;
    static float seperation        = 8;
    // Calc initial values
    float w = MIN(self.frame.size.width, maxContainerWidth) - margins.left - margins.right;
    float x = roundf((self.bounds.size.width - w) / 2.0)    + margins.left;
    float y = (self.bounds.size.height - (volumeHeight + buttonHeight + seperation)) / 2.0f + margins.top;
    
    // Layout slider
    self.volumeSlider.frame = CGRectMake(x, y, w, volumeHeight);
    y += self.volumeSlider.frame.size.height + seperation;
    //self.volumeSlider.backgroundColor = [UIColor redColor];

    // Layout buttons
    float buttonWidth = ( maxTransportWidth - margins.left - margins.right) / [buttons count];
    float buttonX     = x + roundf((maxContainerWidth - maxTransportWidth) / 2.0f);
    for (UIButton *b in buttons) {
        //b.backgroundColor = [UIColor greenColor];
        b.frame = CGRectMake(buttonX, y, buttonWidth, buttonHeight);
        buttonX += buttonWidth;
    }
    
    // Layout background
    self.backgroundImageView.frame = self.bounds;
}

- (void)updateUI {
    
}

@end

@interface CTChromecastMovieControlsView()
@property (nonatomic, strong) CTChromecastMovieTransportView *transportView;
@property (nonatomic, strong) CTChromecastMovieNavigationBar *navigationBar;
@property (nonatomic, strong) UIActivityIndicatorView *bufferingView;
@end

@implementation CTChromecastMovieControlsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.transportView = [[CTChromecastMovieTransportView alloc] initWithFrame: CGRectZero];
        [self addSubview: self.transportView];
        
        self.navigationBar = [[CTChromecastMovieNavigationBar alloc] initWithFrame: CGRectZero];
        [self addSubview: self.navigationBar];
        
        self.bufferingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview: self.bufferingView];
        
        
        [self.transportView.playButton        addTarget:self action:@selector(actionPlay:)              forControlEvents:UIControlEventTouchUpInside];
        [self.transportView.pauseButton       addTarget:self action:@selector(actionPause:)             forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar.seeker            addTarget:self action:@selector(actionSeekUpdated:)       forControlEvents:UIControlEventValueChanged];
        [self.transportView.seekForwardButton addTarget:self action:@selector(actionForwardTouchDown:)  forControlEvents:UIControlEventTouchDown];
        [self.transportView.seekForwardButton addTarget:self action:@selector(actionForwardTouchUp:)    forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self.transportView.seekBackButton    addTarget:self action:@selector(actionBackTouchDown:)     forControlEvents:UIControlEventTouchDown];
        [self.transportView.seekBackButton    addTarget:self action:@selector(actionBackTouchUp:)       forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        // Initialization code
        
        
        [self.navigationBar.aspectFillButton setTarget: self];
        [self.navigationBar.aspectFillButton setAction: @selector(actionAspectFill)];
        
        [self.navigationBar.aspectFitButton setTarget: self];
        [self.navigationBar.aspectFitButton setAction: @selector(actionAspectFit)];
        
        [self.navigationBar.doneButton setTarget:self];
        [self.navigationBar.doneButton setAction:@selector(actionDone)];
    }
    return self;
}

- (void)setAlpha:(CGFloat)alpha {
    self.transportView.alpha = alpha;
    self.navigationBar.alpha = alpha;
}

- (void)updateBuffering:(CTChromecastMoviePlayerController*)player {
    if (player.playbackState == MPMoviePlaybackStateInterrupted ||
        player.playbackState == MPMoviePlaybackStateSeekingForward ||
        player.playbackState == MPMoviePlaybackStateSeekingBackward ||    
        (player.loadState & MPMovieLoadStateStalled) == MPMovieLoadStateStalled ) {
        [self.bufferingView startAnimating];
    } else {
        [self.bufferingView stopAnimating];
    }

}

- (void)playRateForward {
    [self.delegate movieControlsViewActionFastForward:nil];
}
- (void)playRateBack {
    [self.delegate movieControlsViewActionRewind:nil];
}

- (void)actionDone {
    [self.delegate movieControlsViewDone:self];
}

- (void)actionForwardTouchDown:(CTChromecastTransportButton*)button {
    [self performSelector:@selector(playRateForward) withObject: nil afterDelay: 2.0];
}

- (void)actionBackTouchDown:(CTChromecastTransportButton*)button {
    [self performSelector:@selector(playRateBack) withObject: nil afterDelay: 2.0];
}

- (void)actionForwardTouchUp:(CTChromecastTransportButton*)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playRateForward) object:nil];    
    [self.delegate movieControlsViewActionNormalPlayrate: self];
}

- (void)actionBackTouchUp:(CTChromecastTransportButton*)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playRateBack) object:nil];
    [self.delegate movieControlsViewActionNormalPlayrate: self];
}

- (void)actionSeekUpdated:(CTChromecastMovieSeeker*)seeker {
    [self.delegate movieControlsView:self didSeek:seeker.value];
}

- (void)actionPlay:(CTChromecastTransportButton*)button {
    [self.delegate movieControlsViewActionPlay: self];
}

- (void)actionPause:(CTChromecastTransportButton*)button {
    [self.delegate movieControlsViewActionPause: self];
}

- (void)actionAspectFill {
    [self.delegate movieControlsViewActionAspectFill:self];
}

- (void)actionAspectFit {
    [self.delegate movieControlsViewActionAspectFit:self];
}

- (void)moviePlayer:(CTChromecastMoviePlayerController*)player playStateUpdated:(MPMoviePlaybackState)playbackState {
    self.transportView.playing = (player.playbackState == MPMoviePlaybackStatePlaying);
    [self updateBuffering: player];    
}

- (void)moviePlayer:(CTChromecastMoviePlayerController*)player loadStateUpdated:(MPMovieLoadState)loadState {
    [self updateBuffering: player];
}

- (void)moviePlayer:(CTChromecastMoviePlayerController*)player playbackTimeUpdated:(float)playbackTime {
    self.navigationBar.seeker.currentTime = playbackTime;
}

- (void)moviePlayer:(CTChromecastMoviePlayerController*)player durationUpdated:(float)duration {
    self.navigationBar.seeker.totalTime = duration;
}

- (void)moviePlayer:(CTChromecastMoviePlayerController *)player updatedMovieScalingMode:(MPMovieScalingMode)mode {
    if (mode == MPMovieScalingModeAspectFill) {
        self.navigationBar.aspectFill = YES;
    } else {
        self.navigationBar.aspectFill = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.transportView.frame = CGRectMake(0, self.bounds.size.height - 100, self.bounds.size.width, 100);
    
    [self.navigationBar sizeToFit];
    float statusBar = 20;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.bounds.size.width > self.bounds.size.height) {
        statusBar = 30;
    }
    self.navigationBar.frame = CGRectMake(0, 0, self.bounds.size.width, self.navigationBar.frame.size.height + statusBar);
    
    
    [self.bufferingView sizeToFit];
    self.bufferingView.frame = CGRectIntegral(CGRectMake((self.bounds.size.width - self.bufferingView.frame.size.width) / 2.0,
                                                         (self.bounds.size.height - self.bufferingView.frame.size.height) / 2.0,
                                                         self.bufferingView.frame.size.width,
                                                         self.bufferingView.frame.size.height));
}

@end
