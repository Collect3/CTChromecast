//
//  CTChromecastMoviePlayerController.m
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import "CTChromecastMoviePlayerController.h"
#import "CTChromecastManager.h"
#import "CTChromecastPlayer.h"
#import "CTChromecastVolumeView.h"
#import "CTChromecastDeviceListViewController.h"

NSString *CTChromecastMoviePlayerControllerDone     = @"CTChromecastMoviePlayerControllerDone";
NSString *CTChromecastMoviePlayerControllerNext     = @"CTChromecastMoviePlayerControllerNext";
NSString *CTChromecastMoviePlayerControllerPrevious = @"CTChromecastMoviePlayerControllerPrevious";
NSString *CTChromecastMoviePlayerPlaybackDidFinishNotification    = @"CTChromecastMoviePlayerPlaybackDidFinishNotification";
NSString *CTChromecastMoviePlayerLoadStateDidChangeNotification     = @"CTChromecastMoviePlayerLoadStateDidChangeNotification";
NSString *CTChromecastMoviePlayerPlaybackStateDidChangeNotification = @"CTChromecastMoviePlayerPlaybackStateDidChangeNotification";

@interface CTChromecastMoviePlayerInternalView : UIView
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *controlsView;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, assign) BOOL isFullscreen;
@property (nonatomic, unsafe_unretained) CTChromecastMoviePlayerController *controller;
- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;
- (void)cancelFullscreenTimeout;
- (void)scheduleFullscreenTimeout;
@end

@implementation CTChromecastMoviePlayerInternalView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        self.backgroundView = [[UIView alloc] initWithFrame: frame];
        self.backgroundView.backgroundColor = [UIColor redColor];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview: self.backgroundView];
    }
    return self;
}

- (void)setPlayerView:(UIView *)playerView {
    // Remove existing
    [_playerView removeFromSuperview];
    
    _playerView = playerView;
    _playerView.frame = self.bounds;
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self insertSubview:_playerView aboveSubview:self.backgroundView];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    
    // Toggle scaling mode on double tap
    if (sender.state == UIGestureRecognizerStateEnded)     {
        [self.controller toggleScalingMode];
    }
}

- (void)cancelFullscreenTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setFullscreenAnimated) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleFullscreen) object:nil];        
}

- (void)scheduleFullscreenTimeout {
    [self cancelFullscreenTimeout];
    [self performSelector:@selector(setFullscreenAnimated) withObject: nil afterDelay: 5.0f];
}

- (void)setFullscreenAnimated {
    [self setFullscreen:YES animated:YES];
}

- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    if (self.controlsView == nil) {
        return;
    }
    self.isFullscreen = fullscreen;    
    [[UIApplication sharedApplication] setStatusBarHidden:fullscreen withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    [UIView animateWithDuration:(animated) ? 0.35 : 0.0f animations:^(void) {
        self.controlsView.alpha = (fullscreen) ? 0.0f : 1.0;
    }];
    //self.controlsView.userInteractionEnabled = (fullscreen) ? NO : YES;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Reset the timer each time we do an action
    [self scheduleFullscreenTimeout];
    
    // Get the normal hit target
	UIView *hit = [super hitTest:point withEvent:event];
    
    // If interacting with a slider cancel the fullscreen timeout
    // But then add a hook so we can resume after touch up
    if ([hit isKindOfClass: [UISlider class]]) {
        [self cancelFullscreenTimeout];
        UISlider *s = (UISlider*)hit;
        [s addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    
    // If it's a subview of the control view then it's good to go
    if ([hit isDescendantOfView: self.controlsView] && hit != self.controlsView) {
        return hit;
        
    // Otherwise we'll register as a touch on us which will trigger a show / hide of controls.
    } else {
        return self;
    }
}

- (void)sliderTouchUp:(UISlider*)s {
    // Remove hook
    [s removeTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    // Schedule a new timeout
    [self scheduleFullscreenTimeout];
}

- (void)toggleFullscreen {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleFullscreen) object:nil];    
    [self setFullscreen:!self.isFullscreen animated:YES];    
}
- (void)toggleScale {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleScale) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleFullscreen) object:nil];
    [self.controller toggleScalingMode];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    if (t.tapCount == 1) {
        [self performSelector:@selector(toggleFullscreen) withObject: nil afterDelay: 0.35];
    } else if (t.tapCount == 2) {
        [self toggleScale];
    }
    [super touchesEnded: touches withEvent: event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.controller performSelector:@selector(viewWillLayoutSubviews)];
}
@end

