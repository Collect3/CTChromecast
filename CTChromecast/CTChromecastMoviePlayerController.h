//
//  CTChromecastMoviePlayerController.h
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "CTChromecastVolumeView.h"

/** Triggered when the done button is hit */
extern NSString *CTChromecastMoviePlayerControllerDone;

/** Triggered when the next button is hit */
extern NSString *CTChromecastMoviePlayerControllerNext;

/** Triggered when the prev button is hit */
extern NSString *CTChromecastMoviePlayerControllerPrevious;

extern NSString *CTChromecastMoviePlayerPlaybackDidFinishNotification;
extern NSString *CTChromecastMoviePlayerLoadStateDidChangeNotification;
extern NSString *CTChromecastMoviePlayerPlaybackStateDidChangeNotification;

@class CTChromecastMoviePlayerController;
@protocol CTChromecastMovieControlsViewProtocol <NSObject>
@property (nonatomic, assign) id delegate;
- (void)moviePlayer:(CTChromecastMoviePlayerController*)player playStateUpdated:(MPMoviePlaybackState)playbackState;
- (void)moviePlayer:(CTChromecastMoviePlayerController*)player loadStateUpdated:(MPMoviePlaybackState)playbackState;
- (void)moviePlayer:(CTChromecastMoviePlayerController*)player playbackTimeUpdated:(float)playbackTime;
- (void)moviePlayer:(CTChromecastMoviePlayerController*)player durationUpdated:(float)durationTime;
- (void)moviePlayer:(CTChromecastMoviePlayerController *)player updatedMovieScalingMode:(MPMovieScalingMode)mode;
@end

@interface CTChromecastMoviePlayerController : NSObject <MPMediaPlayback>
@property (nonatomic, retain) CTChromecastVolumeView *volumeSlider;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, readonly) UIView *backgroundView;
@property (nonatomic, retain) UIView <CTChromecastMovieControlsViewProtocol> *controlsView;
@property (nonatomic, retain) NSURL *contentURL;

@property (nonatomic) MPMovieSourceType movieSourceType;
@property (nonatomic, readonly) MPMovieMediaTypeMask movieMediaTypes;
@property (nonatomic, readonly) CGSize naturalSize;

@property (nonatomic) MPMovieControlStyle controlStyle;
@property (nonatomic, readonly) MPMoviePlaybackState playbackState;
@property (nonatomic, readonly) MPMovieLoadState loadState;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval playableDuration;
@property (nonatomic) NSTimeInterval initialPlaybackTime;
@property (nonatomic, assign) MPMovieScalingMode scalingMode;
@property (nonatomic, assign) BOOL fullscreen;
@property (nonatomic, readonly, getter=isAirPlayVideoActive) BOOL airPlayVideoActive;
@property (nonatomic, readonly, getter=isChromecastVideoActive) BOOL chromecastVideoActive;
@property (nonatomic) BOOL allowsAirPlay;
@property (nonatomic) BOOL allowsChromecast;

/*  Properties for customising the class used for the indivdual control styles
    Classes should conform to the CTChromecastMovieControlsViewProtocol
    and implement the CTChromecastMovieControlsViewDelegate methods
*/
@property (nonatomic, strong) NSString *controlClassStyleDefault;
@property (nonatomic, strong) NSString *controlClassStyleEmbedded;
@property (nonatomic, strong) NSString *controlClassStyleFullscreen;
@property (nonatomic, strong) NSString *controlClassStyleNone;

/** Changes when switching from chromecast / local */
@property (nonatomic, assign) BOOL isSwitchingOutput;

- (id)initWithContentURL:(NSURL *)url;

/** Alternates the scaling */
- (void)toggleScalingMode;

/** Not currently implemented */
- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;

@end