@interface CTChromecastMoviePlayerController()
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) CTChromecastPlayer *chromecastPlayer;
@property (nonatomic, strong) NSObject <MPMediaPlayback> *activePlayer;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, assign) CFTimeInterval lastKnownTime;
@property (nonatomic, strong) CTChromecastMoviePlayerInternalView *internalView;
@end

@implementation CTChromecastMoviePlayerController
- (id)initWithContentURL:(NSURL *)url {
    if (self = [self init]) {
        
        self.movieSourceType = MPMovieSourceTypeFile;
        self.allowsAirPlay = YES;
        self.allowsChromecast = YES;
        
        // Setup default classes for control styles
        self.controlClassStyleDefault    = @"CTChromecastMovieControlsView";
        self.controlClassStyleEmbedded   = @"CTChromecastMovieControlsView";
        self.controlClassStyleFullscreen = @"CTChromecastMovieControlsView";
        self.controlClassStyleNone       = nil;
        
        _contentURL = url;

        // Create the current player as soon as possible
        // This way it ensures the same flow as wehn using
        // MPMoviePlayerController directly for methods such as
        // prepareToPlay
        self.activePlayer = [self setupPlayer];
                
        // Chromecast load state messages
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(movieLoadStateChangedNotification:)
                                                      name:MPMoviePlayerLoadStateDidChangeNotification
                                                    object:nil];
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(moviePlaybackStateChangedNotification:)
                                                      name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                    object:nil];
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(moviePlaybackDidFinishNotification:)
                                                      name:MPMoviePlayerPlaybackDidFinishNotification
                                                    object:nil];
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(movieDurationAvailableNotification:)
                                                      name:MPMovieDurationAvailableNotification
                                                    object:nil];

        
        // Chromecast movie notifications
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(movieLoadStateChangedNotification:)
                                                      name:CTChromecastPlayerLoadStateDidChangeNotification
                                                    object:nil];
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(moviePlaybackStateChangedNotification:)
                                                      name:CTChromecastPlayerPlaybackStateDidChangeNotification
                                                    object:nil];
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(moviePlaybackDidFinishNotification:)
                                                      name:CTChromecastPlayerPlaybackDidFinishNotification
                                                    object:nil];
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(movieDurationAvailableNotification:)
                                                      name:CTChromecastPlayerDurationAvailableNotification
                                                    object:nil];
        
        
        // Chromecast device notifications
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(deviceConnected)
                                                      name:CTChromecastManagerDidConnectToDeviceNotification
                                                    object:nil];
        
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(deviceDisconnected)
                                                      name:CTChromecastManagerDidDisconnectFromDeviceNotification
                                                    object:nil];
        
        // Device selection
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(deviceListShow)
                                                      name:CTChromecastDeviceListShow
                                                    object:nil];
        
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(deviceListHide)
                                                      name:CTChromecastDeviceListHide
                                                    object:nil];
        
    }
    return self;
}

- (void)startPlaybackTimer {
    // Timer that tracks playback time
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target:self
                                                        selector:@selector(playbackTimerTick)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)stopPlaybackTimer {
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
}

- (UIView*)view {
    if (_view == nil) {
        [self loadView];
        [self viewDidLoad];
    }
    return _view;
}

- (UIView*)backgroundView {
    return self.internalView.backgroundView;
}

- (void)loadView {
    self.internalView =  [[CTChromecastMoviePlayerInternalView alloc] init];
    self.internalView.controller = self;
    self.internalView.playerView = (self.activePlayer == self.moviePlayer) ? self.moviePlayer.view : self.chromecastPlayer.view;
    self.view = self.internalView;
}


- (void)deviceListShow {
    [self.internalView cancelFullscreenTimeout];
    [self.internalView setFullscreen:NO animated:NO];
}

- (void)deviceListHide {
    [self.internalView scheduleFullscreenTimeout];
}

- (void)viewDidLoad {
    [self loadControlsView];
}

- (void)viewWillLayoutSubviews {
    self.controlsView.frame = self.view.bounds;
    self.moviePlayer.view.frame = self.view.bounds;
    self.chromecastPlayer.view.frame = self.view.bounds;
}

- (void)setControlStyle:(MPMovieControlStyle)controlStyle {
    _controlStyle = controlStyle;

    // If we have created our view then recreate the controls view
    if (self.internalView) {
        [self loadControlsView];
    }
}

- (void)setInitialPlaybackTime:(NSTimeInterval)initialPlaybackTime {
    _initialPlaybackTime = initialPlaybackTime;
    if (self.moviePlayer) {
        self.moviePlayer.initialPlaybackTime = _initialPlaybackTime;
    } else {
        self.chromecastPlayer.initialPlaybackTime = _initialPlaybackTime;
    }
}

- (void)loadControlsView {
    Class viewClass = nil;

    if (self.controlStyle == MPMovieControlStyleDefault) {
        viewClass = NSClassFromString(self.controlClassStyleDefault);
    } else if (self.controlStyle == MPMovieControlStyleEmbedded) {
        viewClass = NSClassFromString(self.controlClassStyleEmbedded);
    } else if (self.controlStyle == MPMovieControlStyleFullscreen) {
        viewClass = NSClassFromString(self.controlClassStyleFullscreen);
    } else if (self.controlStyle == MPMovieControlStyleNone) {
        viewClass = NSClassFromString(self.controlClassStyleNone);
    }

    // Remove existing if one
    self.controlsView.delegate = nil;
    [self.controlsView removeFromSuperview];
    
    self.controlsView = [[viewClass alloc] initWithFrame: CGRectZero];
    self.controlsView.delegate = self;
    [(CTChromecastMoviePlayerInternalView*)self.view setControlsView: self.controlsView];
    [self.view addSubview: self.controlsView];
}

/** Not currently implemented */
- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    NSLog(@"CTChromecastMoviePlayerController: WARNING: setFullscreen:animated: not supported");
}

- (void)setContentURL:(NSURL *)contentURL {
    _contentURL = contentURL;
    if (self.moviePlayer) {
        self.moviePlayer.contentURL = contentURL;
    } else if (self.chromecastPlayer) {
        self.chromecastPlayer.contentURL = contentURL;
    }
}

- (BOOL)isChromecastVideoActive {
    return ([self.activePlayer isKindOfClass: [CTChromecastPlayer class]]);
}

- (BOOL)isAirPlayVideoActive {
    return self.moviePlayer.airPlayVideoActive;
}

- (void)setAllowsAirPlay:(BOOL)allowsAirPlay {
    _allowsAirPlay = allowsAirPlay;
    if (self.moviePlayer) {
        self.moviePlayer.allowsAirPlay = _allowsAirPlay;
    }
}

- (void)setMovieSourceType:(MPMovieSourceType)movieSourceType {
    _movieSourceType = movieSourceType;
    if (self.moviePlayer) {
        self.moviePlayer.movieSourceType = movieSourceType;
    }
}

#pragma mark -
#pragma mark State Management
#pragma mark -
- (id)setupPlayer {
    CTChromecastManager *manager = [CTChromecastManager sharedInstance];
    if (manager.activeDevice) {
        if (self.chromecastPlayer == nil) {
            self.chromecastPlayer = [[CTChromecastPlayer alloc] initWithContentURL: self.contentURL];
            self.chromecastPlayer.initialPlaybackTime = self.moviePlayer.currentPlaybackTime;
        }
        return self.chromecastPlayer;
    } else {
        if (self.moviePlayer == nil) {
            self.moviePlayer = [[MPMoviePlayerController alloc] init];
            
            // MPMoviePlayerController can crash if setting the content URL before
            // the movie source type, particuarlly with the streaming type.
            self.moviePlayer.movieSourceType = self.movieSourceType;
            [self.moviePlayer setContentURL: self.contentURL];
            self.moviePlayer.controlStyle = MPMovieControlStyleNone;
            self.moviePlayer.allowsAirPlay = self.allowsAirPlay;
            self.moviePlayer.initialPlaybackTime = self.chromecastPlayer.currentPlaybackTime;
        }
        return self.moviePlayer;
    }
}

- (void)switchOutput {
    // Flag to ignore movie player events when unloading / reloading
    self.isSwitchingOutput = YES;
    
    // Get new output player
    id previousPlayer = self.activePlayer;
    id newPlayer      = [self setupPlayer];
    
    // Nothing to do if we havent switched from the urrent
    if ([newPlayer isEqual: self.activePlayer]) {
        return;
    }
    
    // Setup the new player
    self.activePlayer = newPlayer;
    [newPlayer setInitialPlaybackTime: [previousPlayer currentPlaybackTime]];
    [newPlayer play];
    self.internalView.playerView = [newPlayer view];
    [self.controlsView moviePlayer:self updatedMovieScalingMode:self.scalingMode];
    //[self.view setNeedsLayout];
    
    // Tear down the old
    [previousPlayer stop];

    // Cleanup
    if ([previousPlayer isEqual: self.moviePlayer]) {
        self.moviePlayer = nil;
    } else if ([previousPlayer isEqual: self.chromecastPlayer]) {
        self.chromecastPlayer = nil;
    }
    previousPlayer = nil;
    
    self.isSwitchingOutput = NO;
}


- (void)playbackTimerTick {
    if (self.lastKnownTime != self.currentPlaybackTime) {
        if (self.playbackState == MPMoviePlaybackStatePlaying) {
            [self.controlsView moviePlayer:self playbackTimeUpdated:MAX(0,self.currentPlaybackTime)];
            self.lastKnownTime = self.currentPlaybackTime;
        }
    }
}

#pragma mark -
#pragma mark Manager Notifications
#pragma mark -
- (void)deviceConnected {
    [self switchOutput];
}

- (void)deviceDisconnected {
    [self switchOutput];
}


#pragma mark - 
#pragma mark Events
#pragma mark -
- (void)moviePlaybackStateChangedNotification:(NSNotification*)notification  {
    if (![notification.object isEqual: self.activePlayer]) {
        return;
    }
    
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        [self startPlaybackTimer];
    } else {
        [self stopPlaybackTimer];
    }
    
    [self.controlsView moviePlayer:self playStateUpdated: self.playbackState];
    
    if (!self.isSwitchingOutput) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastMoviePlayerPlaybackStateDidChangeNotification object:self];
    } else {
        NSLog(@"CTChromecastMoviePlayerController: Ignored %@", notification);
    }
    
}
- (void)movieLoadStateChangedNotification:(NSNotification*)notification {
    if (![notification.object isEqual: self.activePlayer]) {
        return;
    }

    [self.controlsView moviePlayer:self loadStateUpdated: self.loadState];

    if (!self.isSwitchingOutput) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastMoviePlayerLoadStateDidChangeNotification object:self];
    } else {
        NSLog(@"CTChromecastMoviePlayerController: Ignored %@", notification);
    }

    
}

- (void)movieDurationAvailableNotification:(NSNotification*)notification {
    if (![notification.object isEqual: self.activePlayer]) {
        return;
    }
    
    [self.controlsView moviePlayer:self durationUpdated: self.duration];
}

- (void)moviePlaybackDidFinishNotification:(NSNotification*)notification {
    if (![notification.object isEqual: self.activePlayer]) {
        return;
    }
    
    if (!self.isSwitchingOutput) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastMoviePlayerPlaybackDidFinishNotification object:self];
    } else {
        NSLog(@"CTChromecastMoviePlayerController: Ignored %@", notification);
    }
}
#pragma mark -
#pragma mark Forwarded Methods
#pragma mark -
- (MPMoviePlaybackState)playbackState {
    if (self.moviePlayer) {
        return self.moviePlayer.playbackState;
    } else {
        return self.chromecastPlayer.playbackState;
    }
}

- (MPMovieLoadState)loadState {
    if (self.moviePlayer) {
        return self.moviePlayer.loadState;
    } else {
        return self.chromecastPlayer.loadState;
    }
}

- (NSTimeInterval)duration {
    if (self.moviePlayer) {
        return self.moviePlayer.duration;
    } else {
        return self.chromecastPlayer.duration;
    }
}

- (NSTimeInterval)playableDuration {
    if (self.moviePlayer) {
        return self.moviePlayer.playableDuration;
    } else {
        // Note, just using duration here for now
        return self.chromecastPlayer.duration;
    }
}

- (void)toggleScalingMode {
    self.scalingMode = (self.scalingMode == MPMovieScalingModeAspectFill) ? MPMovieScalingModeAspectFit : MPMovieScalingModeAspectFill;
}

- (void)setScalingMode:(MPMovieScalingMode)scalingMode {
    if (self.moviePlayer) {
        self.moviePlayer.scalingMode = scalingMode;
    } else {

    }
    [self.controlsView moviePlayer:self updatedMovieScalingMode: self.scalingMode];
}

- (MPMovieScalingMode)scalingMode {
    if (self.moviePlayer) {
        return self.moviePlayer.scalingMode;
    } else {
        return MPMovieScalingModeAspectFit;
    }
}

- (MPMovieMediaTypeMask)movieMediaTypes {
    if (self.moviePlayer) {
        return self.moviePlayer.movieMediaTypes;
    } else {
        return MPMovieMediaTypeMaskVideo | MPMovieMediaTypeMaskAudio;
    }
}

- (CGSize)naturalSize {
    if (self.moviePlayer) {
        return self.moviePlayer.naturalSize;
    } else {
        NSLog(@"WARNING: naturalSize unimplemented when playing via chromecast");
        return CGSizeZero;
    }
}

#pragma mark -
#pragma mark MPMediaPlayback Proxy Methods
#pragma mark -
- (void)prepareToPlay {
    [self.activePlayer prepareToPlay];
}

- (void)play {
    [self.activePlayer play];
}

- (void)pause {
    [self.activePlayer pause];
}

- (void)stop {
    [self.activePlayer stop];
}

- (float)currentPlaybackRate {
    return [self.activePlayer currentPlaybackRate];
}

- (void)setCurrentPlaybackRate:(float)currentPlaybackRate {
    [self.activePlayer setCurrentPlaybackRate: currentPlaybackRate];
}

- (NSTimeInterval)currentPlaybackTime {
    return [self.activePlayer currentPlaybackTime];
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    [self.activePlayer setCurrentPlaybackTime: currentPlaybackTime];
}

- (void)beginSeekingForward {
    [self.activePlayer beginSeekingForward];
}

- (void)beginSeekingBackward {
    [self.activePlayer beginSeekingBackward];
}

- (void)endSeeking {
    [self.activePlayer endSeeking];
}

- (BOOL)isPreparedToPlay {
    return self.activePlayer.isPreparedToPlay;
}

#pragma mark -
#pragma mark Controls Delegate
#pragma mark -
- (void)movieControlsViewDone:(UIView*)view {
    [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastMoviePlayerControllerDone object:self];
    [self stop];    
}
- (void)movieControlsView:(UIView*)view didSeek:(NSTimeInterval)seekTime {
    NSLog(@"movieControlsView:%@ didSeek: %f",view, seekTime);
    self.currentPlaybackTime = seekTime;
}
- (void)movieControlsViewActionPlay:(UIView*)view {
    [self play];
}
- (void)movieControlsViewActionPause:(UIView*)view {
    [self pause];
}
- (void)movieControlsViewActionNext:(UIView*)view {
    [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastMoviePlayerControllerNext object:self];
}
- (void)movieControlsViewActionPrevious:(UIView*)view {
    [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastMoviePlayerControllerPrevious object:self];
}
- (void)movieControlsViewActionFastForward:(UIView*)view {
    self.currentPlaybackRate = 2.0;
}
- (void)movieControlsViewActionRewind:(UIView*)view {
    self.currentPlaybackRate = -2.0;
}
- (void)movieControlsViewActionNormalPlayrate:(UIView*)view {
    self.currentPlaybackRate = 1.0;
}
- (void)movieControlsViewActionAspectFill:(UIView*)view {
    [self setScalingMode: MPMovieScalingModeAspectFill];
}
- (void)movieControlsViewActionAspectFit:(UIView*)view {
    [self setScalingMode: MPMovieScalingModeAspectFit];
}
@end
